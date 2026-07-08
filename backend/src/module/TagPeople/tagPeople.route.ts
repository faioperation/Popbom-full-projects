import { Router } from 'express';
import { TagPeopleController } from './tagPeople.controller';
import auth from '../../app/middleware/auth';
import { USER_ROLE } from '../User/user.constant';
import validateRequest from '../../app/middleware/validateRequest';
import { TagPeopleValidation } from './tagPeople.validation';

const router = Router();

// Create tag (tag a user in a post)
router.post(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(TagPeopleValidation.tagSchema),
  TagPeopleController.tagUser
);

// Get tagged users for a post
router.get(
  '/post/:postId',
  auth(USER_ROLE.user, USER_ROLE.admin),
  TagPeopleController.getTaggedUsers
);

// Get posts where a user was tagged
router.get(
  '/user/:userId',
  auth(USER_ROLE.user, USER_ROLE.admin),
  TagPeopleController.getTaggedPosts
);

// Delete tag by tag document id
router.delete(
  '/:id',
  auth(USER_ROLE.user, USER_ROLE.admin),
  TagPeopleController.removeTag
);

// Optional: delete by post+user pair (body)
router.delete(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(TagPeopleValidation.removeByPostUserSchema),
  TagPeopleController.removeTagByPostUser
);

export const TagPeopleRoutes = router;
