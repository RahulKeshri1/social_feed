import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides access to the Supabase client singleton.
SupabaseClient get supabase => Supabase.instance.client;
