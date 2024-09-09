import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryCubit extends Cubit<GroceryState> {
  GroceryCubit() : super(GroceryStateLoading());

  Future<void> loadData() async {
    try {
      emit(GroceryStateLoading());
      final url = Uri.https(
        'shoping-list-27fe1-default-rtdb.firebaseio.com',
        'flutter.json',
      );
      final respose = await http.get(url);

      if (respose.statusCode >= 400) {
        throw Exception('Failed to fetch grocery items. Try again later!');
      }

      if (respose.body == 'null') {
        emit(GroceryStateReady(data: []));
        return;
      }

      final List<GroceryItem> loadedItems = [];
      final Map<String, dynamic> listData = json.decode(respose.body);
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      emit(GroceryStateReady(data: loadedItems));
    } catch (err) {
      emit(GroceryStateError(error: err));
    }
  }

  Future<void> addItem({
    required String name,
    required int quantity,
    required String category,
  }) async {
    try {
      emit(GroceryStateLoading());
      final url = Uri.https(
          'shoping-list-27fe1-default-rtdb.firebaseio.com', 'flutter.json');
      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(
          {
            'name': name,
            'quantity': quantity,
            'category': category,
          },
        ),
      );
      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch grocery items. Try again later!');
      }
      return loadData();
    } catch (err) {
      emit(
        GroceryStateError(error: err),
      );
    }
  }

  Future<void> removeItem(String id) async {
    try {
      final url = Uri.https(
        'shoping-list-27fe1-default-rtdb.firebaseio.com',
        'flutter/$id.json',
      );

      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch grocery items. Try again later!');
      }
      return loadData();
    } catch (err) {
      emit(
        GroceryStateError(error: err),
      );
    }
  }
}

sealed class GroceryState {}

class GroceryStateLoading extends GroceryState {}

class GroceryStateError extends GroceryState {
  final Object? error;

  GroceryStateError({required this.error});
}

class GroceryStateReady extends GroceryState {
  final List<GroceryItem> data;

  GroceryStateReady({required this.data});
}
