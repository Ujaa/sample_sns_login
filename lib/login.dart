import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LoginWidget extends StatelessWidget {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithKaKao() async {
    final clientState = Uuid().v4();

    print("=============================================================================");
    print("clientState:" + clientState.toString());
    print("=============================================================================");

    //로그인 요청
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': "4392f3172743514e5c0bedd258f563e6",
      'response_mode': 'form_post',
      'redirect_uri':
      'https://delirious-pollen-horn.glitch.me/callbacks/kakao/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(),
        callbackUrlScheme: "webauthcallback");

    print("=============================================================================");
    print("result:" + result);
    print("=============================================================================");

    final body = Uri.parse(result).queryParameters;
    print("=============================================================================");
    print("body:" + body["code"]);
    print("=============================================================================");


    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code',
      'client_id': "4392f3172743514e5c0bedd258f563e6",
      'redirect_uri':
      'https://delirious-pollen-horn.glitch.me/callbacks/kakao/sign_in',
      'code':body["code"],
    });

    var responseTokens = await http.post(tokenUrl.toString());

    print("=============================================================================");
    print("responseTokens:" + responseTokens.body.toString());
    print("=============================================================================");

    Map<String, dynamic> bodys = json.decode(responseTokens.body);
    var response = await http.post(
        'https://delirious-pollen-horn.glitch.me/callbacks/kakao/token',
        body: {"accessToken": bodys['access_token']});
    return await FirebaseAuth.instance
        .signInWithCustomToken(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SNS Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text("Google Login"),
              onPressed: signInWithGoogle,
            ),
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              onPressed: signInWithKaKao,
              child: Text("KaKao Login"),
            ),
          ],
        ),
      ),
    );
  }
}