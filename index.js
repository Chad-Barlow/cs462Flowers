var express = require('express');
var path = require('path');
var connect = require('connect');
var http = require('http');
//var tools = require('./tools.js');
var cookieParser = require('cookie-parser');
var cookieSession = require('cookie-session');
var session = require('client-sessions');
var URI = require('urijs');
var fs = require('fs');
var bodyParser = require('body-parser');
//var tools = require('./tools.js');
var app = express();

app.use(express.static(__dirname + '/'));
app.use(bodyParser.urlencoded({extended:true}));
app.use(bodyParser.json());

app.use(session({
  cookieName: 'session',
  secret: "superduppersecretuuid20sdfsfd",  //tools.generateUUID(),
  duration: 30 * 60 * 1000,
  activeDuration: 5 * 60 * 1000,
  ephemeral: true
}));

app.use(function(req, res, next) { 
  //If we want to add sessions this is where it would go. 
  /*if (req.session && req.session.user) {
	if(user.userId === req.session.user.userId){
               req.user = user;
               req.session.user = user;
               res.locals.user = user;
        }
    } else {
      next();
    }*/
    console.log("Session created!");
    next();
});

app.get('/', (req,res)=>{
    res.sendFile(path.join(__dirname + '/login.html'));
    //res.redirect('login');
});

app.get('/thanks', (req,res)=>{
    res.sendFile(path.join(__dirname + '/thankyou.html'));
});


app.get('/bid', (req,res)=>{
   
http.get('http://ec2-54-202-97-114.us-west-2.compute.amazonaws.com:8080/sky/event/cj1pvaakt0001i0p9ffenyuza/2005/rfq/delivery_ready?shopID='+req.query.shopID+'&dest='+req.query.dest, (res) => {
  const { statusCode } = res;
  const contentType = res.headers['content-type'];

  let error;
  if (statusCode !== 200) {
    error = new Error(`Request Failed.\n` +
                      `Status Code: ${statusCode}`);
  } else if (!/^application\/json/.test(contentType)) {
    error = new Error(`Invalid content-type.\n` +
                      `Expected application/json but received ${contentType}`);
  }
  if (error) {
    console.error(error.message);
    //consume response data to free up memory
        res.resume();
            return;
              }
   
                res.setEncoding('utf8');
                  let rawData = '';
                    res.on('data', (chunk) => { rawData += chunk; });
                      res.on('end', () => {
                          try {
                                const parsedData = JSON.parse(rawData);
                                      console.log(parsedData);
                                          } catch (e) {
                                                console.error(e.message);
                                                    }
                                                      });
                                                      }).on('error', (e) => {
                                                        console.error(`Got error: ${e.message}`);
                                                        });   






  res.sendFile(path.join(__dirname + '/store.html'));
});

app.listen(3005, function () {
    console.log('Example app listening on port 3005!');
})


var config = {
  'secrets' : {
    'clientId' : 'USBHU4SJMV3UWRSGUHN1DNQ5234FRX2NTUEDT100GM4RETGO',
    'clientSecret' : 'GOCNUL4BVWQZ0LMVXVX4RM4FVOY2YH4VP3MHC5TCUKZJHYXE',
    'redirectUrl' : 'http://ec2-54-202-97-114.us-west-2.compute.amazonaws.com:3005/redirect'
  }
};

var foursquare = require('node-foursquare')(config);

//Use this one as the exchange thingy better than mine
app.get('/login', function(req, res) {
    res.writeHead(303, { 'location': foursquare.getAuthClientRedirectUrl() });
    res.end();
});

//Finish foursquare login procedure
app.get('/redirect', function (req, res) {
  foursquare.getAccessToken({
    code: req.query.code
  }, function (error, accessToken) {
    if(error) {
      res.send('An error was thrown: ' + error.message);
    }
    else {
      req.session.user = "store";
      res.redirect('store');
    }
   });
});

app.get('/store',function (req,res){
	res.sendFile(path.join(__dirname + '/store.html'));
});
