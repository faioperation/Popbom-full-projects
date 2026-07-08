import { Router } from "express";
import { UserRoutes } from "../../module/User/user.route";
import { AuthRoutes } from "../../module/Auth/auth.route";
import { PostRoutes } from "../../module/Post/post.route";
import { CommentRoutes } from "../../module/Comment/comment.route";
import { PostReactionRoutes } from "../../module/PostReaction/reaction.route";
import { SavedPostRoutes } from "../../module/SavePost/savedPost.route";
import { SharedPostRoutes } from "../../module/SharedPost/sharedPost.route";
import { StoryRoutes } from "../../module/Story/story.route";
import { ChallengeRoutes } from "../../module/Challenge/challenge.route";
import { ChallengeParticipantRoutes } from "../../module/ChallengeParticipant/participant.route";
import { PostWatchRoutes } from "../../module/PostWatchHistory/watch.route";
import { PostWatchCountRoutes } from "../../module/PostWatchCount/watchCount.route";
import { StoryReactionRoutes } from "../../module/StoryReaction/reaction.route";
import { StoryReplyRoutes } from "../../module/StoryReply/reply.route";
import { FollowRoutes } from "../../module/Follow/follow.route";
import { TagRoutes } from "../../module/Tag/tag.route";
import { MusicRoutes } from "../../module/Music/music.route";
import { ReportRoutes } from "../../module/Report/report.route";
import { ChatRoutes } from "../../module/Chat/chat.route";
import { PointRoutes } from "../../module/Point/point.route";
import { GiftRoutes } from "../../module/Gift/gift.route";
import { AdminAuthRoutes } from "../../module/AdminAuth/adminAuth.route";
import { AdminRoutes } from "../../module/Admin/admin.route";
import { ShareProfileRoutes } from "../../module/ShareProfile/shareProfile.route";
import { NotificationRoutes } from "../../module/Notification/notification.route";
import { AiRecommendationRoutes } from "../../module/AIRecommendation/aiRecommendation.route";
import { VisualSearchRoutes } from "../../module/VisualSearch/search.route";
import { LiveRoutes } from "../../module/Live/live.route";

const router = Router();

const moduleRoutes = [
    {
        path: '/auth',
        route: AuthRoutes
    },
    {
        path: '/users',
        route: UserRoutes
    },
    {
        path: '/posts',
        route: PostRoutes
    },
    {
        path: '/comments',
        route: CommentRoutes
    },
    {
        path: '/post-reactions',
        route: PostReactionRoutes
    },
    {
        path: '/saved-posts',
        route: SavedPostRoutes
    },
    {
        path: '/shared-posts',
        route: SharedPostRoutes
    },
    {
        path: '/stories',
        route: StoryRoutes
    },
    {
        path: '/challenges',
        route: ChallengeRoutes
    },
    {
        path: '/challenge-participants',
        route: ChallengeParticipantRoutes
    },
    {
        path: '/post-watch',
        route: PostWatchRoutes
    },
    {
        path: '/post-watch-count',
        route: PostWatchCountRoutes
    },
    {
        path: '/story-reaction',
        route: StoryReactionRoutes
    },
    {
        path: '/story-reply',
        route: StoryReplyRoutes
    },
    {
        path: '/follow',
        route: FollowRoutes
    },
    {
        path: '/tag',
        route: TagRoutes
    },
    {
        path: '/music',
        route: MusicRoutes
    },
    {
        path: '/chat',
        route: ChatRoutes
    },
    {
        path: '/notification',
        route: NotificationRoutes
    },
    {
        path: '/report',
        route: ReportRoutes
    },
    {
        path: '/point',
        route: PointRoutes
    },
    {
        path: '/gift',
        route: GiftRoutes
    },
    {
        path: '/auth/admin',
        route: AdminAuthRoutes
    },
    {
        path: '/admin',
        route: AdminRoutes
    },
    {
        path: '/share-profile',
        route: ShareProfileRoutes
    },
    {
        path: "/ai-recommendation",
        route: AiRecommendationRoutes
    },
    {
        path: '/ai-visual-search',
        route: VisualSearchRoutes
    },
    {
        path: '/live',
        route: LiveRoutes
    }
    
];

moduleRoutes.forEach((route) => router.use(route.path, route.route));

export default router;
