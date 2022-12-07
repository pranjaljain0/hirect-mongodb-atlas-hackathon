## What I built

An application for applying for jobs, The portal is for both employers and job applicants. In my portal there can be be status updates on jobs. Where applicants upload all the details like education, experience & certifications. And also employers will be able to check all the applicant details, change status of the applications and much more. There is also a chat feature available which I have used with third party service.

### Category Submission

Choose Your Own Adventure

### App Link

[Github Repo](https://github.com/pranjaljain0/hirect-mongodb-atlas-hackathon)

### Screenshots

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jkjs8r9rzmu65fgd46vw.png)
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0m9mqqmg1hovc8rqp2wv.png)
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2yeaehhdjhxdhzydkhgu.png)
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ebmq0q7n9toj60f5yl74.png)
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/pnyjhob3y5z1s5mm5tk8.png)
The screenshots are attached but I have created a demo video for the whole app.
[Demo Video](https://drive.google.com/file/d/1muHczWR92O0NEIhZsEK5KYj4fGMuQmWV/view?usp=share_link)

### Description

For this application I have build an application on Flutter as a native mobile for both android and IOS, The backend for the app is made in ExpressJS with multiple libraries to debug APIs written. The app uses basic design as I didnt focus on design of the application, And then I created comphrensive APIs for doing multiple operations.

In express JS I am using `mondodb` Package where I am running mongoDB queries like this

login ([Auth.js](https://github.com/pranjaljain0/hirect-mongodb-atlas-hackathon/blob/main/hirect-backend/routes/auth.js))

```js
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
```

SignUp ([Auth.js](https://github.com/pranjaljain0/hirect-mongodb-atlas-hackathon/blob/main/hirect-backend/routes/auth.js))

```js
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
```

Here you can see, As I dont want multiple users I first check for user then I move forward with creating one, And here the user is being created with initial fields which are required so that the application does not break.

To update I am using addToSet feature of MongoDB

Updating Jobs ([jobs.js](https://github.com/pranjaljain0/hirect-mongodb-atlas-hackathon/blob/main/hirect-backend/routes/jobs.js))

```js
client
	.db('Hirect')
	.collection('Users')
	.updateOne({ email }, { $addToSet: { jobPosts: { ...jobDetails, jobID } } })
	.then((e) => {
		res
			.status(200)
			.json({ status: 'SUCCESS', res: e, email, jobDetails, jobID });
	});
```

### Link to Source Code

[Github Repo](https://github.com/pranjaljain0/hirect-mongodb-atlas-hackathon)

### Permissive License

MIT

## Background

As I am pursuing my masters right now in computer science, I found that the current portals miss few things Which I tried to add in my application, Like status update on my applications, Job posting rating and reviews and more features.

### How I built it

As it was a very comphrensive application. I created APIs using ExpressJS. There I have used a modular approach where I divided endpoints in multiple modules which had there own multiple function which were in turn performing mongoDB operations.
