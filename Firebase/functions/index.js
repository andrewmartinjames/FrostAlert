const functions = require("firebase-functions");
const {Firestore} = require("@google-cloud/firestore");
const admin = require("firebase-admin");
const firestore = new Firestore();
admin.initializeApp();

exports.newUser = functions.auth.user().onCreate((user) => {
  // ...
  const uid = user.uid;
  const docRef = firestore.collection("users");
  const document = docRef.doc(uid);
  console.log(uid);
  document.set({
    uid: uid,
    endpoint: "/endpoints/",
    threshold_temp: 2.0,
    fcm_token: "",
  });
});

// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
