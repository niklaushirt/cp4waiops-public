const express = require('express');
const bodyParser = require('body-parser');
const processing = require("./processing.js");

const router = express.Router();

const iterateElement = process.env.ITERATE_ELEMENT || "events"
const nodeElement = process.env.NODE_ELEMENT || "kubernetes.container_name"
const alertgroupElement = process.env.ALERT_ELEMENT || "kubernetes.namespace_name"
const summaryElement = process.env.SUMMARY_ELEMENT || "@rawstring"
const timestampElement = process.env.TIMESTAMP_ELEMENT || "override_with_date"
const urlElement = process.env.URL_ELEMENT || "none"
const severityElement = process.env.SEVERITY_ELEMENT || "5"
const managerElement = process.env.MANAGER_ELEMENT || "KafkaWebhook"
const kafkaBroker = process.env.KAFKA_BROKER || "kafka1:9092"
const kafkaUser = process.env.KAFKA_USER || "cp4waiops-cartridge-kafka-auth"
const kafkaPWD = process.env.KAFKA_PWD || "CHANGEME"
const kafkaTopicEvents = process.env.KAFKA_TOPIC_EVENTS || "cp4waiops-cartridge-alerts-noi-CREATE-NOI-INTEGRATION"
const kafkaTopicLogs = process.env.KAFKA_TOPIC_LOGS || "cp4waiops-cartridge-logs-CREATE-NOI-INTEGRATION"
const token = process.env.TOKEN || ""

global.token = ""
global.loggedin = false

function render_with_token(req, res, page, parameters) {
  if (global.loggedin == true) {
    res.render(page, parameters);
  } else {
    res.render('login', {});
  }
}


//**************************************************************************************************
// Basic Functions
//**************************************************************************************************
router.get("/", function (req, res) {
  render_with_token(req, res, 'index', {});
});


router.get("/login", function (req, res) {
  //global.loggedin = true
  if (req.query.token == token) {
    global.loggedin = true
    console.log("   ✅ LOGGED IN", req.query);
    render_with_token(req, res, 'index', {});
  } else {
    global.loggedin = false
    console.log("   ❌ LOGIN REFUSED", req.query);
    res.render('error', {});
  }
});


router.get("/config", function (req, res) {
  render_with_token(req, res, 'config', {
    iterateElement: iterateElement,
    nodeElement: nodeElement,
    alertgroupElement: alertgroupElement,
    summaryElement: summaryElement,
    urlElement: urlElement,
    severityElement: severityElement,
    timestampElement: timestampElement,
    kafkaBroker: kafkaBroker,
    kafkaUser: kafkaUser,
    kafkaPassword: "**PROVIDED**",
    kafkaTopicEvents: kafkaTopicEvents,
    kafkaTopicLogs: kafkaTopicLogs,
    token: token
  });
});


router.get("/about", function (req, res) {
  render_with_token(req, res, 'about');
});


router.get("/deployment", function (req, res) {
  render_with_token(req, res, 'deployment');
});




//**************************************************************************************************
// Specific APIs
//**************************************************************************************************
//**************************************************************************************************
// GET - Secured through Web UI
//**************************************************************************************************

router.get("/webhook", function (req, res) {
  render_with_token(req, res, 'webhook', {});
});


//**************************************************************************************************
// POST - Secured through TOKEN
//**************************************************************************************************

router.post("/webhook", function (req, res) {
  if (req.headers.token == token) {

    console.log("  **************************************************************************************************");
    console.log("   📛 Received Payload");
    //console.log(req.body);
    processing.parse_payload(req.body)
    res.sendStatus(200);
  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.sendStatus(401);
  }

});



module.exports = router;