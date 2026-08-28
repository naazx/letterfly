import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";

admin.initializeApp();

export const onNewLetter = onDocumentCreated(
  "pairs/{pairID}/letters/{letterID}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const letter = snapshot.data();
    const {pairID} = event.params;
    const authorID = letter.authorID;

    const pairDoc = await admin.firestore()
      .collection("pairs").doc(pairID).get();
    const members: string[] = pairDoc.data()?.members ?? [];
    const partnerID = members.find((id) => id !== authorID);

    if (!partnerID) return;

    const partnerDoc = await admin.firestore()
      .collection("users").doc(partnerID).get();
    const fcmToken = partnerDoc.data()?.fcmToken;

    if (!fcmToken) return;

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "New letter!",
        body: letter.subject ?? "You've received a new letter",
      },
    });
  }
);

/**
 * Sends push notifications to partners about letters unlocking soon.
 * @param {number} daysAhead - Days before unlock date to trigger reminder.
 * @param {string} message - Notification body text.
 */
async function sendUnlockReminders(daysAhead: number, message: string) {
  const now = new Date();
  const windowStart = new Date(
    now.getTime() + daysAhead * 24 * 60 * 60 * 1000
  );
  const windowEnd = new Date(
    windowStart.getTime() + 24 * 60 * 60 * 1000
  );

  const snapshot = await admin.firestore()
    .collectionGroup("letters")
    .where("unlockDate", ">=", windowStart)
    .where("unlockDate", "<", windowEnd)
    .get();

  for (const doc of snapshot.docs) {
    const letter = doc.data();
    const pairID = doc.ref.parent.parent?.id;
    if (!pairID) continue;

    const pairDoc = await admin.firestore()
      .collection("pairs").doc(pairID).get();
    const members: string[] = pairDoc.data()?.members ?? [];
    const partnerID = members.find((id) => id !== letter.authorID);

    if (!partnerID) continue;

    const partnerDoc = await admin.firestore()
      .collection("users").doc(partnerID).get();
    const fcmToken = partnerDoc.data()?.fcmToken;

    if (!fcmToken) continue;

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "Time Capsule",
        body: message,
      },
    });
  }
}

export const timeCapsuleReminders = onSchedule(
  {
    schedule: "every day 09:00",
    timeZone: "Europe/Kyiv",
  },
  async () => {
    await sendUnlockReminders(7, "A letter unlocks in one week!");
    await sendUnlockReminders(1, "A letter unlocks tomorrow!");
  }
);
