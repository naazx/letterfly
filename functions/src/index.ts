import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

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
