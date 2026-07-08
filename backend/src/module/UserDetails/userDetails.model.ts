import { model, Schema } from "mongoose";
import { IUserDetails } from "./userDetails.interface";

const userDetailsSchema = new Schema<IUserDetails>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    name: { type: String, required: true },
    bio: { type: String, default: '' },
    photo:{
            type:String,
            default:'',
        },
    instaLink: { type: String, default: '' },
    youtubeLink: { type: String, default: '' },
    deletedAt: { type: Date, default: null },
  },
  { timestamps: true }
);

export const UserDetails = model<IUserDetails>('UserDetails', userDetailsSchema);
