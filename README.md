# 📱 Catálogo de Proyectos - Flutter

Una aplicación móvil desarrollada en **Flutter** que funciona como un catálogo interactivo de propiedades/proyectos. Esta app demuestra la integración de autenticación de usuarios mediante Firebase y el consumo eficiente de servicios web (API REST) con manejo de estados sin conexión.

## ✨ Características Principales

* **🔐 Autenticación Segura:** Inicio de sesión integrado con **Google Sign-In** a través de Firebase Authentication, ofreciendo un flujo de acceso rápido y confiable.
* **🌐 Consumo de API REST:** Conexión a un servicio externo (JSONPlaceholder) para obtener y listar dinámicamente las publicaciones o "proyectos" disponibles.
* **💾 Modo Offline (Caché Local):** Implementación de `shared_preferences` para almacenar la última respuesta de la API. Si el usuario pierde la conexión a internet, la aplicación carga automáticamente los datos guardados en caché, evitando interrupciones en la experiencia de usuario.
* **🎨 Interfaz Moderna y Responsiva:** Diseño limpio basado en Material Design 3 (Material 3), con manejo de estados de carga (`CircularProgressIndicator`), estados de error, e imágenes dinámicas mediante red.

## 🛠️ Tecnologías y Paquetes Utilizados

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend as a Service:** [Firebase](https://firebase.google.com/) (Autenticación)
* **Dependencias Principales:**
  * `firebase_core` & `google_sign_in`: Para la gestión de usuarios y login con Google.
  * `http`: Para realizar peticiones HTTP GET a la API externa.
  * `shared_preferences`: Para el almacenamiento local (caché) de los datos JSON.

## 🏗️ Arquitectura del Código

El proyecto está estructurado modularmente para separar la lógica de negocio de la interfaz de usuario:

* `/lib/models/`: Contiene los modelos de datos (ej. `post_model.dart`) encargados de mapear las respuestas JSON a objetos de Dart.
* `/lib/services/`: Contiene la lógica pura de la aplicación.
  * `api_service.dart`: Gestiona las peticiones HTTP y la lógica de fallback hacia el caché local si no hay red.
  * `google_auth_service.dart`: Centraliza todas las interacciones con Firebase y Google Sign-In.
* `/lib/main.dart`: Punto de entrada de la aplicación y donde se definen las pantallas de UI (`LoginScreen` y `PostListScreen`).

## 🚀 Cómo ejecutar este proyecto

1. Clona este repositorio: `git clone https://github.com/LunaC155/Registro-Google.git`
2. Instala las dependencias: `flutter pub get`
3. **Importante:** Este proyecto utiliza Firebase. Para que funcione localmente, deberás conectar tu propio proyecto de Firebase:
   * Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
   * Habilita el método de inicio de sesión con Google.
   * Genera y descarga los archivos de configuración (`google-services.json` para Android, `GoogleService-Info.plist` para iOS) y colócalos en sus respectivas carpetas.
   * Ejecuta `flutterfire configure` para generar el archivo `firebase_options.dart`.
4. Ejecuta la app: `flutter run`
