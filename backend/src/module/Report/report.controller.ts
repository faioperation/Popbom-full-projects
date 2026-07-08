import { Request, Response } from 'express';
import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { JwtPayload } from 'jsonwebtoken';
import { ReportServices } from './report.service';

// POST /reports
const createReport = catchAsync(async (req: Request, res: Response) => {
  const user = req.user as JwtPayload;
  const userId = user?.id || user?._id;
  const body = req.body;

  const payload = {
    category: body.category,
    shortTitle: body.shortTitle,
    description: body.description
  };

  const report = await ReportServices.createReport(userId, payload);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'Report submitted successfully',
    data: report
  });
});

// GET /reports  (admin)
const getReports = catchAsync(async (req: Request, res: Response) => {
  const { page = '1', limit = '20', status: s, category, userId, from, to } = req.query as any;
  const filter: any = {};
  if (s) filter.status = s;
  if (category) filter.category = category;
  if (userId) filter.userId = userId;
  if (from) filter.from = from;
  if (to) filter.to = to;

  const result = await ReportServices.getReports(filter, { page: Number(page), limit: Number(limit) });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Reports retrieved successfully',
    data: result
  });
});

// GET /reports/:id
const getReportById = catchAsync(async (req: Request, res: Response) => {
  const report = await ReportServices.getReportById(req.params.id);
  if (!report) {
    return sendResponse(res, {
      statusCode: status.NOT_FOUND,
      success: false,
      message: 'Report not found',
      data: null
    });
  }

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Report retrieved successfully',
    data: report
  });
});

// PATCH /reports/:id
const updateReport = catchAsync(async (req: Request, res: Response) => {
  const updates = {
    status: req.body.status,
    adminResponse: req.body.adminResponse,
    isReadByAdmin: typeof req.body.isReadByAdmin === 'boolean' ? req.body.isReadByAdmin : undefined
  };

  const updated = await ReportServices.updateReport(req.params.id, updates);
  if (!updated) {
    return sendResponse(res, {
      statusCode: status.NOT_FOUND,
      success: false,
      message: 'Report not found',
      data: null
    });
  }

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Report updated successfully',
    data: updated
  });
});

// DELETE /reports/:id
const deleteReport = catchAsync(async (req: Request, res: Response) => {
  const ok = await ReportServices.deleteReport(req.params.id);
  if (!ok) {
    return sendResponse(res, {
      statusCode: status.NOT_FOUND,
      success: false,
      message: 'Report not found',
      data: null
    });
  }

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Report deleted successfully',
    data: null
  });
});

export const ReportController = {
  createReport,
  getReports,
  getReportById,
  updateReport,
  deleteReport
};
