import mongoose from 'mongoose';
import { IGift } from './gift.interface';
import { Gift } from './gift.model';
import { User } from '../User/user.modal';
import { PointHistory } from '../Point/point.model';
import { NotificationService } from '../Notification/notification.service';

const GIFT_POINT_MAP: Record<string, number> = {
  coin: 100,
  heart: 50,
  rose: 50,
  star: 50,
  fire: 50,
};

const sendGift = async (payload: Partial<IGift>) => {

  if (!payload.authorId) throw new Error('authorId is required');
  if (!payload.userId) throw new Error('userId (recipient) is required');
  if (!payload.giftType) throw new Error('giftType is required');

  // prevent self-gift if you want
  if (payload.authorId.toString() === payload.userId.toString()) {
    throw new Error('Sender cannot send gift to themselves');
  }

  // ensure recipient exists
  const recipient = await User.findById(payload.userId);
  if (!recipient) throw new Error('Recipient user not found');

  const session = await mongoose.startSession();
  try {
    session.startTransaction();

    // 1) create gift
    const created = await Gift.create([payload as IGift], { session });
    const createdGift = created[0];

    // 2) compute points
    const pointsToAdd = GIFT_POINT_MAP[createdGift.giftType] ?? 0;

    if (pointsToAdd > 0) {
      // atomic increment points on recipient
      await User.findByIdAndUpdate(
        createdGift.userId,
        { $inc: { points: pointsToAdd } },
        { session }
      );

      // 3) log history
      await PointHistory.create([{
        userId: createdGift.userId,
        change: pointsToAdd,
        reason: 'gift_received',
        sourceType: 'gift',
        sourceId: createdGift._id,
      }], { session });
    }

    await NotificationService.sendNotification({
      userId: createdGift.userId as any,
      senderId: createdGift.authorId as any,
      type: 'gift',
      message: `sent you a ${createdGift.giftType}`,
      linkType: 'gift',
      linkId: createdGift._id as any,
    });

    await session.commitTransaction();
    session.endSession();

    // populate author if you want to return
    await createdGift.populate('authorId', 'username');

    return createdGift;
  } catch (err) {
    try { await session.abortTransaction(); session.endSession(); } catch (e) { }
    throw err;
  }
};



export const GiftService = {
  sendGift
};
