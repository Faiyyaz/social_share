import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String> shareWhatsApp({
    @required String postShareJson,
  }) async {
    final String status =
        await _channel.invokeMethod('shareWhatsApp', postShareJson);
    return status;
  }

  static Future<String> shareTwitter({
    @required String postShareJson,
  }) async {
    final String status =
        await _channel.invokeMethod('shareTwitter', postShareJson);
    return status;
  }

  static Future<String> shareFacebook({
    @required String postShareJson,
  }) async {
    final String status =
        await _channel.invokeMethod('shareFacebook', postShareJson);
    return status;
  }
}
