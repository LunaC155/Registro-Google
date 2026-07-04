import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // 1. Usamos .instance como exige la nueva versión
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Función para abrir la ventana de cuentas de Google
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // 2. En la v7+ es obligatorio inicializar antes de llamar a la ventana
      await _googleSignIn.initialize();
      
      // 3. Usamos authenticate() en lugar de signIn()
      final GoogleSignInAccount? account = await _googleSignIn.authenticate();
      return account; 
    } catch (error) {
      debugPrint("Error al iniciar sesión con Google: $error");
      return null; 
    }
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}