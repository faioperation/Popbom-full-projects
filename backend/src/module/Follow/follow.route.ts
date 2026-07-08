import { Router } from 'express';
import { FollowController } from './follow.controller';
import auth from '../../app/middleware/auth';
import { USER_ROLE } from '../User/user.constant';

const router = Router();

// Toggle follow (follow/unfollow)
router.post('/toggle', auth(USER_ROLE.user, USER_ROLE.admin), FollowController.toggleFollow);

// amk jara follow krtese
router.get('/followers/:userId', FollowController.getFollowers);

// ami jader k follow krtesi
router.get('/following/:userId', FollowController.getFollowing);

// Unfollow by follow-record id (owner or admin)
router.delete('/:id', auth(USER_ROLE.user, USER_ROLE.admin), FollowController.unfollow);

// Optional quick check
router.get('/is-following', auth(USER_ROLE.user, USER_ROLE.admin), FollowController.isFollowing);

export const FollowRoutes = router;
