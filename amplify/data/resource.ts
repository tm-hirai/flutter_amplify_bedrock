import {
  type ClientSchema,
  a,
  defineData,
  defineFunction,
} from "@aws-amplify/backend";

export const MODEL_ID = "anthropic.claude-3-sonnet-20240229-v1:0";

export const calorieCalculationFunction = defineFunction({
  entry: "./calorieCalculation.ts",
  environment: {
    MODEL_ID,
  },
  runtime: 20,
  timeoutSeconds: 10,
});

const schema = a.schema({
  calorieCalculation: a
    .query()
    .arguments({ base64String: a.string().required() })
    .returns(a.string())
    .authorization((allow) => [allow.publicApiKey()])
    .handler(a.handler.function(calorieCalculationFunction)),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: "apiKey",
    apiKeyAuthorizationMode: {
      expiresInDays: 30,
    },
  },
});
