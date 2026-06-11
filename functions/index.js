const { onValueWritten } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

exports.onUserStateChange = onValueWritten(
    { ref: '/{uid}/active' },
    async (event) => {
        try {
            const isActive = event.data.after.val();
            const uid = event.params.uid;

            if (isActive === undefined) {
                console.error("No value found for 'active' in Realtime Database.");
                return;
            }

            const firestoreRef = firestore.doc(`users/${uid}`);

            await firestoreRef.update({
                active: isActive,
                lastSeen: Date.now(),
            });

            console.log(`Firestore updated for user ${uid}: { active: ${isActive}, lastSeen: ${Date.now()} }`);
        } catch (error) {
            console.error("Error updating Firestore:", error);
        }
    }
);
