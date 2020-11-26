//
// Generated file. Do not edit.
//

// ignore: unused_import
import 'dart:ui';

import 'package:assets_audio_player_web/web/assets_audio_player_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:import_js_library/import_js_library.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:wakelock_web/wakelock_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(PluginRegistry registry) {
  AssetsAudioPlayerWebPlugin.registerWith(registry.registrarFor(AssetsAudioPlayerWebPlugin));
  FirebaseFirestoreWeb.registerWith(registry.registrarFor(FirebaseFirestoreWeb));
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  FirebaseStorageWeb.registerWith(registry.registrarFor(FirebaseStorageWeb));
  FluttertoastWebPlugin.registerWith(registry.registrarFor(FluttertoastWebPlugin));
  ImportJsLibrary.registerWith(registry.registrarFor(ImportJsLibrary));
  SharedPreferencesPlugin.registerWith(registry.registrarFor(SharedPreferencesPlugin));
  WakelockWeb.registerWith(registry.registrarFor(WakelockWeb));
  registry.registerMessageHandler();
}
