import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';

/// Handles all menu-related read operations.
/// Write operations (create, update, delete) are managed from the admin web dashboard.
class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches all menu categories.
  Future<List<MenuCategoryModel>> getCategories() async {
    final response = await _supabase
        .from('menu_categories')
        .select()
        .order('name');

    return (response as List<dynamic>)
        .map((json) => MenuCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches all available menu items, optionally filtered by category.
  /// 
  /// Only returns items where `is_available = true` (enforced by RLS as well).
  Future<List<MenuItemModel>> getMenuItems({String? categoryId}) async {
    var query = _supabase
        .from('menu_items')
        .select('*, menu_categories(id, name, description)')
        .eq('is_available', true)
        .order('name');

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query;

    return (response as List<dynamic>)
        .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single menu item by its ID.
  Future<MenuItemModel?> getMenuItemById(String id) async {
    final response = await _supabase
        .from('menu_items')
        .select('*, menu_categories(id, name, description)')
        .eq('id', id)
        .eq('is_available', true)
        .maybeSingle();

    if (response == null) return null;
    return MenuItemModel.fromJson(response);
  }

  /// Searches menu items by name keyword.
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    final response = await _supabase
        .from('menu_items')
        .select('*, menu_categories(id, name, description)')
        .eq('is_available', true)
        .ilike('name', '%$query%')
        .order('name');

    return (response as List<dynamic>)
        .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
