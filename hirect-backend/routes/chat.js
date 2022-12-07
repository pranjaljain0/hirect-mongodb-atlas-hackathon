var StreamChat = require('stream-chat').StreamChat;
const express = require('express');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const app = express.Router();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(morgan('dev'));

const api_key = 'try43se9tyqm';
const api_secret =
	'34utmrtjpx7w8j7we74ca4eynpuq4sya3rnrpe6kv8bfrzc5n4ks8aek9d3r8ejn';

app.get('/', (req, res) => res.json({ status: 'working' }));

app.get('/channel/new', async (req, res) => {
	var user1 = req.query.user1;
	var user2 = req.query.user2;

	const serverClient = StreamChat.getInstance(api_key, api_secret);
	const channel = serverClient.channel('messaging', {
		members: [user1, user2],
		created_by_id: user1,
	});

	channel.create().then((e) => {
		res.json({ status: 'Channel created' });
	});
});

module.exports = app;
