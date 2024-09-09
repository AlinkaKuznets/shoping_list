import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoping_list/domain/grocery_cubit.dart';

import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widgets/new_item.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push<GroceryItem>(
              MaterialPageRoute(
                builder: (ctx) => const NewItem(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<GroceryCubit, GroceryState>(
        builder: (context, state) {
          return switch (state) {
            GroceryStateLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            GroceryStateError() => Center(
                child: Text(
                  state.error.toString(),
                ),
              ),
            GroceryStateReady state => state.data.isEmpty
                ? const Center(child: Text('No items added yet!'))
                : ListView.builder(
                    itemCount: state.data.length,
                    itemBuilder: (ctx, index) => Dismissible(
                      onDismissed: (direction) =>
                          context.read<GroceryCubit>().removeItem(
                                state.data[index].id,
                              ),
                      key: ValueKey(state.data[index].id),
                      child: ListTile(
                        title: Text(state.data[index].name),
                        leading: Container(
                          width: 24,
                          height: 24,
                          color: state.data[index].category.color,
                        ),
                        trailing: Text(
                          state.data[index].quantity.toString(),
                        ),
                      ),
                    ),
                  ),
          };
        },
      ),
    );
  }
}
