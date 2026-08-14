import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../models/models.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('SupabaseService has not been initialized. Call initialize() first.');
    }
    return _client!;
  }

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('✅ Supabase connected successfully: ${SupabaseConstants.supabaseUrl}');
    } catch (e) {
      debugPrint('⚠️ Supabase initialization note: $e');
      _isInitialized = false;
    }
  }

  // Real Supabase Auth Methods
  static User? get currentAuthUser => _client?.auth.currentUser;

  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    if (_client == null) return null;
    try {
      final res = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );
      return res;
    } catch (e) {
      debugPrint('Supabase SignUp error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    if (_client == null) return null;
    try {
      final res = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } catch (e) {
      debugPrint('Supabase SignIn error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    if (_client == null) return;
    try {
      await _client!.auth.signOut();
    } catch (e) {
      debugPrint('Supabase SignOut error: $e');
    }
  }

  static Future<void> resetPassword(String email) async {
    if (_client == null) return;
    try {
      await _client!.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Supabase ResetPassword error: $e');
      rethrow;
    }
  }
}
