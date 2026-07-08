import { Document, Schema } from 'mongoose';

export type TReportStatus = 'open' | 'in_progress' | 'resolved' | 'closed';

export interface IReport {
  userId: Schema.Types.ObjectId;
  category: string;
  shortTitle: string;
  description: string;
  status: TReportStatus;
  adminResponse?: string;
  isReadByAdmin?: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface CreateReportInput {
  category: string;
  shortTitle: string;
  description: string;
  attachments?: string[] | string;
}

export interface UpdateReportInput {
  status?: TReportStatus;
  adminResponse?: string;
  isReadByAdmin?: boolean;
}

export interface ReportDocument extends IReport, Document {}
