import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

import 'services/api_service.dart';
import 'services/google_auth_service.dart';
import 'models/post_model.dart';

// -----------------------------------------------------------
// 1. PUNTO DE ENTRADA Y CONFIGURACIÓN
// -----------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Proyectos - Offline & Auth',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta roja de "Debug"
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Un color más sobrio y elegante
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}

// -----------------------------------------------------------
// 2. PANTALLA DE LOGIN (Autenticación con Google)
// -----------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.signInWithGoogle();
    
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PostListScreen(user: user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso cancelado o error de conexión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: _isLoading 
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícono decorativo para la pantalla de bienvenida
                  Icon(Icons.real_estate_agent, size: 80, color: Colors.blueGrey.shade700),
                  const SizedBox(height: 20),
                  const Text(
                    'Bienvenido al Portal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _handleLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Ingresar con Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// -----------------------------------------------------------
// 3. PANTALLA PRINCIPAL (Consumo de API + Caché + Interfaz UI)
// -----------------------------------------------------------
class PostListScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  
  const PostListScreen({super.key, required this.user});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  final GoogleAuthService _authService = GoogleAuthService();

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catálogo de Proyectos', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Hola, ${widget.user.displayName?.split(" ").first ?? "Usuario"}', 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueGrey),
            tooltip: 'Actualizar datos',
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          )
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _apiService.fetchPosts(),
        builder: (context, snapshot) {
          
          // Estado 1: Cargando datos de la API
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sincronizando catálogo...'),
                ],
              )
            );
          } 
          
          // Estado 2: Error (Sin internet y sin caché)
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Modo Offline Activo\nPero no hay datos guardados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              )
            );
          } 
          
          // Estado 3: Éxito (Datos obtenidos de la red o del caché)
          else if (snapshot.hasData) {
            final posts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen dinámica del proyecto
                      Image.network(
                        'https://picsum.photos/seed/${post.id + 100}/600/300',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Si falla la carga de la imagen (ej. offline), mostramos un icono
                          return Container(
                            height: 200,
                            color: Colors.blueGrey.shade100,
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                      
                      // Contenido de la Tarjeta
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Propiedad #${post.id}',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              post.title.toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }
}