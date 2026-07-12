import 'package:albert/features/utils/firebase/files/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['SERVER_CLIENT_ID'],
  );
}
