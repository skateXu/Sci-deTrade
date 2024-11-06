// ipfs_config.js
const { create } = require('ipfs-http-client');
const ipfs = create({ url: 'http://localhost:5001' });
module.exports = ipfs;