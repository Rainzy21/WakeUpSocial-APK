import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/resilient_call.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';

/// Handles all menu-related read operations.
class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MenuCategoryModel>> getCategories() {
    return ResilientCall.run(
      operation: 'menu.get_categories',
      action: () async {
        final response = await _supabase
            .from('menu_categories')
            .select()
            .order('name')
            .limit(50);
        return (response as List<dynamic>)
            .map(
              (json) =>
                  MenuCategoryModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  Future<List<MenuItemModel>> getMenuItems({String? categoryId}) {
    return ResilientCall.run(
      operation: 'menu.get_items',
      tags: {if (categoryId != null) 'category_id': categoryId},
      action: () async {
        var query = _supabase
            .from('menu_items')
            .select('*, menu_categories(id, name, description)')
            .eq('is_available', true);

        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }

        final response = await query.order('name').limit(100);
        return (response as List<dynamic>)
            .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<MenuItemModel?> getMenuItemById(String id) {
    return ResilientCall.run(
      operation: 'menu.get_item_by_id',
      tags: {'item_id': id},
      action: () async {
        final response = await _supabase
            .from('menu_items')
            .select('*, menu_categories(id, name, description)')
            .eq('id', id)
            .eq('is_available', true)
            .maybeSingle();
        if (response == null) return null;
        return MenuItemModel.fromJson(response);
      },
    );
  }

  Future<List<MenuItemModel>> searchMenuItems(String query) {
    return ResilientCall.run(
      operation: 'menu.search_items',
      action: () async {
        final response = await _supabase
            .from('menu_items')
            .select('*, menu_categories(id, name, description)')
            .eq('is_available', true)
            .ilike('name', '%$query%')
            .order('name')
            .limit(50);
        return (response as List<dynamic>)
            .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
