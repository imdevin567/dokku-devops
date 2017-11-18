FROM node:8-alpine

RUN mkdir /app && npm install -g yarn
COPY app /app

WORKDIR /app
RUN rm -rf node_modules && yarn

EXPOSE 3000
CMD ["yarn", "start"]
