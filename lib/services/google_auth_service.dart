import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// La clase ahora se llama AuthService para ser más genérica
class AuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn;
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId: "497369853822-0isc65qnt3kifgulabqklbdra3983mdk.apps.googleusercontent.com",
        );
      } else {
        googleSignIn = GoogleSignIn();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Inicio de sesión con Google cancelado por el usuario.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error en Google Sign In: $e");
      return null;
    }
  }

  // Nueva función para el inicio de sesión con Facebook usando signInWithPopup
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      // signInWithPopup es ideal para aplicaciones web
      return await FirebaseAuth.instance.signInWithPopup(facebookProvider);
    } catch (e) {
      print("Error en Facebook Sign In: $e");
      return null;
    }
  }
}
