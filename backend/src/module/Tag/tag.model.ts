import { model, Schema } from "mongoose";
import { ITag } from "./tag.interface";

const tagSchema = new Schema<ITag>(
  {
    tagName: { type: String, required: true },
  },
  { timestamps: true }
);

export const Tag = model<ITag>('Tag', tagSchema);
