// server_config.js
module.exports = {
    port: 3001, 
    corsOptions: {
      origin: '*', 
      methods: ['GET', 'POST'],
      allowedHeaders: ['Content-Type', 'Authorization'], 
    },
  };