import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { PostServices } from './post.service';
import { JwtPayload } from 'jsonwebtoken';


const createPost = catchAsync(async (req, res) => {
  // Validate file upload
  if (!req.file) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: 'Video file is required',
      data: null
    });
  }

  const fileUrl = req.file.path || (req.file as any)?.secure_url;

  if (!fileUrl) {
    return sendResponse(res, {
      statusCode: status.INTERNAL_SERVER_ERROR,
      success: false,
      message: 'Failed to upload video. Cloudinary error: cloud_name is disabled. Please check your CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET in .env file.',
      data: null
    });
  }



  const data = {
    ...req.body,
    authorId: req.user?.id,
    videoUrl: fileUrl
  };

  if (typeof data.tagPeople === 'string') {
    try {
      data.tagPeople = JSON.parse(data.tagPeople);
    } catch (error) {
      data.tagPeople = [];
    }
  }

  // Handle hashTagIds (note: field name should be hashTagIds, not hashTagNames)
  if (typeof data.hashTagIds === 'string') {
    try {
      data.hashTagIds = JSON.parse(data.hashTagIds);
    } catch {
      data.hashTagIds = [];
    }
  }

  // Also check for hashTagNames (common mistake) and convert if needed
  if (req.body.hashTagNames && !data.hashTagIds) {
    console.warn('hashTagNames field detected. Please use hashTagIds instead.');
    if (typeof req.body.hashTagNames === 'string') {
      try {
        data.hashTagIds = JSON.parse(req.body.hashTagNames);
      } catch {
        data.hashTagIds = [];
      }
    } else if (Array.isArray(req.body.hashTagNames)) {
      data.hashTagIds = req.body.hashTagNames;
    }
  }

  const post = await PostServices.createPost(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'Post created',
    data: post
  });
});

const getPost = catchAsync(async (req, res) => {
  const post = await PostServices.getPostById(req.params.id);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Post retrived successfully',
    data: post
  });
});

// only reels
const getLoggedInUserPosts = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;

  const userId = user._id.toString();

  const posts = await PostServices.getPostsByUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Post retrived successfully',
    data: posts
  });
});

const getUserPostsByUserId = catchAsync(async (req, res) => {

  const userId = req.params.userId;

  const posts = await PostServices.getPostsByUserId(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Post retrived successfully',
    data: posts
  });
});

const getFeed = catchAsync(async (req, res) => {
  const currentUser = req.user as JwtPayload;
  const posts = await PostServices.getFeed(currentUser.id);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Feed retrieved successfully",
    data: posts,
  });
});


const updatePost = catchAsync(async (req, res) => {
  const post = await PostServices.updatePost(req.params.id, req.body);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: post
  });
});

const deletePost = catchAsync(async (req, res) => {
  await PostServices.deletePost(req.params.postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Post deleted',
    data: null
  });
});

const getTaggedPosts = catchAsync(async (req, res) => {
  const { userId } = req.params;

  const result = await PostServices.getTaggedPosts(userId);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Tagged posts retrieved successfully",
    data: result
  });
});

const getTrendingPosts = catchAsync(async (req, res) => {
  const posts = await PostServices.getTrendingPosts();
  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Trending posts retrieved successfully",
    data: posts
  });
});
export const PostController = {
  createPost,
  getPost,
  getLoggedInUserPosts,
  getUserPostsByUserId,
  getFeed,
  updatePost,
  deletePost,
  getTaggedPosts,
  getTrendingPosts
};
