import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as apn from '@parse/node-apn';

admin.initializeApp();

const db = admin.firestore();

export const helloWorld = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send("<h1>Hello from Firebase!</h1><p>You have found the stellarvision cloud functions url</p>");
});

export const cleanupCallDocs = functions.https.onRequest(async (req, res) => {
    functions.logger.info('Cleanup has been initiated');
    const querySnapshot = await db.collection('calls').get();
    const calldocs: string[] = [];
    if (!querySnapshot.empty) {
        querySnapshot.forEach((doc) => {
            var time = doc.createTime.seconds;
            var time2 = doc.readTime.seconds;
            var diff = time2 - time;
            if (diff > 21600) {
                calldocs.push(doc.id);
            }
        });
        if (calldocs.length > 0) {
            var html = '<h1>Call Docs Cleaned Up</h1>';
            calldocs.forEach(async (e) => {
                console.log('cleaned: ' + e);
                html += '<p>' + e + '</p>';
                await db.collection('calls').doc(e).delete();
            });
            res.send(html);
        }
        else {
            res.send('<h1>No CallDocs Cleaned</h1>');
        }
    }
    else res.send('query empty');
});

export const ongoingCalls = functions.https.onRequest(async (req, res) => {
    functions.logger.info('getOngoingCalls List has been initiated');
    const querySnapshot = await db.collection('calls').get();
    const calldocs: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];
    if (!querySnapshot.empty) {
        querySnapshot.forEach((doc) => {
            calldocs.push(doc);
        });
        if (calldocs.length > 0) {
            var html = '<h1>Ongoing Calls</h1>';
            calldocs.forEach((e) => {
                console.log('> ' + e.id + e.data()['channel_id'] + e.data()['timestamp']);
                html += '<p>' + e.data()['channel_id'] + ' > ' + e.data()['timestamp'] + '</p>';
            });
            res.send(html);
        }
        else {
            res.send('<h1>No Ongoing Calls</h1>');
        }
    }
    else res.send('query empty');
});

var options = {
    token: {
        key: "./AuthKey_2AFRPJJGR9.p8",
        keyId: "2AFRPJJGR9",
        teamId: "RZ5HK969KG"
    },
    production: true
};
var apnProvider = new apn.Provider(options);

export const apncallpush = functions.https.onRequest(async (req, res) => {
    functions.logger.info('APN Call Push has been initiated');
    var callerid = req.body.callerid;
    var callername = req.body.callername;
    // var calleruuid = req.body.calleruuid;
    var callertoken = req.body.calleetoken;

    var note = new apn.Notification();
    let deviceToken = `${callertoken}`

    // TODO : Replace uuid with actual real user's device uuid
    note.rawPayload = {
        "aps": {
            "alert": {
                "uuid": `f579cc8c-7127-4ca3-a9f5-dd4a591a2567`,
                "incoming_caller_id": `${callerid}`,
                "incoming_caller_name": `${callername}`,
            }
        }
    };
    note.pushType = "voip";
    note.topic = "com.stellarvision.uvuevideochat.voip";

    apnProvider.send(note, deviceToken).then((result) => {
        var r = `DONE! notifs sent: ${result.sent.length} failed: ${result.failed.length}`;
        console.log(r);
        res.send({ msg: r });
    });
});