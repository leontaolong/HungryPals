"use strict";

const express = require('express');
const morgan = require('morgan');
const bodyParser = require('body-parser');
const mongodb = require('mongodb');
const fs = require('fs');
const http = require('http');
const https = require('https');
const apn = require('apn');
const forceSsl = require('express-force-ssl');

const PostStore = require('./models/posts/mongostore.js');
const UserStore = require('./models/users/mongostore.js');

const app = express();

app.use(morgan(process.env.LOGFORMAT || 'dev'));
// app.use(forceSsl);

//  increase the default limit globally 
require('events').EventEmitter.prototype._maxListeners = 100;

const port = process.env.PORT || '443';
const httpPort = process.env.HTTPPORT || '80'
const dbAddr = process.env.DBADDR;
const apnsPath = process.env.APNSPATH;

if (!dbAddr) {
	console.error("please set DBADDR to connect to Database");
	process.exit(1);
}

if (!apnsPath) {
	console.error("please set APNSPATH to connect to APNs for push notification");
	process.exit(1);
}

let apnsOptions = {
    token: {
        key: apnsPath,
        keyId: "LC84854ZM7",
        teamId: "6UZHVQ52BK"
    },
    production: false
};

// set up APNs connection
var apnProvider = new apn.Provider(apnsOptions);
// let apnProvider = null;  // for dev purpose, don't frequently connect to APNs

app.use(bodyParser.text());
app.use(bodyParser.json());

let certPath = process.env.CERTPATH;
let keyPath = process.env.KEYPATH;

var options = {
    key: fs.readFileSync(keyPath),
    cert: fs.readFileSync(certPath),
};

mongodb.MongoClient.connect(`mongodb://${dbAddr}/hungrypals`)
    .then(db => {
		let colUsers = db.collection('users');
        let colPosts = db.collection('posts');

        let handlers = require('./handlers/handlers.js');

        let userStore = new UserStore(colUsers);
        let postStore = new PostStore(colPosts);

        app.use(handlers(userStore, postStore, apnProvider));

        //error handler
        app.use((err, req, res, next) => {
            console.error(err);
            res.status(err.status || 500).send(err.message);
        });

        http.createServer(app).listen(httpPort, () => {
            console.log(`server running at ${httpPort} ...`)
        });  
        
        https.createServer(options, app).listen(port, () => {
            console.log(`server running at ${port} ...`)
        });
        
    })
    .catch(err => {
        console.error(err);
});