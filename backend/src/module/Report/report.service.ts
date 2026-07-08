import { ReportModel } from './report.model';
import { CreateReportInput, UpdateReportInput } from './report.interface';
import mongoose, { Types } from 'mongoose';


const createReport = async (userId: string, payload: CreateReportInput) => {
  
  const report = await ReportModel.create({
    userId: new Types.ObjectId(userId),
    category: payload.category,
    shortTitle: payload.shortTitle,
    description: payload.description,
    status: 'open'
  });

  return report;
};

const getReportById = async (id: string) => {
  if (!Types.ObjectId.isValid(id)) return null;
  const report = await ReportModel.findById(id)
    .populate({ path: 'userId', select: 'username email', populate: { path: 'userDetails', select: 'name photo' } })
    .lean();
  return report;
};

const getReports = async (filter: any = {}, options: { page?: number; limit?: number; sort?: any } = {}) => {
  const page = Math.max(1, options.page ?? 1);
  const limit = Math.max(1, options.limit ?? 20);
  const skip = (page - 1) * limit;
  const sort = options.sort ?? { createdAt: -1 };

  const q: any = {};
  if (filter.status) q.status = filter.status;
  if (filter.category) q.category = filter.category;
  if (filter.userId && Types.ObjectId.isValid(filter.userId)) q.userId = new Types.ObjectId(filter.userId);
  if (filter.from || filter.to) {
    q.createdAt = {};
    if (filter.from) q.createdAt.$gte = new Date(filter.from);
    if (filter.to) q.createdAt.$lte = new Date(filter.to);
  }

  const [data, total] = await Promise.all([
    ReportModel.find(q).sort(sort).skip(skip).limit(limit)
      .populate({ path: 'userId', select: 'username', populate: { path: 'userDetails', select: 'name photo' } })
      .lean(),
    ReportModel.countDocuments(q)
  ]);

  return { data, total, page, limit };
};

const updateReport = async (reportId: string, updates: UpdateReportInput) => {
  if (!Types.ObjectId.isValid(reportId)) return null;
  const updated = await ReportModel.findByIdAndUpdate(reportId, { $set: updates }, { new: true, runValidators: true });
  return updated;
};

const deleteReport = async (reportId: string) => {
  if (!Types.ObjectId.isValid(reportId)) return false;
  const session = await mongoose.startSession();
  try {
    session.startTransaction();
    const r = await ReportModel.findById(reportId).session(session);
    if (!r) {
      await session.abortTransaction();
      session.endSession();
      return false;
    }
    await ReportModel.findByIdAndDelete(reportId).session(session);
    await session.commitTransaction();
    session.endSession();
    return true;
  } catch (err) {
    try { await session.abortTransaction(); session.endSession(); } catch {}
    throw err;
  }
};

export const ReportServices = {
  createReport,
  getReportById,
  getReports,
  updateReport,
  deleteReport
};
