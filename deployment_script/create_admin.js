const dotenv = require('dotenv');
dotenv.config();
var request = require('request');

var options = {
  'method': 'POST',
  'url': process.env.CREATE_ADMIN,
  'headers': {
    'Content-Type': 'application/json',
    'Cookie': 'user_sid=s%3A7UbHCKo-pP9TzIgj5crnoYS4hkc1GqYi.z4Sx3PET3lYv0SIlAWXnFmmLk9W2JRbD3AuVyDR4NkE'
  },
  body: JSON.stringify({
    "name": "admin",
    "username": "admin",
    "email": process.env.ADMIN_EMAIL,
    "password": process.env.ADMIN_PASS,
    "phone": process.env.ADMIN_PHONE,
    "role_id": "1"
  })

};
request(options, function (error, response) {
  if (error) throw new Error(error);
  console.log(response.body);
});


var options_module = {
'method': 'GET',
'url': process.env.CREATE_MODULE,
'headers': {
'Cookie': 'user_sid=s%3Aq4_GusWnYyKoru0Jnga3jLesrd886f3Q.cZVQlo%2BlId4gtggAd8kwaAH7vvosbFq%2Fb%2F%2FwJ%2FC5a8g'
}
};
request(options_module, function (error, response) {
if (error) throw new Error(error);
console.log(response.body);
});




var options_package = {
'method': 'GET',
'url': process.env.CREATE_PACKAGE,
'headers': {
'Cookie': 'user_sid=s%3Aq4_GusWnYyKoru0Jnga3jLesrd886f3Q.cZVQlo%2BlId4gtggAd8kwaAH7vvosbFq%2Fb%2F%2FwJ%2FC5a8g'
}
};
request(options_package, function (error, response) {
if (error) throw new Error(error);
console.log(response.body);
});