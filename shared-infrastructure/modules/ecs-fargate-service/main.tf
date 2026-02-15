###############################################################################
# IAM - Execution Role (for ECS agent to pull images, push logs)
###############################################################################
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "execution" {
  name = "${var.service_name}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "execution_base" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow pulling secrets if any are configured
resource "aws_iam_role_policy" "execution_secrets" {
  count = length(var.secrets) > 0 ? 1 : 0
  name  = "${var.service_name}-execution-secrets"
  role  = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters",
      ]
      Resource = [for s in var.secrets : s.valueFrom]
    }]
  })
}

###############################################################################
# IAM - Task Role (for application code)
###############################################################################
resource "aws_iam_role" "task" {
  name = "${var.service_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

# Attach additional managed policies
resource "aws_iam_role_policy_attachment" "task_additional" {
  for_each   = toset(var.task_role_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = each.value
}

# Attach inline policy if provided
resource "aws_iam_role_policy" "task_inline" {
  count  = var.task_role_policy_json != null ? 1 : 0
  name   = "${var.service_name}-task-policy"
  role   = aws_iam_role.task.id
  policy = var.task_role_policy_json
}

# X-Ray permissions
resource "aws_iam_role_policy_attachment" "task_xray" {
  count      = var.enable_xray_tracing ? 1 : 0
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

###############################################################################
# Security Group
###############################################################################
resource "aws_security_group" "task" {
  name_prefix = "${var.service_name}-task-"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.service_name} ECS tasks"

  tags = merge(var.tags, { Name = "${var.service_name}-task" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "task_from_alb" {
  count = var.create_alb ? 1 : 0

  security_group_id            = aws_security_group.task.id
  referenced_security_group_id = aws_security_group.alb[0].id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  description                  = "Allow traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "task_all" {
  security_group_id = aws_security_group.task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

###############################################################################
# Task Definition
###############################################################################
locals {
  app_container = {
    name      = var.service_name
    image     = var.container_image
    cpu       = var.enable_xray_tracing ? var.cpu - 32 : var.cpu
    memory    = var.enable_xray_tracing ? var.memory - 64 : var.memory
    essential = true

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    environment = var.environment_variables
    secrets     = var.secrets

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = data.aws_region.current.id
        "awslogs-stream-prefix" = var.service_name
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }

  xray_container = var.enable_xray_tracing ? [{
    name      = "xray-daemon"
    image     = "public.ecr.aws/xray/aws-xray-daemon:latest"
    cpu       = 32
    memory    = 64
    essential = false

    portMappings = [{
      containerPort = 2000
      protocol      = "udp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = data.aws_region.current.id
        "awslogs-stream-prefix" = "xray"
      }
    }
  }] : []

  container_definitions = jsonencode(concat([local.app_container], local.xray_container))
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions    = local.container_definitions

  tags = var.tags
}

###############################################################################
# ECS Service
###############################################################################
resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.create_alb ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.enable_service_discovery && var.ecs_namespace_arn != null ? [1] : []
    content {
      enabled   = true
      namespace = var.ecs_namespace_arn

      service {
        port_name      = var.service_name
        discovery_name = var.service_name
        client_alias {
          port     = var.container_port
          dns_name = var.service_name
        }
      }
    }
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = var.tags

  lifecycle {
    ignore_changes = [desired_count]
  }
}

###############################################################################
# ALB
###############################################################################
resource "aws_security_group" "alb" {
  count = var.create_alb ? 1 : 0

  name_prefix = "${var.service_name}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.service_name} ALB"

  tags = merge(var.tags, { Name = "${var.service_name}-alb" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count = var.create_alb && var.alb_certificate_arn != null ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  cidr_ipv4         = var.alb_ingress_cidr_blocks[0]
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count = var.create_alb ? 1 : 0

  security_group_id = aws_security_group.alb[0].id
  cidr_ipv4         = var.alb_ingress_cidr_blocks[0]
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_task" {
  count = var.create_alb ? 1 : 0

  security_group_id            = aws_security_group.alb[0].id
  referenced_security_group_id = aws_security_group.task.id
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  description                  = "Allow traffic to tasks"
}

resource "aws_lb" "this" {
  count = var.create_alb ? 1 : 0

  name               = var.service_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.alb_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  count = var.create_alb ? 1 : 0

  name        = var.service_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  count = var.create_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = var.alb_certificate_arn != null ? "redirect" : "forward"
    target_group_arn = var.alb_certificate_arn == null ? aws_lb_target_group.this[0].arn : null

    dynamic "redirect" {
      for_each = var.alb_certificate_arn != null ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  count = var.create_alb && var.alb_certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  tags = var.tags
}

###############################################################################
# Auto Scaling
###############################################################################
resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${split("/", var.cluster_arn)[1]}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.autoscaling_cpu_target
  }
}
