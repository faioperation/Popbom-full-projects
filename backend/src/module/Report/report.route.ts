import { Router } from 'express';
import { ReportController } from './report.controller';
import auth from '../../app/middleware/auth';
import { USER_ROLE } from '../User/user.constant';
import validateRequest from '../../app/middleware/validateRequest';
import { ReportValidation } from './report.validation';


const router = Router();

router.post(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(ReportValidation.createReportSchema),
  ReportController.createReport
);

// list (admin)
router.get(
  '/',
  auth(USER_ROLE.user),
  ReportController.getReports
);

// get single (owner or admin)
router.get(
  '/:id',
  auth(USER_ROLE.user, USER_ROLE.admin),
  ReportController.getReportById
);

// update (admin)
router.patch(
  '/:id',
  auth(USER_ROLE.admin),
  validateRequest(ReportValidation.updateReportSchema),
  ReportController.updateReport
);

// delete (admin)
router.delete(
  '/:id',
  auth(USER_ROLE.admin),
  ReportController.deleteReport
);

export const ReportRoutes = router;
