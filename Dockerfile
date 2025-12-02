FROM node:23-alpine as build

WORKDIR /app

COPY package*.json ./

RUN \
  apk add --no-cache git && \
  npm install && \
  npm install -g @angular/cli

COPY . .

RUN \
  export TAG=$(git describe --tags --always --dirty) && \
  export SHA=$(git log -1 --format=%h) && \
  sed -i "s|0.0.0|${TAG}|" src/lib/version.ts && \
  sed -i "s|abcdef123456|${SHA}|" src/lib/version.ts && \
  npm ci && \
  npx ng build && \
  cp _redirects dist/ctrl/_redirects


FROM nginx:stable

COPY --from=build \
  /app/dist/ctrl \
  /usr/share/nginx/html

EXPOSE 80
