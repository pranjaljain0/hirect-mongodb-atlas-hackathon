var express = require('express');
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const app = express.Router();
const morgan = require('morgan');
const mailjet = require('node-mailjet').connect(
	'7b49938b353225cd076dcfa1512d473d',
	'359b9eda904b7ebce328b3a1830b42a8'
);
var StreamChat = require('stream-chat').StreamChat;
var uniqid = require('uniqid');

const api_key = 'try43se9tyqm';
const api_secret =
	'34utmrtjpx7w8j7we74ca4eynpuq4sya3rnrpe6kv8bfrzc5n4ks8aek9d3r8ejn';

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(morgan('dev'));

const uri = env.MongoDBuri;

app.get('/', (req, res) => res.json({ Route: 'Auth' }));

app.get('/login', (req, res) => {
	let email = req.query.email;
	let password = req.query.password;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: email, password: password })
				.toArray((err, results) => {
					err && res.status(400).json({ error: err, status: 0 });
					if (results.length != 1)
						res.status(401).json({ status: 0, message: 'User not found' });
					else res.status(200).json(results);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/JobSeekerSignUp', async (req, res) => {
	var email = req.body.email;
	var password = req.body.password;
	var fullName = req.body.fullName;
	// Initialize a Server Client

	const serverClient = StreamChat.getInstance(api_key, api_secret);
	// Create User Token
	const token = serverClient.createToken(fullName);

	var data = {
		accountType: 1,
		userID: uniqid(),
		email,
		password,
		fullName,
		summary: '',
		education: [],
		experience: [],
		certifications: [],
		savedJobs: [],
		appliedJobs: [],
		preferences: {},
		chatToken: token,
	};

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: email })
				.toArray((err, results) => {
					if (results.length === 1) {
						res.status(100).json({ status: 0, message: 'Email already found' });
					} else {
						client
							.db('Hirect')
							.collection('Users')
							.insertOne(data)
							.then((e) => {
								res.status(200).json({
									status: 1,
									message: 'User Registered',
									res: { ...e, ...data },
								});
							});
					}
				});

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/JobProviderSignUp', async (req, res) => {
	var email = req.body.email;
	var password = req.body.password;
	var fullName = req.body.fullName;
	var companyName = req.body.companyName;

	const serverClient = StreamChat.getInstance(api_key, api_secret);
	// Create User Token
	const token = serverClient.createToken(fullName);

	var data = {
		accountType: 0,
		userID: uniqid(),
		email,
		password,
		fullName,
		companyName,
		upVotes: 0,
		downVotes: 0,
		jobPosts: [],
		applications: [],
		reviews: [],
		chatToken: token,
	};

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: email })
				.toArray((err, results) => {
					if (results.length === 1) {
						res.json({ status: 0, message: 'Email already found' });
					} else {
						client
							.db('Hirect')
							.collection('Users')
							.insertOne(data)
							.then((e) => {
								res.json({
									status: 1,
									message: 'User Registered',
									res: { ...e, ...data },
								});
							});
					}
				});

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/forget', (req, res) => {
	let email = req.query.email;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: email })
				.toArray((err, results) => {
					err && res.status(400).json({ error: err, status: 0 });
					if (results.length != 1)
						res.status(401).json({ status: 0, message: 'User not found' });
					else {
						let password = results[0].password;
						const request = mailjet.post('send', { version: 'v3.1' }).request({
							Messages: [
								{
									From: {
										Email: 'rp98@njit.edu',
										Name: 'Hirect Pilot',
									},
									To: [
										{
											Email: email,
										},
									],
									Subject: 'Your Hirect password!',
									TextPart: `Hello, Your password is ${password}`,
									HTMLPart: `<h3>Hello,!</h3><br /><span>Your password is ${password}</span>`,
								},
							],
						});
						request
							.then((result) => {
								res.status(200).json({ status: 1, Message: 'Found', result });
							})
							.catch((err) => {
								res
									.status(400)
									.json({ status: 0, Message: 'Error', error: err });
							});
					}
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

module.exports = app;
