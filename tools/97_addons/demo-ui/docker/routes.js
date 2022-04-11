const express = require('express');
const bodyParser = require('body-parser');
const processing = require("./processing.js");

const router = express.Router();

const kafkaBroker = process.env.KAFKA_BROKER || "kafka1:9092"
const kafkaUser = process.env.KAFKA_USER || "cp4waiops-cartridge-kafka-auth"
const kafkaPWD = process.env.KAFKA_PWD || "CHANGEME"
const kafkaTopicEvents = process.env.KAFKA_TOPIC_EVENTS || "cp4waiops-cartridge-alerts-noi-CREATE-NOI-INTEGRATION"
const kafkaTopicLogs = process.env.KAFKA_TOPIC_LOGS || "cp4waiops-cartridge-logs-CREATE-NOI-INTEGRATION"
const iterations = process.env.LOG_ITERATIONS || "5"
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
    kafkaBroker: kafkaBroker,
    kafkaUser: kafkaUser,
    kafkaPassword: "**PROVIDED**",
    kafkaTopicEvents: kafkaTopicEvents,
    kafkaTopicLogs: kafkaTopicLogs,
    iterations: iterations,
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

router.get("/demo_doc", function (req, res) {
  render_with_token(req, res, 'demo_doc');
});


router.get("/demo", function (req, res) {
  if (global.loggedin == true) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Events and Log Anomalies");
    //console.log(req.body);
    processing.parse_demo_event()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    processing.parse_demo_log()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.render('done', {});
  } else {
    console.log("   ❌ OPERATION REFUSED", req.query);
    res.render('login', {});
  }
});


router.get("/demo_event", function (req, res) {
  if (global.loggedin == true) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Events");
    //console.log(req.body);
    processing.parse_demo_event()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.render('done', {});
  } else {
    console.log("   ❌ OPERATION REFUSED", req.query);
    res.render('login', {});
  }

});


router.get("/demo_log", function (req, res) {
  if (global.loggedin == true) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Log Anomalies");
    //console.log(req.body);
    processing.parse_demo_log()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.render('done', {});
  } else {
    console.log("   ❌ OPERATION REFUSED", req.query);
    res.render('login', {});
  }

});



//**************************************************************************************************
// POST - Secured through TOKEN
//**************************************************************************************************

router.post("/demo", function (req, res) {
  if (req.headers.token == token) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Events and Log Anomalies");
    //console.log(req.body);
    processing.parse_demo_event()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    processing.parse_demo_log()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.sendStatus(200);
  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.sendStatus(401);
  }

});


router.post("/demo_event", function (req, res) {
  if (req.headers.token == token) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Events");
    //console.log(req.body);
    processing.parse_demo_event()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.sendStatus(200);
  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.sendStatus(401);
  }

});


router.post("/demo_log", function (req, res) {
  if (req.headers.token == token) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Log Anomalies");
    //console.log(req.body);
    processing.parse_demo_log()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.sendStatus(200);
  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.sendStatus(401);
  }

});



router.post("/demo_log_rsa", function (req, res) {
  if (req.headers.token == token) {
    console.log("  **************************************************************************************************");
    console.log("   🚀 Starting Demo: Log Anomalies RSA");
    //console.log(req.body);
    processing.parse_demo_log_rsa()
    console.log("   ✅ Done");
    console.log("  **************************************************************************************************");

    res.sendStatus(200);
  } else {
    console.log("   ❌ OPERATION REFUSED for Token:", req.headers.token);
    res.sendStatus(401);
  }

});



module.exports = router;