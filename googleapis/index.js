const express = require("express");
const cors = require("cors");
const axios = require("axios").default;
const { v4 } = require("uuid");

const app = express();
app.use(cors());
const PORT = 4000;
const apiKey = "AIzaSyCHySMHG-mV2kq1pYGqgw2B6OAK-9xbOxk";

app.get("/autocomplete", async (req, res) => {
  try {
    let url = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${
      req.query.place
    }&key=${apiKey}&sessiontoken=${v4()}`;
    let data = await axios.get(url);
    res.send(data.data);
  } catch (e) {
    res.send(e.toString());
  }
});

app.get("/decode", async (req, res) => {
  try {
    let url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${req.query.placeID}&key=${apiKey}`;
    let data = await axios.get(url);
    res.send(data.data);
  } catch (e) {
    res.send(e.toString());
  }
});

app.get("/getaddress", async (req, res) => {
  try {
    let url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${req.query.placeID}&key=${apiKey}`;
    let data = await axios.get(url);
    res.send(data.data);
  } catch (e) {
    res.send(e.toString());
  }
});

app.listen(PORT, () => {
  console.log("Running");
});
