const admin = require("firebase-admin");
const express = require("express");
const functions = require('firebase-functions');

admin.initializeApp();

const app = express();

app.use(express.json());

app.get("/onNewBooking", (req, res) => {
  const allQueryStrings = req.query;
  const DATA = {
    notification: {
      body: allQueryStrings["body"],
      title: "New Booking",
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      orderID: allQueryStrings["orderID"],
    },
  };
  admin
    .messaging()
    .sendToDevice(allQueryStrings["token"], DATA)
    .then((response) => {
      res.send(JSON.stringify(response));
    })
    .catch((error) => {
      res.send(JSON.stringify(error));
    });
});

app.get("/sendToTopic", (req, res) => {
  const allQueryStrings = req.query;
  const DATA = {
    notification: {
      body: allQueryStrings["body"],
      title: allQueryStrings["title"],
    },
  };
  admin
    .messaging()
    .sendToTopic(allQueryStrings["topic"], DATA)
    .then((response) => {
      res.send(JSON.stringify(response));
    })
    .catch((error) => {
      res.send(JSON.stringify(error));
    });
});

app.get("/onOrderComplete", (req, res) => {
  const allQueryStrings = req.query;
  const DATA = {
    notification: {
      body: allQueryStrings["body"],
      title: "Order Delivered Successfully",
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      orderID: allQueryStrings["orderID"],
    },
  };
  admin
    .messaging()
    .sendToDevice(allQueryStrings["token"], DATA)
    .then((response) => {
      res.send(JSON.stringify(response));
    })
    .catch((error) => {
      res.send(JSON.stringify(error));
    });
});

exports.app = functions.https.onRequest(app);