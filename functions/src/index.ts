import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

/**
 * Triggered when a new message is posted in a conversation.
 * Sends push notification via FCM to the recipient.
 */
export const onChatMessageCreated = functions.firestore
  .document('conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const conversationId = context.params.conversationId;

    const convDoc = await db.collection('conversations').doc(conversationId).get();
    if (!convDoc.exists) return;

    const conv = convDoc.data();
    if (!conv) return;

    const recipientId = conv.participantIds.find((id: string) => id !== message.senderId);
    if (!recipientId) return;

    // Fetch recipient's FCM tokens
    const userDoc = await db.collection('users').doc(recipientId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (fcmToken) {
      await fcm.send({
        token: fcmToken,
        notification: {
          title: `New message from @${message.senderHandle}`,
          body: message.text,
        },
        data: {
          conversationId,
          type: 'chat',
        },
      });
    }
  });

/**
 * Triggered when a user likes a post.
 * Sends an in-app and push notification to the post's author.
 */
export const onPostLiked = functions.firestore
  .document('posts/{postId}/likes/{userId}')
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const likerId = context.params.userId;

    const postDoc = await db.collection('posts').doc(postId).get();
    if (!postDoc.exists) return;
    const post = postDoc.data();
    if (!post || post.authorId === likerId) return; // Don't notify self

    const likerDoc = await db.collection('users').doc(likerId).get();
    const liker = likerDoc.data();

    // Create in-app notification in author's subcollection
    await db.collection('users').doc(post.authorId).collection('notifications').add({
      userId: post.authorId,
      senderId: likerId,
      senderDisplayName: liker?.displayName || 'User',
      senderHandle: liker?.handle || 'user',
      senderAvatarUrl: liker?.avatarUrl || null,
      type: 'like',
      postId,
      postSnippet: (post.content || '').substring(0, 60),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
    });
  });

/**
 * Callable function to assign trusted admin role claims.
 */
export const setAdminRole = functions.https.onCall(async (data, context) => {
  // Ensure the caller is already an admin
  if (context.auth?.token.admin !== true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only existing administrators can assign admin claims.'
    );
  }

  const targetUid = data.uid;
  await admin.auth().setCustomUserClaims(targetUid, { admin: true });
  return { success: true, message: `Admin role granted to ${targetUid}` };
});
