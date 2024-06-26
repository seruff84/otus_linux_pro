
FROM node:10-alpine
WORKDIR /app
COPY /app /app
RUN chown -R node:node /app
USER node
RUN npm install
EXPOSE 3000
CMD [ "node", "app.js" ]