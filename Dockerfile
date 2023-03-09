FROM alpine

ARG loc=.
ARG cron="*/5 * * * *"

WORKDIR /app

RUN apk update

# https://nodejs.org/en/download/package-manager/#alpine-linux
RUN apk add nodejs npm
RUN apk add nginx

COPY ${loc} .
COPY nginx.conf /etc/nginx/http.d/default.conf

RUN rm -Rf node_modules # should be ignored in .dockerignore
RUN rm -Rf dist # should be ignored in .dockerignore
RUN npm ci
RUN mkdir dist
RUN echo "rm -Rf /app/distSwp && cp -r /app/dist /app/distSwp && ln -sfn /app/distSwp /usr/share/nginx/html && npm run build --prefix /app && ln -sfn /app/dist /usr/share/nginx/html" >> /root/build.sh
RUN chmod +x /root/build.sh
RUN /root/build.sh

RUN echo "${cron} /root/build.sh >> /var/log/qwik-isr.log" >> "/tmp/qwik-crontab.txt"
RUN /usr/bin/crontab /tmp/qwik-crontab.txt

RUN echo "nginx -g 'daemon off;' & /usr/sbin/crond -f -l 8" >> /root/start.sh
RUN chmod +x /root/start.sh

CMD /root/start.sh
