const functions = require("firebase-functions");
const { WebhookClient } = require("dialogflow-fulfillment");

// Enable this for better logs when deploying
process.env.DEBUG = 'dialogflow:debug';

exports.dialogflowFirebaseFulfillment = functions.https.onRequest((request, response) => {
  const agent = new WebhookClient({ request, response });

  // 🧠 Intents and Responses Mapping
  const intentMap = new Map();

  intentMap.set("ডেঙ্গু হলে মাথা ব্যথা হয়?", (agent) => {
    agent.add("হ্যাঁ, ডেঙ্গু হলে মাথা, চোখের পেছনে ও শরীরে ব্যথা হতে পারে।");
  });

  intentMap.set("ডেঙ্গু গুরুতর হলে কি হয়?", (agent) => {
    agent.add("ডেঙ্গু গুরুতর হলে রক্তক্ষরণ, শ্বাসকষ্ট বা শরীরের অঙ্গ বিকল হতে পারে। এমন পরিস্থিতিতে দ্রুত হাসপাতালে যেতে হবে।");
  });

  intentMap.set("ডেঙ্গু চিকিৎসা ও খরচ কেমন", (agent) => {
    agent.add("সরকারি হাসপাতালে সাধারণত খরচ খুবই কম বা বিনামূল্যে চিকিৎসা হয়। তবে গুরুতর হলে বেসরকারি হাসপাতালে চিকিৎসা ব্যয়বহুল হতে পারে।");
  });

  intentMap.set("ডেঙ্গু হলে কি ওষুধ খেতে হবে?", (agent) => {
    agent.add("প্যারাসিটামল খাওয়া যায় জ্বর কমাতে, তবে ডাক্তারের পরামর্শ ছাড়া অন্য ওষুধ নয়।");
  });

  intentMap.set("ডেঙ্গু থেকে বাঁচার উপায় জানাবেন?", (agent) => {
    agent.add("মশার কামড় থেকে বাঁচুন, পানি জমতে দেবেন না এবং মশারি ব্যবহার করুন।");
  });

  intentMap.set("ডেঙ্গুতে কোন লক্ষণ দেখা দিলে হাসপাতালে যেতে হবে?", (agent) => {
    agent.add("তীব্র পেট ব্যথা, রক্তক্ষরণ, শ্বাসকষ্ট, বা অবচেতন হলে সাথে সাথে হাসপাতালে যান।");
  });

  intentMap.set("ডেঙ্গু হলে কখন ডাক্তার দেখানো দরকার?", (agent) => {
    agent.add("জ্বর ৩ দিনের বেশি থাকলে, তীব্র ব্যথা বা রক্তক্ষরণ হলে ডাক্তার দেখানো দরকার।");
  });

  agent.handleRequest(intentMap);
});
