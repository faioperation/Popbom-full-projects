import z from 'zod';

const createReportSchema = z.object({
  body: z.object({
    category: z.string({ required_error: 'Category is required' }).min(1),
    shortTitle: z.string({ required_error: 'Short title is required' }).min(1).max(150),
    description: z.string({ required_error: 'Description is required' }).min(10)
  })
});

const updateReportSchema = z.object({
  body: z.object({
    status: z.enum(['open','in_progress','resolved','closed']).optional(),
    adminResponse: z.string().optional().nullable(),
    isReadByAdmin: z.boolean().optional()
  })
});

const getReportsQuerySchema = z.object({
  query: z.object({
    page: z.string().optional(), // parse to number in controller
    limit: z.string().optional(),
    status: z.enum(['open','in_progress','resolved','closed']).optional(),
    category: z.string().optional(),
    userId: z.string().optional(),
    from: z.string().optional(),
    to: z.string().optional()
  })
});

export const ReportValidation = {
  createReportSchema,
  updateReportSchema,
  getReportsQuerySchema
};
