import { Router } from 'express';
import auth from '../../app/middleware/auth';
import { USER_ROLE } from '../User/user.constant';
import { PointController } from './point .controller';

const router = Router();

router.get('/:userId', auth(USER_ROLE.user, USER_ROLE.admin), PointController.getUserPoints);
router.get('/:userId/history', auth(USER_ROLE.user, USER_ROLE.admin), PointController.getPointHistory);

export const PointRoutes = router;
