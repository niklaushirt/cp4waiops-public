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
const iterateElement = process.env.ITERATE_ELEMENT || "events"
const nodeElement = process.env.NODE_ELEMENT || "kubernetes.container_name"
const alertgroupElement = process.env.ALERT_ELEMENT || "kubernetes.namespace_name"
const summaryElement = process.env.SUMMARY_ELEMENT || "@rawstring"
const timestampElement = process.env.TIMESTAMP_ELEMENT || "override_with_date"
const urlElement = process.env.URL_ELEMENT || "none"
const severityElement = process.env.SEVERITY_ELEMENT || "5"
const managerElement = process.env.MANAGER_ELEMENT || "KafkaWebhook"


global.logs=true

app.use(bodyParser.json());

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.static(path.join(__dirname, 'public')));


// Set port
const port = process.env.PORT || "8080";
app.set("port", port);

app.use('/', routes);

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
console.log("    🛰️ Generic Webhook2Events Gateway - Push WebHook Events to CP4WAIOPS AI Manager");
console.log("");
console.log("       Provided by:");
console.log("        🇨🇭 Niklaus Hirt (nikh@ch.ibm.com)");
// Server
app.listen(port, () => console.log(`     🚀 Server running on localhost:${port}`));
console.log("*************************************************************************************************");
console.log("*************************************************************************************************");
console.log("");
console.log("    **************************************************************************************************");
console.log("     🎯 Mapping Parameters");
console.log("    **************************************************************************************************");

console.log(`         ♻️  Iterate Over:  ${iterateElement}`);
console.log(`         📥 Node:          ${nodeElement}`);
console.log(`         🚀 AlertGroup:    ${alertgroupElement}`);
console.log(`         📙 Summary:       ${summaryElement}`);
console.log(`         🌏 URL:           ${urlElement}`);
console.log(`         🎲 Severity:      ${severityElement}`);
console.log(`         🕦 Timestamp:     ${timestampElement}`);

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
console.log("    **************************************************************************************************");


