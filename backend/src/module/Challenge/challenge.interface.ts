import { Schema } from "mongoose";

export interface IChallenge {
  authorId: Schema.Types.ObjectId;
  challengeName: string;
  challengeDesc:string;
  challengePoster?: string;
  challengeStartDate: Date;
  challengeEndDate: Date;
  rules?: string[];
  createdAt?: Date;
  updatedAt?: Date;
}

type PopulatedUser = {
  _id: string;
  username: string;
  userDetails?: {
    name?: string;
    photo?: string;
  };
};

type PopulatedChallenge = {
  _id: string;
  challengeName: string;
  challengePoster?: string;
  authorId?: PopulatedUser;
};

export interface IPopulatedParticipant {
  _id: string;
  challengeId: PopulatedChallenge;
  postId: string;
  participantId: PopulatedUser;
}

export interface IChallengeResponse {
  _id: string;
  challengeName: string;
  challengeDesc: string;
  challengePoster: string;
  challengeStartDate: Date;
  challengeEndDate: Date;
  totalParticipants: number;
  rules: string[];
  participants: {
    _id: string;
    username: string;
    name: string;
    photo: string;
  }[];
  author: {
    _id: string;
    username: string;
    name: string;
    photo: string;
  };
}
