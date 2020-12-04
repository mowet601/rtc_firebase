import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as apn from '@parse/node-apn';
import { uuid } from 'uuidv4';

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
            const time = doc.createTime.seconds;
            const time2 = doc.readTime.seconds;
            const diff = time2 - time;
            if (diff > 21600) {
                calldocs.push(doc.id);
            }
        });
        if (calldocs.length > 0) {
            let html = '<h1>Call Docs Cleaned Up</h1>';
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
            let html = '<h1>Ongoing Calls</h1>';
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

const options = {
    token: {
        key: __dirname + "/../AuthKey_2AFRPJJGR9.p8",
        keyId: "2AFRPJJGR9",
        teamId: "RZ5HK969KG",
    },
    cert: __dirname + "/../voip_services.pem",
    production: false,
};
const apnProvider = new apn.Provider(options);

export const apncallpush = functions.https.onRequest(async (req, res) => {
    const callerid: string = req.body.callerid;
    const callername: string = req.body.callername;
    const callertoken: string = req.body.calleetoken;
    const calluuid: string = uuid();
    // let calleruuid = req.body.calleruuid;

    console.log(`CallerID: ${callerid}, CallerName: ${callername}, CallerAPNToken: ${callertoken}`);

    const note = new apn.Notification();
    const deviceToken = `${callertoken}`

    note.rawPayload = {
        "aps": {
            "content-available": 1,
            "alert": {
                "uuid": calluuid,
                "incoming_caller_id": callerid,
                "incoming_caller_name": callername,
            },
        },
    };
    note.expiry = Math.floor(Date.now() / 1000) + 60;
    note.pushType = "voip";
    note.topic = "com.stellarvision.uvuevideochat.voip";

    apnProvider.send(note, deviceToken).then((result) => {
        const r = `PushNotifsSent: ${result.sent.length}, pushesfailed: ${result.failed.length}`;
        // console.log(r);
        let a: string[] = [];
        result.failed.forEach(e => {
            if (e.response !== null) {
                a.push(`${e.status}: ${e.response?.reason} - ${e.device}`);
            }
            else {
                a.push(`did: ${e.device} error: ${e.error?.name} errmsg: ${e.error?.message}\n${e.error?.stack}`);
            }
        });
        console.log({ msg: r, success: result.sent.length, failed: a });
        res.send({ msg: r, success: result.sent.length, failed: a });
    }).catch(() => {
        console.log('NOPE notif not sent');
        res.send({ msg: 'Error: Notif not sent' })
    });
});