import { defineBackend } from "@aws-amplify/backend";
import { data, MODEL_ID, calorieCalculationFunction } from "./data/resource";
import { Effect, PolicyStatement } from "aws-cdk-lib/aws-iam";

export const backend = defineBackend({
  data,
  calorieCalculationFunction,
});

backend.calorieCalculationFunction.resources.lambda.addToRolePolicy(
  new PolicyStatement({
    effect: Effect.ALLOW,
    actions: ["bedrock:InvokeModel"],
    resources: [`arn:aws:bedrock:us-east-1::foundation-model/${MODEL_ID}`],
  })
);
