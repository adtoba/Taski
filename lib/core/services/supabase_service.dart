import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {

  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> insert({String? table, Map<String, dynamic>? data}) async {
    await _supabase.from(table!).insert(data!);
  }

  static Future<void> update({String? table, Map<String, dynamic>? data, String? id}) async {
    if (id != null) {
      await _supabase.from(table!).update(data!).eq('id', id);
    } else {
      await _supabase.from(table!).update(data!);
    }
  }

  static Future<void> delete({String? table, String? id}) async {
    await _supabase.from(table!).delete().eq('id', id!);
  }
}