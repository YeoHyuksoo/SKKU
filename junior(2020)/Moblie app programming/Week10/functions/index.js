const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

var regToken = "fH4dCTaNTIC3BdjxCceKnH:APA91bE2NEmoZiIcOiQHoE91pMeZ1vyI-P5e9DL4oxysgyrMtZZiLBP8P0rkv9rB_dTHg1sLUqi2zMWLk6iO5qTBTFyTGwwsA3ZbuA9dvNtbtWu_JKJC_ZbR50HXNQMs7RAKXuR2f_mH"
exports.sendPushNotification = functions.database
	.ref ('/Notification/{userId}')
	.onCreate ((snapshot, context) => {
	  const data = snapshot.val();
	  const uid = context.params.userId;

	  console.log ('recv data : ', data, uid);

	  var message = {
		notification: {
		  title: 'test notification',
		  // body: 'test notification body'			// For example
		  body: data.StudentID + " " + data.Name	// For exercise
		},
		data: {
		  token : data.Token,					
		  uid : uid,
		},
		token: regToken
	  };

	  admin.messaging().send(message)
  		.then((response) => {
    		// Response is a message ID string.
    		console.log('Successfully sent message:', response);
			return response;
  		})
  		.catch((error) => {
    		console.log('Error sending message:', error);
  		});
	});
