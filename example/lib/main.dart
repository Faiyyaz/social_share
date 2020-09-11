import 'package:flutter/material.dart';
import 'package:social_share/post_share.dart';
import 'package:social_share/social_share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlatButton(
              onPressed: () async {
                String sendStatus;
                PostShare postShare = PostShare(
                  message: 'Hello testing share plugin',
                  type: 'text',
                );
                sendStatus = await SocialShare.shareWhatsApp(
                  postShareJson: postShareToJson(postShare),
                );
                print(sendStatus);
              },
              child: Text('Share WhatsApp'),
            ),
            SizedBox(
              height: 16.0,
            ),
            FlatButton(
              onPressed: () async {
                String sendStatus;
                PostShare postShare = PostShare(
                  message: 'Hello',
                  type: 'text',
                );
                sendStatus = await SocialShare.shareTwitter(
                  postShareJson: postShareToJson(postShare),
                );
                print(sendStatus);
              },
              child: Text('Share Tweet'),
            ),
            SizedBox(
              height: 16.0,
            ),
            FlatButton(
              onPressed: () async {
                String sendStatus;
                PostShare postShare = PostShare(
                  message: 'https://www.google.com',
                  type: 'text',
                );
                sendStatus = await SocialShare.shareFacebook(
                  postShareJson: postShareToJson(postShare),
                );
                print(sendStatus);
              },
              child: Text('Share FB'),
            ),
          ],
        ),
      ),
    );
  }
}
