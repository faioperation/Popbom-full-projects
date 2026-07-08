import { Router } from 'express';
import { PostController } from './post.controller';
import auth from '../../app/middleware/auth';
import { USER_ROLE } from '../User/user.constant';
import upload from '../../app/middleware/upload';
import { handleUploadError } from '../../app/middleware/upload.middleware';

const router = Router();

router.post('/', auth(USER_ROLE.user, USER_ROLE.admin), upload.single("video"),handleUploadError, PostController.createPost);  //ok
router.get('/my-posts', auth(USER_ROLE.user, USER_ROLE.admin), PostController.getLoggedInUserPosts); //ok
router.get('/trending', PostController.getTrendingPosts);
router.get('/user-posts/:userId', auth(USER_ROLE.user, USER_ROLE.admin), PostController.getUserPostsByUserId);
router.get('/tagged/:userId', auth(USER_ROLE.user, USER_ROLE.admin), PostController.getTaggedPosts); //ok

router.get('/:id', PostController.getPost);

router.get('/',auth(USER_ROLE.user, USER_ROLE.admin), PostController.getFeed); //ok

router.patch('/:id', auth(USER_ROLE.user, USER_ROLE.admin), PostController.updatePost);
router.delete('/delete/:postId', auth(USER_ROLE.user, USER_ROLE.admin), PostController.deletePost);

export const PostRoutes = router;
