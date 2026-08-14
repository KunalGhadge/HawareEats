/// Configuration file for HawareEats Supabase Backend Integration
class SupabaseConstants {
  static const String supabaseUrl = 'https://addsskvhsypebtuhrngu.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_0GetVKRsK34mSvZ8lJb60g_MvG7GLmA';

  /// Helper to check if credentials are configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
