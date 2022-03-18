const kafkaBroker = process.env.KAFKA_BROKER || "kafka1:9092"
const kafkaUser = process.env.KAFKA_USER || "cp4waiops-cartridge-kafka-auth"
const kafkaPWD = process.env.KAFKA_PWD || "CHANGEME"
const kafkaTopicEvents = process.env.KAFKA_TOPIC_EVENTS || "cp4waiops-cartridge-alerts-noi-CREATE-NOI-INTEGRATION"
const kafkaTopicLogs = process.env.KAFKA_TOPIC_LOGS || "cp4waiops-cartridge-alerts-noi-CREATE-NOI-INTEGRATION"
const fs = require('fs')


const {
    Kafka, logLevel
} = require('kafkajs')

const kafka = new Kafka({
    clientId: 'my-app',
    brokers: [kafkaBroker],
    ssl: {
        rejectUnauthorized: false,
        ca: [fs.readFileSync('./ca.crt', 'utf-8')]
      },
    sasl: {
        mechanism: 'scram-sha-512', // scram-sha-256 or scram-sha-512
        username: kafkaUser,
        password: kafkaPWD
    },
    requestTimeout: 25000,
    connectionTimeout: 3000,
    logLevel: logLevel.ERROR
})

const producer = kafka.producer()
producer.logger().setLogLevel(logLevel.ERROR)





function sendToKafkaEvent(kafkaMessage) {
    console.log("             📥 Send to Kafka");
    console.log("");
    console.log(`             ${kafkaMessage}`);
    console.log("");

    // Producing
    console.log(`              Connect to Kafka`);
    producer.connect()

    const run = async () => {
        // Producing
        console.log(`              Send to Kafka`);

        await producer.connect()
        await producer.send({
            topic: kafkaTopicEvents,
            messages: [{
                value: kafkaMessage
            } ]
        })
      }
      run().catch(console.error)
}





function sendToKafkaLog(kafkaMessage) {
    producer.connect()

    const run = async () => {
        // Producing
        // console.log(`              Send to Kafka`);
        await producer.connect()
        await producer.send({
            topic: kafkaTopicLogs,
            messages: [{
                value: kafkaMessage
            } ]
        })
      }
      run().catch(console.error)
}



module.exports = {
    sendToKafkaEvent,
    sendToKafkaLog
};