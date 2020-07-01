const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const cors = require('cors')({origin: true});
admin.initializeApp();

exports.myFunction = functions.firestore
  .document('Restaurants/{restDocId}/Reviews/{reviewDocId}')
  .onWrite((change, context) => { 
    
    console.log('write operation performed');
    console.log('restDocId:'+context.params.restDocId);
    console.log('reviewDocId:'+context.params.reviewDocId);
  
    // Get an object with the current document value.
    // If the document does not exist, it has been deleted.
    const document = change.after.exists ? change.after.data() : null;
    const documentBefore = change.before.data();
    
    admin
    .firestore()
    .collection('Restaurants/'+context.params.restDocId+'/Reviews')
    .get().then((snapshots)=>{

      var sum = 0.0;
      var count = 0;
      var average = 0.0;
      // get values from database and calculate average of average_ratings
      snapshots.forEach(doc => {

        const docId = doc.id;
        const docData = doc.data();
        var docAverage = docData['average_rating']


        sum = sum + parseFloat(docAverage);
        count++;
        average = sum/count;

        // console.log('sum:'+sum);
        // console.log('count:'+count);
        // console.log(doc.id, '=>', doc.data());
      });

      console.log('average:'+average.toFixed(1));

      // update calculated average ratings to database under that restaurant
      admin
      .firestore()
      .collection('Restaurants')
      .doc(context.params.restDocId)
      .update({
        avg_rating: (average.toFixed(1)).toString(),
      }).then((snapshots)=>{
  
        console.log('avg_rating updated');

        return true;
      }).catch((e)=>
  
        console.log('error occured: '+e)
  
      );
  

      return true;
    }).catch((e)=>

      console.log('error occured: '+e)

    );
  

  });




  // calculate average ratings on Events

  exports.myFunction = functions.firestore
  .document('Events/{restDocId}/Reviews/{reviewDocId}')
  .onWrite((change, context) => { 
    
    console.log('write operation performed');
    console.log('restDocId:'+context.params.restDocId);
    console.log('reviewDocId:'+context.params.reviewDocId);
  
    // Get an object with the current document value.
    // If the document does not exist, it has been deleted.
    const document = change.after.exists ? change.after.data() : null;
    const documentBefore = change.before.data();
    
    admin
    .firestore()
    .collection('Events/'+context.params.restDocId+'/Reviews')
    .get().then((snapshots)=>{

      var sum = 0.0;
      var count = 0;
      var average = 0.0;
      // get values from database and calculate average of average_ratings
      snapshots.forEach(doc => {

        const docId = doc.id;
        const docData = doc.data();
        var docAverage = docData['rating']


        sum = sum + parseFloat(docAverage);
        count++;
        average = sum/count;

        // console.log('sum:'+sum);
        // console.log('count:'+count);
        // console.log(doc.id, '=>', doc.data());
      });

      console.log('average:'+average.toFixed(1));

      // update calculated average ratings to database under that restaurant
      admin
      .firestore()
      .collection('Events')
      .doc(context.params.restDocId)
      .update({
        avg_rating: (average.toFixed(1)).toString(),
      }).then((snapshots)=>{
  
        console.log('avg_rating updated');

        return true;
      }).catch((e)=>
  
        console.log('error occured: '+e)
  
      );
  

      return true;
    }).catch((e)=>

      console.log('error occured: '+e)

    );
  

  });







  // initialize users login record everyday

  exports.addMessage = functions.https.onRequest((req, res) => {

    const currentdate = new Date(); 
    const currentOffset = currentdate.getTimezoneOffset();
    const ISTOffset = 330;   // IST offset UTC +5:30 
    const ISTTime = new Date(currentdate.getTime() + (ISTOffset + currentOffset)*60000);
    var day = currentdate.getDate()<10? "0"+ currentdate.getDate() : currentdate.getDate();
    var month = (currentdate.getMonth()+1)<10? "0"+(currentdate.getMonth()+1): (currentdate.getMonth()+1);
    const dateTime = day
                  + "-"
                  + month
                  + "-" 
                  + currentdate.getFullYear();
  
  
    admin
    .firestore()
    .collection("Users")
    .get()
    .then((snapshot) => 
       snapshot.forEach((userSnap) => {

        userSnap.ref.set({
          login_record: {
            [dateTime]: false
          },
        }, { merge: true });

      }
      ))
    .catch(()=>
      res.json({
        message: 'not great'
      })
      );
  
  
    
  });
  

 
  /**
  * Here we're using Gmail to send 
  */
  let transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
          user: 'dreamworldtab.my@gmail.com',
          pass: 'rohitmohitroli'
      }
  });
  
  exports.sendMail = functions.https.onRequest((req, res) => {
      cors(req, res, () => {
        
          // getting dest email by query string
          const email = req.query.email;
          const orderId = req.query.orderId;
          const userId = req.query.userId;
          const mobile = req.query.mobile;
          const name = req.query.name;


          admin
          .firestore()
          .document("Orders/"+orderId)
          .get()
          .then((doc)=>{

            const docData = doc.data();
            var delivery_address = docData['delivery_address']
            var items = docData['items']
            var total_amount = docData['total_amount']
            var order_by = docData['order_by']
            

              const mailOptions = {
                from: 'OCD <dreamworldtab.my@gmail.com>', // Something like: Jane Doe <janedoe@gmail.com>
                to: email,
                subject: 'New Order from OCD App', // email subject
                html: `<p style="font-size: 16px;">New Order Rceived!!</p>
                    <br /> <br />
                    <p>
                    Name: `+name+` <br />
                    Mobile: `+mobile+` <br />
                    Delivery Address: `+delivery_address+` <br /> <br />
                    <b> Total Amount: `+total_amount+` </b> <br /> <br />
                    Items: `+items+` <br />
                    </p>
                ` // email content in HTML
              };

              // returning result
              return transporter.sendMail(mailOptions, (erro, info) => {
                  if(erro){
                      return res.send(erro.toString());
                  }
                  return res.send('Sent');
              });

  
          }).catch(()=>
          res.json({
            message: 'not great'
          })
          );
  
      });    
  });