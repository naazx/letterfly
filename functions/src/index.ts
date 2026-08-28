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

    const rawText: string = letter.text ?? "You've received a new letter";
    const body = rawText.length > 100 ?
      rawText.slice(0, 100) + "..." :
      rawText;

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: letter.subject ?? "New letter!",
        body: body,
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


/**
 * Computes the next real occurrence of a pair event, handling
 * recurring events the same way the Swift client does.
 * @param {Date} date - Original event date.
 * @param {boolean} isRecurring - Whether the event repeats yearly.
 * @return {Date} The next real occurrence date.
 */
function nextOccurrence(date: Date, isRecurring: boolean): Date {
  if (!isRecurring) return date;

  const now = new Date();
  const thisYearDate = new Date(date);
  thisYearDate.setFullYear(now.getFullYear());

  if (thisYearDate < now) {
    thisYearDate.setFullYear(now.getFullYear() + 1);
  }

  return thisYearDate;
}

export const pairEventReminders = onSchedule(
  {
    schedule: "every day 09:00",
    timeZone: "Europe/Kyiv",
  },
  async () => {
    const snapshot = await admin.firestore()
      .collectionGroup("events")
      .get();

    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);

    for (const doc of snapshot.docs) {
      const event = doc.data();
      const occurrence = nextOccurrence(
        event.date.toDate(),
        event.isRecurring
      );

      const isSameDay =
        occurrence.getFullYear() === tomorrow.getFullYear() &&
        occurrence.getMonth() === tomorrow.getMonth() &&
        occurrence.getDate() === tomorrow.getDate();

      if (!isSameDay) continue;

      const pairID = doc.ref.parent.parent?.id;
      if (!pairID) continue;

      const pairDoc = await admin.firestore()
        .collection("pairs").doc(pairID).get();
      const members: string[] = pairDoc.data()?.members ?? [];

      for (const memberID of members) {
        const memberDoc = await admin.firestore()
          .collection("users").doc(memberID).get();
        const fcmToken = memberDoc.data()?.fcmToken;

        if (!fcmToken) continue;

        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: "Upcoming event",
            body: `${event.title} is tomorrow!`,
          },
        });
      }
    }
  }
);

/**
 * Checks whether any letter was created today for a given pair.
 * @param {string} pairID - The pair document ID.
 * @return {Promise<boolean>} True if at least one letter exists today.
 */
async function hasLetterToday(pairID: string): Promise<boolean> {
  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);

  const endOfDay = new Date();
  endOfDay.setHours(23, 59, 59, 999);

  const snapshot = await admin.firestore()
    .collection("pairs").doc(pairID).collection("letters")
    .where("createdAt", ">=", startOfDay)
    .where("createdAt", "<=", endOfDay)
    .limit(1)
    .get();

  return !snapshot.empty;
}

export const dailyWriteReminder = onSchedule(
  {
    schedule: "every day 21:00",
    timeZone: "Europe/Kyiv",
  },
  async () => {
    const pairsSnapshot = await admin.firestore()
      .collection("pairs").get();

    for (const pairDoc of pairsSnapshot.docs) {
      const pairID = pairDoc.id;
      const wroteToday = await hasLetterToday(pairID);

      if (wroteToday) continue;

      const members: string[] = pairDoc.data().members ?? [];

      for (const memberID of members) {
        const memberDoc = await admin.firestore()
          .collection("users").doc(memberID).get();
        const fcmToken = memberDoc.data()?.fcmToken;

        if (!fcmToken) continue;

        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: "Don't forget to write!",
            body: "You haven't sent a letter today.",
          },
        });
      }
    }
  }
);
