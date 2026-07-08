import { Router } from 'express';
import { PostTagController } from './postTag.controller';
import auth from '../../app/middleware/auth';
import { USER_ROLE } from '../User/user.constant';
import validateRequest from '../../app/middleware/validateRequest';
import { PostTagValidation } from './postTag.validation';


const router = Router();

// get tags for a post
router.get('/post/:postId', PostTagController.getTagsForPost);

// get posts for a tag
router.get('/tag/:tagId', PostTagController.getPostsByTag);

// delete by PostTag document id
router.delete('/:id', auth(USER_ROLE.user, USER_ROLE.admin), PostTagController.removePostTagById);

// optional: delete by postId + tagId in body
router.delete(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(PostTagValidation.removeByPostTagSchema),
  PostTagController.removePostTag
);

export const PostTagRoutes = router;
