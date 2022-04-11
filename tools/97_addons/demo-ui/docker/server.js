const express = require("express");
const routes = require("./routes");
const bodyParser = require('body-parser');

var path = require('path');

// App
const app = express();

const kafkaBroker = process.env.KAFKA_BROKER || "kafka1:9092"
const kafkaUser = process.env.KAFKA_USER || "cp4waiops-cartridge-kafka-auth"
const kafkaPWD = process.env.KAFKA_PWD || "CHANGEME"
const kafkaTopicEvents = process.env.KAFKA_TOPIC_EVENTS || "cp4waiops-cartridge-alerts-noi-CREATE-NOI-INTEGRATION"
const kafkaTopicLogs = process.env.KAFKA_TOPIC_LOGS || "cp4waiops-cartridge-logs-CREATE-NOI-INTEGRATION"
const iterations = process.env.LOG_ITERATIONS || "5"
const token = process.env.TOKEN || ""
const timeFormat = process.env.LOG_TIME_FORMAT ||   "yyyy-mm-dd'T'HH:MM:ss.000000+00:00"
const timeSteps = process.env.LOG_TIME_STEPS ||   "1000"
const timeSkew = process.env.LOG_TIME_SKEW ||   "60"
const timeZone = process.env.LOG_TIME_ZONE ||   "-1"
const dlRoute = process.env.DATALAYER_ROUTE ||   "https://ibm.com"
const dlAuth = process.env.USER_PASS ||   "https://ibm.com"




global.logs=true

app.use(bodyParser.json());

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.static(path.join(__dirname, 'public')));


// Set port
const port = process.env.PORT || "8080";
app.set("port", port);

app.use('/', routes);

//app.use(bodyParser.urlencoded({ extended: false }));
// parse application/json
//app.use(bodyParser.json())

// parse application/vnd.api+json as json
//app.use(bodyParser.json({ type: 'application/vnd.api+json' }))
app.use(bodyParser.urlencoded({limit: '5000mb', extended: true, parameterLimit: 100000000000}));

console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("         __________  __ ___       _____    ________            ");
console.log("        / ____/ __ \\/ // / |     / /   |  /  _/ __ \\____  _____");
console.log("       / /   / /_/ / // /| | /| / / /| |  / // / / / __ \\/ ___/");
console.log("      / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) ");
console.log("      \\____/_/      /_/  |__/|__/_/  |_/___/\\____/ .___/____/  ");
console.log("                                                /_/            ");
console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("");
console.log("    🛰️ DemoUI for CP4WAIOPS AI Manager");
console.log("");
console.log("       Provided by:");
console.log("        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)");
console.log("");
// Server
app.listen(port, () => console.log(`     🚀 Server running on localhost:${port}`));
console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("");
console.log("    **************************************************************************************************");
console.log("     🔎 KAFKA Parameters");
console.log("    **************************************************************************************************");

console.log(`           KafkaBroker:        ${kafkaBroker}`);
console.log(`           KafkaUser:          ${kafkaUser}`);
console.log(`           KafkaPWD:           ${kafkaPWD}`);
console.log(`           KafkaTopic Events:  ${kafkaTopicEvents}`);
console.log(`           KafkaTopic Logs:    ${kafkaTopicLogs}`);
console.log("");
console.log(`           Log Iterations:     ${iterations}`);
console.log("");
console.log(`           Logs Time Format:   ${timeFormat}`);
console.log(`           Logs Time Step:     ${timeSteps}`);
console.log(`           Logs Time Skew:     ${timeSkew}`);
console.log(`           Logs Time Zone:     ${timeZone}`);
console.log("");
console.log(`           Datalayer Route:    ${dlRoute}`);
console.log(`           Datalayer AUTH:     ${dlAuth}`);

console.log("");

console.log(`           Token:              ${token}`);
console.log("");
console.log("    **************************************************************************************************");


