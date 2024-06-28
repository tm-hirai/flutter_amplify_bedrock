import type { Schema } from "./resource";
import {
  BedrockRuntimeClient,
  InvokeModelCommand,
  InvokeModelCommandInput,
} from "@aws-sdk/client-bedrock-runtime";

// initialize bedrock runtime client
const client = new BedrockRuntimeClient({ region: "us-east-1" });

export const handler: Schema["calorieCalculation"]["functionHandler"] = async (
  event,
  _
) => {
  const base64String = event.arguments.base64String;

  const input = {
    modelId: process.env.MODEL_ID,
    contentType: "application/json",
    accept: "application/json",
    body: JSON.stringify({
      anthropic_version: "bedrock-2023-05-31",
      system:
        "You are a calorie analysis expert capable of estimating the calories of any dish shown in an image.",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {
                type: "base64",
                media_type: "image/jpeg",
                data: base64String,
              },
            },
            {
              type: "text",
              text: `Estimate calories of the food in this image. Use JSON format with "food" (dish name in Japanese) and "calorie" (in kcal) as keys.
              Do not output anything other than JSON.
              <example>
              {
                "food": "寿司",
                "calorie": 300
              }
              </example>
              `,
            },
          ],
        },
      ],
      max_tokens: 1000,
      temperature: 0,
    }),
  } as InvokeModelCommandInput;

  const command = new InvokeModelCommand(input);
  const response = await client.send(command);
  const data = JSON.parse(Buffer.from(response.body).toString());
  return data.content[0].text;
};
