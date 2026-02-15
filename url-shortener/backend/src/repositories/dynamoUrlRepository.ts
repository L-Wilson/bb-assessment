import { PutCommand, GetCommand, QueryCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { DescribeTableCommand } from '@aws-sdk/client-dynamodb';
import { docClient, dynamoClient } from '../config/database';
import { config } from '../config';
import { UrlEntity } from '../types';
import { UrlRepository } from './urlRepository';

const TABLE_NAME = config.dynamodb.tableName;

export class DynamoUrlRepository implements UrlRepository {
  async save(url: UrlEntity): Promise<UrlEntity> {
    await docClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: {
          shortCode: url.shortCode,
          longUrl: url.longUrl,
          createdAt: url.createdAt.toISOString(),
          clickCount: url.clickCount,
          userId: url.userId,
        },
        ConditionExpression: 'attribute_not_exists(shortCode)',
      })
    );
    return url;
  }

  async findByShortCode(shortCode: string): Promise<UrlEntity | null> {
    const result = await docClient.send(
      new GetCommand({
        TableName: TABLE_NAME,
        Key: { shortCode },
      })
    );

    if (!result.Item) return null;

    return {
      shortCode: result.Item.shortCode,
      longUrl: result.Item.longUrl,
      createdAt: new Date(result.Item.createdAt),
      clickCount: result.Item.clickCount ?? 0,
      userId: result.Item.userId,
    };
  }

  async findByLongUrl(longUrl: string): Promise<UrlEntity | null> {
    const result = await docClient.send(
      new QueryCommand({
        TableName: TABLE_NAME,
        IndexName: 'LongUrlIndex',
        KeyConditionExpression: 'longUrl = :longUrl',
        ExpressionAttributeValues: {
          ':longUrl': longUrl,
        },
        Limit: 1,
      })
    );

    if (!result.Items || result.Items.length === 0) return null;

    const item = result.Items[0];
    return {
      shortCode: item.shortCode,
      longUrl: item.longUrl,
      createdAt: new Date(item.createdAt),
      clickCount: item.clickCount ?? 0,
      userId: item.userId,
    };
  }

  async incrementClickCount(shortCode: string): Promise<void> {
    await docClient.send(
      new UpdateCommand({
        TableName: TABLE_NAME,
        Key: { shortCode },
        UpdateExpression: 'SET clickCount = clickCount + :inc',
        ExpressionAttributeValues: {
          ':inc': 1,
        },
      })
    );
  }

  async healthCheck(): Promise<boolean> {
    try {
      await dynamoClient.send(
        new DescribeTableCommand({ TableName: TABLE_NAME })
      );
      return true;
    } catch {
      return false;
    }
  }
}
