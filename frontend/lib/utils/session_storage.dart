// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Per-tab session storage using the browser's sessionStorage API.
/// Each browser tab gets its own isolated session — tabs never overwrite
/// each other's login state.

void saveSession({
  required String role,
  required String firstName,
  required String userId,
}) {
  html.window.sessionStorage['role'] = role;
  html.window.sessionStorage['firstName'] = firstName;
  html.window.sessionStorage['userId'] = userId;
}

void clearSession() {
  html.window.sessionStorage.remove('role');
  html.window.sessionStorage.remove('firstName');
  html.window.sessionStorage.remove('userId');
}

String getSessionRole() => html.window.sessionStorage['role'] ?? '';
String getSessionFirstName() => html.window.sessionStorage['firstName'] ?? '';
String getSessionUserId() => html.window.sessionStorage['userId'] ?? '';