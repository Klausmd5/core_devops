FROM node:19 AS build

WORKDIR /app

COPY frontend/package.json frontend/yarn.lock ./

RUN yarn install --frozen-lockfile

COPY frontend .

FROM build AS frontend-auth

RUN yarn build auth --prod

FROM build AS frontend

RUN yarn build frontend --prod

FROM build AS mainframe

RUN yarn build mainframe --prod

FROM caddy:2-alpine

COPY deployment/caddy/Caddyfile /srv/input.Caddyfile
COPY deployment/caddy/entrypoint.sh /entrypoint.sh
RUN apk add dos2unix && dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

COPY --from=frontend-auth /app/dist/apps/auth /srv/auth
COPY --from=frontend /app/dist/apps/frontend /srv/frontend
COPY --from=mainframe /app/dist/apps/mainframe /srv/mainframe

ENV DOMAIN_NAME=synopsis.localhost
ENV TLS_EMAIL=""
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
