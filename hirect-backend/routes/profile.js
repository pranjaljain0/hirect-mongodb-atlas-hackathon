var express = require('express');
const app = express.Router();
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const { AffindaCredential, AffindaAPI } = require('@affinda/affinda');
const fs = require('fs');
const morgan = require('morgan');
const _ = require('lodash');
const fileUpload = require('express-fileupload');

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(morgan('dev'));
app.use(
	fileUpload({
		createParentPath: true,
	})
);

const uri = env.MongoDBuri;

app.get('/', (req, res) => res.json({ Route: 'Profile' }));

app.get('/reviews/:email', async (req, res) => {
	var email = req.params.email;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.findOne({ email })
				.then((e) => {
					console.log(e);
					res.status(200).json({
						status: 'SUCCESS',
						reviews: e.reviews,
					});
				});

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/review/post', async (req, res) => {
	var email = req.body.email;
	var review = req.body.review;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email },
					{
						$push: {
							reviews: review,
						},
					}
				)
				.then((e) =>
					res.status(200).json({ status: 'SUCCESS', reviews: review })
				);

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/job/:email/:jobID', async (req, res) => {
	var email = req.params.email;
	var jobID = req.params.jobID;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.findOne({ email })
				.then((e) => {
					e.appliedJobs.forEach((e, index) => {
						if (e.jobID == jobID) {
							res.status(200).json({ status: e.status });
						}
					});
				});

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/application/status/update', async (req, res) => {
	var email = req.body.email;
	var jobID = req.body.jobID;
	var status = req.body.status;
	var index = null;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.findOne({ email })
				.then((e) => {
					e.appliedJobs.forEach((e, index) => {
						if (e.jobID == jobID) {
							client
								.db('Hirect')
								.collection('Users')
								.updateOne(
									{ email },
									{
										$set: {
											[`appliedJobs.${index}.status`]: status,
										},
									}
								)
								.then((e) =>
									res.status(200).json({ status: 'SUCCESS', status: status })
								);
						}
					});
				});

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/votecount', async (req, res) => {
	var email = req.query.email;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.findOne({ email })
				.then((e) => {
					res.status(200).json({
						status: 'SUCCESS',
						upVotes: e.upVotes,
						downVotes: e.downVotes,
					});
				});

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/rate/up', async (req, res) => {
	var email = req.body.email;
	var upvote = req.body.upvote;
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email },
					{
						$set: {
							upVotes: upvote + 1,
						},
					}
				)
				.then((e) =>
					res.status(200).json({ status: 'SUCCESS', voteCount: upvote + 1 })
				);

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/rate/down', async (req, res) => {
	var email = req.body.email;
	var downvote = req.body.downvote;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email },
					{
						$set: {
							downVotes: downvote + 1,
						},
					}
				)
				.then((e) =>
					res.status(200).json({
						upVote: e.upVote,
						downVote: e.downVote,
					})
				);

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/get/id', async (req, res) => {
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ _id: req.query._id })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/add/:category/:email', async (req, res) => {
	var { email, category } = req.params;
	var data = req.body.data;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne({ email }, { $push: { [category]: data } })
				.then((e) => {
					res.status(200).json({ status: 1, message: 'UPDATED' });
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/remove/:category/:email', async (req, res) => {
	var { email, category } = req.params;
	var data = req.body.data;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne({ email }, { $pull: { [category]: data } })
				.then((e) => {
					res.status(200).json({ status: 1, message: 'Removed' });
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/get/email', async (req, res) => {
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: req.query.email })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/add/appliedJobs', async (req, res) => {
	const email = req.body.email;
	const _jobDetail = req.body.jobDetail;
	const _userDetails = req.body.userDetails;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email: email },
					{
						$addToSet: {
							appliedJobs: { ..._jobDetail, status: '0' },
							appliedJobsID: _jobDetail.jobID,
						},
					}
				)
				.then((e) => {
					res.status(200).json({ status: 1, message: 'Added' });
				});

			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email: _jobDetail.jobPostOwnerEmail },
					{
						$addToSet: {
							applications: {
								..._userDetails,
								jobTitle: _jobDetail.jobTitle,
								jobID: _jobDetail.jobID,
							},
						},
					}
				);

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/add/savedJobs/', async (req, res) => {
	const email = req.body.email;
	const jobDetail = req.body.jobDetail;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email: email },
					{
						$addToSet: {
							savedJobs: jobDetail,
						},
					}
				)
				.then((e) => res.status(200).json({ status: 1, message: 'Added' }));

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/get/appliedJobs', async (req, res) => {
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: req.query.email })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results[0].appliedJobs);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/get/applications', async (req, res) => {
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: req.query.email })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results[0].applications);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.get('/get/savedJobs/', async (req, res) => {
	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.find({ email: req.query.email })
				.toArray((err, results) => {
					err && res.status(400).json(err);
					res.status(200).json(results[0].savedJobs);
				});
			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/update', async (req, res) => {
	var email = req.body.email;
	var updatedDoc = req.body.updatedDoc;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne({ email: email }, { $set: { ...updatedDoc } })
				.then((resp) =>
					res
						.status(200)
						.json({ status: 1, message: 'updated succesfully', resp })
				);

			const body = {
				_id: '623192c1ed9b39426bdda760',
				accountType: 1,
				email: 'p@g.com',
				password: '123',
				fullName: 'pj',
				education: [
					{
						name: 'A',
						start: '2021',
						end: '2023',
					},
				],
				experience: [],
				certifications: [],
				savedJobs: [],
				appliedJobs: [],
			};

			return client;
		})
		// .then((client) => client.close())
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

app.post('/preferences/update/:email', async (req, res) => {
	const email = req.params.email;
	const preferences = req.body.preferences;

	MongoClient.connect(uri, {
		useNewUrlParser: true,
		useUnifiedTopology: true,
	})
		.then((client) => {
			client
				.db('Hirect')
				.collection('Users')
				.updateOne(
					{ email: email },
					{
						$set: {
							preferences: preferences,
						},
					}
				)
				.then((e) => res.status(200).json({ status: 1, message: 'Updated' }));

			return client;
		})
		.catch((error) => {
			res.status(500).json({ status: 'ERROR', err: error });
			console.error(error);
		});
});

module.exports = app;
