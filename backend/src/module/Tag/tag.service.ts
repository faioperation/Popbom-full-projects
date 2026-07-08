import { ITag } from "./tag.interface";
import { Tag } from "./tag.model";

const createTag = async (payload: Partial<ITag>) => {

  if(!payload.tagName){
    throw new Error('Tag name is required');
  }
  const cleanName = payload.tagName.trim().toLowerCase();

  let tag = await Tag.findOne({ tagName: cleanName });

  if (!tag) {
    tag = await Tag.create({ tagName: cleanName });
  }

  return tag;
};

const getAllTags = async () => {
  return await Tag.find().sort({ createdAt: -1 });
};

export const TagService = {
  createTag,
  getAllTags
};
