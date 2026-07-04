import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class ApiService {
  final String _baseUrl = "https://jsonplaceholder.typicode.com/posts";
  final String _cacheKey = "cached_posts"; // Clave para identificar los datos

  Future<List<Post>> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. Intentar petición HTTP
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // 2. Si tiene éxito, guardamos el JSON crudo en el caché
        await prefs.setString(_cacheKey, response.body);
        
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      // 3. Si falla la red, buscamos en el caché local
      print("Sin conexión, cargando caché...");
      
      String? cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        // Si hay algo guardado, lo mostramos
        List<dynamic> body = jsonDecode(cachedData);
        return body.map((item) => Post.fromJson(item)).toList();
      } else {
        // Si no hay internet Y no hay caché, lanzamos el error
        throw Exception("Sin conexión y sin datos en caché.");
      }
    }
  }
}