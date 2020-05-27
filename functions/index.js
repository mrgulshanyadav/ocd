const functions = require('firebase-functions');
const admin = require('firebase-admin');
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
  

