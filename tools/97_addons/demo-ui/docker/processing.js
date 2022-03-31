const kafka = require("./kafka");
const dateFormat = require('dateformat');
var https = require("https");


var options = {
  host: 'www.google.com',
  port: 80,
  path: '/upload',
  method: 'POST'
};


function parse_demo_event() {

  const iterateElement = "events"
  const nodeElement = "Node"
  const nodeAliasElement = "NodeAlias"
  const alertgroupElement = "AlertGroup"
  const summaryElement = "Summary"
  const timestampElement = "override_with_date"
  const urlElement = "URL"
  const severityElement = "Severity"
  const managerElement = "Manager"
  const payload = process.env.DEMO_EVENTS || "{}"



  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 Generating Demo Events from Config Map");

    // console.log("  **************************************************************************************************");
    // console.log("   ⏳ Decode Payload");

    const obj = JSON.parse(payload);

    // console.log("  **************************************************************************************************");
    // console.log("   🌏 Fields to iterate over");
    const iterateObj = obj[iterateElement]
    // console.log(iterateObj);
    // console.log("  **************************************************************************************************");
    // console.log("  **************************************************************************************************");
    // console.log("");
    // console.log("");
    // console.log("");
    // console.log("");

    var kafkaMessage = ""
    var dateFull = Date.now();

    for (var actElement in iterateObj) {

      dateFull = dateFull + 1000;

      var objectToIterate = iterateObj[actElement]

      var actNodeElement = objectToIterate[nodeElement] || nodeElement;
      var actNodeAliasElement = objectToIterate[nodeAliasElement] || nodeAliasElement;
      var actAlertgroupElement = objectToIterate[alertgroupElement] || alertgroupElement;
      var actSummaryElement = objectToIterate[summaryElement] || summaryElement;
      var actUrlElement = objectToIterate[urlElement] || urlElement;
      var actManagerElement = objectToIterate[managerElement] || managerElement;
      var actSeverityElement = objectToIterate[severityElement] || severityElement;
      var actTimestampElement = objectToIterate[timestampElement] || dateFull;
      var formattedTimestamp = `${actTimestampElement}`.substring(0, 10);


      // console.log("");
      // console.log("");
      // console.log("");
      // console.log("    **************************************************************************************************");
      // console.log("    **************************************************************************************************");
      // console.log("     🎯 Found Element");
      // console.log("    **************************************************************************************************");
      // console.log(`         📥 Node:        ${actNodeElement}`);
      // console.log(`         📥 NodeAlias    ${actNodeAliasElement}`);
      // console.log(`         🚀 AlertGroup:  ${actAlertgroupElement}`);
      // console.log(`         📙 Summary:     ${actSummaryElement}`);
      // console.log(`         🌏 URL:         ${actUrlElement}`);
      // console.log(`         🌏 Manager:     ${actManagerElement}`);
      // console.log(`         🎲 Severity:    ${actSeverityElement}`);
      // console.log(`         🕦 Timestamp:   ${formattedTimestamp}`);
      // console.log("        *************************************************************************************************");
      // console.log("");
      console.log(`         📥 Event:     ${actNodeElement}:${actSummaryElement}`);

      actKafkaLine = `{"EventId": "","Node": "${actNodeElement}","NodeAlias": "${actNodeElement}","Manager": "${actManagerElement}","Agent": "${actManagerElement}","Summary": "${actSummaryElement}","FirstOccurrence": "${formattedTimestamp}","LastOccurrence": "${formattedTimestamp}","AlertGroup": "${actAlertgroupElement}","AlertKey": "","Type": 1,"Location": "","Severity": ${actSeverityElement},"URL": "${actUrlElement}","NetcoolEventAction": "insert"}`
      kafka.sendToKafkaEvent(actKafkaLine)
    }
    //console.log("**************************************************************************************************");
  } catch (ex) {
    console.log(ex);
  }
}





function closeStories() {

  const dlRoute = process.env.DATALAYER_ROUTE ||   "https://ibm.com"
  const dlAuth = process.env.USER_PASS ||   "https://ibm.com"


  console.log(`         🌏 ROUTE  ${dlRoute}`);
  console.log(`         🌏 AUTH   ${dlAuth}`);
  // curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/stories" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "resolved"}' -H 'Content-Type: application/json' 
  // -H "x-username:admin" 
  // -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" 

  var options = {
    host: dlRoute,
    port: 443,
    path: '/irdatalayer.aiops.io/active/v1/stories',
    method: 'PATCH',
    auth: dlAuth,
    headers: {
      'Content-Type': 'application/json',
      'x-username' : 'admin',
      'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'
    },
    "json": {"state": "resolved"}
  };

  var req = https.request(options, function(res) {
    console.log('STATUS: ' + res.statusCode);
    //console.log('HEADERS: ' + JSON.stringify(res.headers));
    res.setEncoding('utf8');
    res.on('data', function (chunk) {
      console.log('BODY: ' + chunk);
    });
  });
  
  req.on('error', function(e) {
    console.log('problem with request: ' + e.message);
  });
  
  // write data to request body
  req.write('{"state": "resolved"}\n');
  req.end();

  try {
    console.log("   📛 Close Stories");
    console.log("  **************************************************************************************************");

  } catch (ex) {
    console.log(ex);
  }
}


function closeAlerts() {

  const dlRoute = process.env.DATALAYER_ROUTE ||   "https://ibm.com"
  const dlAuth = process.env.USER_PASS ||   "https://ibm.com"


  console.log(`         🌏 ROUTE  ${dlRoute}`);
  console.log(`         🌏 AUTH   ${dlAuth}`);
  // curl "https://$DATALAYER_ROUTE/irdatalayer.aiops.io/active/v1/stories" --insecure --silent -X PATCH -u "${USER_PASS}" -d '{"state": "resolved"}' -H 'Content-Type: application/json' 
  // -H "x-username:admin" 
  // -H "x-subscription-id:cfd95b7e-3bc7-4006-a4a8-a73a79c71255" 

  var options = {
    host: dlRoute,
    port: 443,
    path: '/irdatalayer.aiops.io/active/v1/alerts?filter=type.classification%20%3D%20%27robot-shop%27',
    method: 'PATCH',
    auth: dlAuth,
    headers: {
      'Content-Type': 'application/json',
      'x-username' : 'admin',
      'x-subscription-id' : 'cfd95b7e-3bc7-4006-a4a8-a73a79c71255'
    },
    "json": {"state": "closed"}
  };

  var req = https.request(options, function(res) {
    console.log('STATUS: ' + res.statusCode);
    //console.log('HEADERS: ' + JSON.stringify(res.headers));
    res.setEncoding('utf8');
    res.on('data', function (chunk) {
      console.log('BODY: ' + chunk);
    });
  });
  
  req.on('error', function(e) {
    console.log('problem with request: ' + e.message);
  });
  
  // write data to request body
  req.write('{"state": "closed"}\n');
  req.end();

  try {
    console.log("   📛 Close Alerts");
    console.log("  **************************************************************************************************");

  } catch (ex) {
    console.log(ex);
  }
}



function parse_demo_log() {

  const iterateElement = "logs"
  const payload = process.env.DEMO_LOGS || "{}"
  const iterations = process.env.LOG_ITERATIONS || "5"
  const timeFormat = process.env.LOG_TIME_FORMAT ||   "yyyy-mm-dd'T'HH:MM:ss.000000+00:00"
  const timeSteps = process.env.LOG_TIME_STEPS ||   "1"
  const timeSkew = process.env.LOG_TIME_SKEW ||   "60"
  const timeZone = process.env.LOG_TIME_ZONE ||   "-1"
  
  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 Generating Demo Log Anomalies from Config Map");


    closeStories();
    closeAlerts();

    var kafkaMessage = ""
    //var dateFull = new Date().toISOString();
    //
    // 2022-03-08T17:41:56.000000+00:00
    //"yyyy-mm-ddTh:MM:ss.000000+00:00"
    //    
    //var dateFull=dateFormat(now, "isoDateTime");
    var now = new Date();
    //Add Skew in seconds
    var parsedDate = new Date(Date.parse(now))
    console.log(`         🕦 Now                  ${parsedDate}`);

    now = new Date(parsedDate.getTime() + (1000 * 60 * 60 * timeZone))
    parsedDate = new Date(Date.parse(now))
    console.log(`         🕦 Adjusted TZ          ${parsedDate}`);

    now = new Date(parsedDate.getTime() + (1000 * timeSkew))
    parsedDate = new Date(Date.parse(now))
    console.log(`         🕦 Adjusted Skew        ${parsedDate}`);

    var dateFull=dateFormat(now,timeFormat);
    console.log(`         🕦 Date Formatted       ${dateFull}`);

    for (let step = 0; step < iterations; step++) {

      var array = payload.toString().split("\n");
      for (i in array) {

        // Add step time in ms
        now = new Date(parsedDate.getTime() + (1000*timeSteps))
        parsedDate = new Date(Date.parse(now))
        //console.log(`         🕦 Adjusted Step   ${parsedDate}`);


        dateFull=dateFormat(now,timeFormat);

        //console.log(`         💚 DATE ${dateFull}`);

        var objectToIterate = array[i]
        actKafkaLine = objectToIterate.replace("MY_TIMESTAMP", dateFull)

        kafka.sendToKafkaLog(actKafkaLine)

      }
      console.log(`         📥 Logs:     Injected ${i} Log Lines at ${parsedDate}`);

    }
  } catch (ex) {
    console.log(ex);
  }
}




function parse_demo_log_rsa() {

  const payload = process.env.DEMO_LOGS_RSA || "{}"
  const iterations = 1
  let sleep = require('util').promisify(setTimeout);

  try {
    console.log("  **************************************************************************************************");
    console.log("   📛 Generating Demo Log RSA Anomalies from Config Map");

    var kafkaMessage = ""
    var dateFull = Date.now();

    for (let step = 0; step < iterations; step++) {

      var array = payload.toString().split("\n");
      for (i in array) {

        dateFull = dateFull + 1000;
        var objectToIterate = array[i]
        var actTimestampElement = dateFull;
        var formattedTimestamp = `${actTimestampElement}`.substring(0, 10);
        actKafkaLine = objectToIterate.replace("MY_TIMESTAMP", formattedTimestamp)
        //console.log(`         📥 Logs:     Injected ${i} Log Line`,actKafkaLine);

        kafka.sendToKafkaLogAsync(actKafkaLine)

      }
      console.log(`         📥 Logs:     Injected ${i} Log Lines`);



    }
  } catch (ex) {
    console.log(ex);
  }
}







module.exports = {
  parse_demo_event,
  parse_demo_log,
  parse_demo_log_rsa
};