const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const fileUpload = require('express-fileupload');
const express = require('express');
const app = express.Router();
const morgan = require('morgan');
const { AffindaCredential, AffindaAPI } = require('@affinda/affinda');
const fs = require('fs');
const { Axios, default: axios } = require('axios');
const cloudinary = require('cloudinary').v2;

const uri =
	'mongodb+srv://pranjaljain0:mOI95OR4zNrtyZ3i@cluster0.gylbe.mongodb.net/hirect?retryWrites=true&w=majority';
cloudinary.config({
	cloud_name: 'de7jxzes9',
	api_key: '161713749771518',
	api_secret: '78tL2uTZYLvFOQjGf7ijmSZ2ghA',
	secure: true,
});

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(morgan('dev'));
app.use(
	fileUpload({
		createParentPath: true,
	})
);

app.get('/', (req, res) => res.json({ Route: 'Helper' }));

app.get('/jsonstr', (req, res) => res.json({ str: { fullName: 'PJB' } }));

app.post('/saveJob', (req, res) => res.json({ Hello: 'Workin' }));

app.post('/saveJob', (req, res) => res.json({ Hello: 'Workin' }));

app.post('/resumeParser', async (req, res) => {
	try {
		if (!req.files) {
			res.json({
				status: false,
				message: 'No file uploaded',
			});
		} else {
			var resume = req.files.resume;
			var email = req.body.email;
			var path = './uploads/' + resume.name;
			resume.mv(path);

			cloudinary.uploader.upload(
				path,
				{
					public_id: `hirect/resume/${email}`,
					overwrite: true,
				},
				function (error, result) {
					if (result)
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
										{ $set: { resume: { name: resume.name, url: result.url } } }
									)
									.then((resp) =>
										res.status(200).json({
											status: 1,
											message: 'updated succesfully',
											resume: { name: resume.name, url: result.url },
										})
									);
								return client;
							})

							.catch((error) => {
								res.status(500).json({ status: 'ERROR', err: error });
								console.error(error);
							});
					if (error) res.status(500).json({ status: 'ERROR', err: error });
				}
			);

			// const credential = new AffindaCredential(
			// 	'e01c296c8855ce16c59799532efff7c11ce9bd4d'
			// );
			// const client = new AffindaAPI(credential);
			// const readStream = fs.createReadStream('./uploads/' + resume.name);
			// client
			// 	.createResume({ file: readStream })
			// 	.then((result) => {
			// 		console.log();
			// 		if (result.statusCode == 200)
			// 			res.json({
			// 				status: true,
			// 				message: 'File is uploaded',
			// 				data: {
			// 					name: resume.name,
			// 					mimetype: resume.mimetype,
			// 					size: resume.size,
			// 				},
			// 				resume: result,
			// 			});
			// 		if (result.statusCode == 400) {
			// 			console.error(result);
			// 			res.status(400).send(result);
			// 		}
			// 	})
			// 	.catch((err) => {
			// 		console.error(err);
			// 		res.status(500).send(err);
			// 	});
			// Can also use a URL:
		}
	} catch (err) {
		console.error(err);
		res.status(500).send(err);
	}
});

module.exports = app;
