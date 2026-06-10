import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQY4K05OjUB8xY63ZrR1B8uPopsyDbaR4',
    appId: '1:862442978495:android:2f84d6c1e63f46728e1a0a',
    messagingSenderId: '862442978495',
    projectId: 'solarpumpsupervision-b0c86',
    storageBucket: 'solarpumpsupervision-b0c86.firebasestorage.app',
    databaseURL: 'https://solarpumpsupervision-b0c86-default-rtdb.europe-west1.firebasedatabase.app',
  );
}
