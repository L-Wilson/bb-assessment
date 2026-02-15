import { createApp } from './app';
import { DynamoUrlRepository } from './repositories/dynamoUrlRepository';
import { config } from './config';
import { logger } from './utils/logger';

const repository = new DynamoUrlRepository();
const app = createApp(repository);

app.listen(config.port, () => {
  logger.info(`Server started on port ${config.port}`, {
    env: config.nodeEnv,
    baseUrl: config.baseUrl,
  });
});
