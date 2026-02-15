import {
  DynamoDBClient,
  CreateTableCommand,
  DescribeTableCommand,
} from '@aws-sdk/client-dynamodb';

const client = new DynamoDBClient({
  region: process.env.AWS_REGION || 'eu-central-1',
  endpoint: process.env.DYNAMODB_ENDPOINT || 'http://localhost:8000',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'local',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'local',
  },
});

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || 'urls';

async function init() {
  try {
    await client.send(new DescribeTableCommand({ TableName: TABLE_NAME }));
    console.log(`Table "${TABLE_NAME}" already exists.`);
    return;
  } catch (error: unknown) {
    if (error && typeof error === 'object' && 'name' in error && error.name !== 'ResourceNotFoundException') {
      throw error;
    }
  }

  console.log(`Creating table "${TABLE_NAME}"...`);

  await client.send(
    new CreateTableCommand({
      TableName: TABLE_NAME,
      KeySchema: [{ AttributeName: 'shortCode', KeyType: 'HASH' }],
      AttributeDefinitions: [
        { AttributeName: 'shortCode', AttributeType: 'S' },
        { AttributeName: 'longUrl', AttributeType: 'S' },
      ],
      GlobalSecondaryIndexes: [
        {
          IndexName: 'LongUrlIndex',
          KeySchema: [{ AttributeName: 'longUrl', KeyType: 'HASH' }],
          Projection: { ProjectionType: 'ALL' },
          ProvisionedThroughput: {
            ReadCapacityUnits: 5,
            WriteCapacityUnits: 5,
          },
        },
      ],
      ProvisionedThroughput: {
        ReadCapacityUnits: 5,
        WriteCapacityUnits: 5,
      },
    })
  );

  console.log(`Table "${TABLE_NAME}" created successfully.`);
}

init().catch((err) => {
  console.error('Failed to initialize DynamoDB:', err);
  process.exit(1);
});
