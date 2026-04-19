export const mealInterpretationSchema = {
  type: "object",
  additionalProperties: false,
  required: ["title", "summary", "confidenceBand", "totals", "items"],
  properties: {
    title: {
      type: "string",
      minLength: 1,
      maxLength: 120,
    },
    summary: {
      type: "string",
      minLength: 1,
      maxLength: 240,
    },
    confidenceBand: {
      type: "string",
      enum: ["low", "medium", "high"],
    },
    totals: {
      type: "object",
      additionalProperties: false,
      required: ["kcal", "carbs", "fat", "protein"],
      properties: {
        kcal: { type: "number", minimum: 0 },
        carbs: { type: "number", minimum: 0 },
        fat: { type: "number", minimum: 0 },
        protein: { type: "number", minimum: 0 },
      },
    },
    items: {
      type: "array",
      minItems: 1,
      maxItems: 12,
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "id",
          "label",
          "amount",
          "unit",
          "kcal",
          "carbs",
          "fat",
          "protein",
          "confidenceBand",
          "editable",
        ],
        properties: {
          id: {
            type: "string",
            minLength: 1,
            maxLength: 64,
          },
          label: {
            type: "string",
            minLength: 1,
            maxLength: 120,
          },
          amount: {
            type: "number",
            exclusiveMinimum: 0,
          },
          unit: {
            type: "string",
            enum: ["g", "ml", "serving", "oz", "fl oz", "g/ml"],
          },
          kcal: { type: "number", minimum: 0 },
          carbs: { type: "number", minimum: 0 },
          fat: { type: "number", minimum: 0 },
          protein: { type: "number", minimum: 0 },
          confidenceBand: {
            type: "string",
            enum: ["low", "medium", "high"],
          },
          editable: { type: "boolean" },
        },
      },
    },
  },
} as const;
