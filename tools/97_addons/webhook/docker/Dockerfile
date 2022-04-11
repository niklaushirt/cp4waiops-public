FROM node:14-alpine


WORKDIR /app
ENV NODE_ENV production

COPY catpl.crt ca.crt
RUN chmod 777 ca.crt

COPY ssh-startup.sh ssh-startup.sh
RUN chmod +x ssh-startup.sh

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY package.json package.json
RUN npm install


USER nextjs

COPY public ./public
COPY views ./views

COPY *.js .


ENV ITERATE_ELEMENT events
ENV NODE_ELEMENT kubernetes.container_name
ENV ALERT_ELEMENT kubernetes.namespace_name
ENV SUMMARY_ELEMENT @rawstring
ENV TIMESTAMP_ELEMENT @timestamp
ENV URL_ELEMENT url
ENV SEVERITY_ELEMENT 5
ENV MANAGER_ELEMENT KafkaWebhook

ENV KAFKA_BROKER kafka1:9092
ENV KAFKA_USER events
ENV KAFKA_PWD events
ENV KAFKA_TOPIC events

EXPOSE 8080


ENTRYPOINT /app/ssh-startup.sh

