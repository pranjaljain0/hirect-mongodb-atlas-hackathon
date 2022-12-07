const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const express = require('express');
const app = express.Router();
const morgan = require('morgan');
var uniqid = require('uniqid');

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(morgan('dev'));

const uri =
	'mongodb+srv://pranjaljain0:mOI95OR4zNrtyZ3i@cluster0.gylbe.mongodb.net/hirect?retryWrites=true&w=majority';
// mongodb+srv://pranjaljain0:mOI95OR4zNrtyZ3i@cluster0.gylbe.mongodb.net/hirect
app.get('/', (req, res) => res.json({ Route: 'Jobs' }));

app.get('/all', async (req, res) => {
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Jobs')
				.find({})
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results);
				});
			return client;
		})
		// .then((client) => client.close())
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/sorted/:email', async (req, res) => {
	var email = req.params.email;
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
					err && res.status(400).json(err);
					var apps = results[0].applications;
					var resApps = {};
					apps.forEach((item, index) => {
						if (
							resApps[item.jobTitle] !== undefined &&
							resApps[item.jobTitle].applications !== null
						)
							resApps[item.jobTitle] = {
								jobID: item.jobID,
								applications: [...resApps[item.jobTitle].applications, item],
							};
						else
							resApps[item.jobTitle] = {
								jobID: item.jobID,
								applications: [item],
							};
					});
					res.status(200).json(resApps);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/tags/all', async (req, res) => {
	var tags = [];
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Jobs')
				.find({})
				.toArray((err, results) => {
					err && res.status(400).json(err);
					results.map((item, index) => {
						item['jobTags'] !== undefined &&
							item['jobTags'] !== null &&
							item['jobTags'].map((item, index) => {
								if (tags.indexOf(item) === -1) tags.push(item);
							});
					});
					res.status(200).json(tags);
				});
			return client;
		})
		// .then((client) => client.close())
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/posts', async (req, res) => {
	var posts = [];
	var email = req.query.email;
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results[0].jobPosts);
				});
			return client;
		})
		// .then((client) => client.close())
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/applied', async (req, res) => {
	var email = req.query.email;
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Jobs')
				.find({ email })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results);
				});
			return client;
		})
		// .then((client) => client.close())
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/post', async (req, res) => {
	var email = req.body.email;
	var jobDetails = req.body.jobDetails;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			var jobID = uniqid();
			client
				.db('Hirect')
				.collection('Jobs')
				.insertOne({ ...jobDetails, jobID });

			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email },
					{ $addToSet: { jobPosts: { ...jobDetails, jobID } } }
				)
				.then((e) => {
					res
						.status(200)
						.json({ status: 'SUCCESS', res: e, email, jobDetails, jobID });
				});
			return client;
		})
		// .then((client) => client.close())
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

module.exports = app;
