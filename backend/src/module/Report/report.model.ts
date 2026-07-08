import { model, Schema } from 'mongoose';
import { ReportDocument } from './report.interface';

const ReportSchema = new Schema<ReportDocument>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    category: { type: String, required: true },
    shortTitle: { type: String, required: true },
    description: { type: String, required: true },
    status: { type: String, enum: ['open','in_progress','resolved','closed'], default: 'open' },
    adminResponse: { type: String, default: '' },
    isReadByAdmin: { type: Boolean, default: false }
  },
  { timestamps: true }
);

// text index to support search later
ReportSchema.index({ shortTitle: 'text', description: 'text' });

export const ReportModel = model<ReportDocument>('Report', ReportSchema);
