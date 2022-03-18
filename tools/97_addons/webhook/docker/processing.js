const kafka = require("./kafka");



function parse_payload(payload) {

  const iterateElement = process.env.ITERATE_ELEMENT || "events"
  const nodeElement = process.env.NODE_ELEMENT || "kubernetes.container_name"
  const nodeAliasElement = process.env.NODEALIAS_ELEMENT || "kubernetes.container_name"
  const alertgroupElement = process.env.ALERT_ELEMENT || "kubernetes.namespace_name"
  const summaryElement = process.env.SUMMARY_ELEMENT || "@rawstring"
  const timestampElement = process.env.TIMESTAMP_ELEMENT || "override_with_date"
  const urlElement = process.env.URL_ELEMENT || "none"
  const severityElement = process.env.SEVERITY_ELEMENT || "5"
  const managerElement = process.env.MANAGER_ELEMENT || "KafkaWebhook"


  try {
    console.log("  **************************************************************************************************");
    console.log("   ⏳ Decode Payload");

    const stringyJSON = JSON.stringify(payload);
    const obj = JSON.parse(stringyJSON);

    console.log("  **************************************************************************************************");
    console.log("   🌏 Fields to iterate over");
    const iterateObj = obj[iterateElement]
    console.log(iterateObj);
    console.log("  **************************************************************************************************");
    console.log("  **************************************************************************************************");
    console.log("");
    console.log("");
    console.log("");
    console.log("");

    var kafkaMessage = ""

    for (var actElement in iterateObj) {

      var objectToIterate = iterateObj[actElement]
      var actNodeElement = objectToIterate[nodeElement] || nodeElement;
      var actNodeAliasElement = objectToIterate[nodeAliasElement] || nodeAliasElement;
      var actAlertgroupElement = objectToIterate[alertgroupElement] || alertgroupElement;
      var actSummaryElement = objectToIterate[summaryElement] || summaryElement;
      var actUrlElement = objectToIterate[urlElement] || urlElement;
      var actManagerElement = objectToIterate[managerElement] || managerElement;
      var actSeverityElement = objectToIterate[severityElement] || severityElement;
      var dateFull = Date.now();
      var actTimestampElement = objectToIterate[timestampElement] || dateFull;
      var formattedTimestamp = `${actTimestampElement}`.substring(0, 10);

      console.log("");
      console.log("");
      console.log("");
      console.log("    **************************************************************************************************");
      console.log("    **************************************************************************************************");
      console.log("     🎯 Found Element");
      console.log("    **************************************************************************************************");
      console.log(`         📥 Node:        ${actNodeElement}`);
      console.log(`         📥 NodeAlias    ${actNodeAliasElement}`);
      console.log(`         🚀 AlertGroup:  ${actAlertgroupElement}`);
      console.log(`         📙 Summary:     ${actSummaryElement}`);
      console.log(`         🌏 URL:         ${actUrlElement}`);
      console.log(`         🌏 Manager:     ${actManagerElement}`);
      console.log(`         🎲 Severity:    ${actSeverityElement}`);
      console.log(`         🕦 Timestamp:   ${formattedTimestamp}`);
      console.log("        *************************************************************************************************");
      console.log("");

      actKafkaLine = `{"EventId": "","Node": "${actNodeElement}","NodeAlias": "${actNodeElement}","Manager": "${actManagerElement}","Agent": "${actManagerElement}","Summary": "${actSummaryElement}","FirstOccurrence": "${formattedTimestamp}","LastOccurrence": "${formattedTimestamp}","AlertGroup": "${actAlertgroupElement}","AlertKey": "","Type": 1,"Location": "","Severity": ${actSeverityElement},"URL": "${actUrlElement}","NetcoolEventAction": "insert"}`
      kafka.sendToKafkaEvent(actKafkaLine)

    }
    console.log("**************************************************************************************************");
  } catch (ex) {
    console.log(ex);
  }
}








module.exports = {
  parse_payload
};