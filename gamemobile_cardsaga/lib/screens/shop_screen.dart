import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/item.dart';
import '../providers/lang_provider.dart';
import '../utils/constants.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    final lang = context.watch<LangProvider>();
    final t = lang.locale.languageCode == 'en' ? Strings.en : Strings.vi;

    final items = gs.shopItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: t['back'],
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t['shop_title'] ?? 'Shop',
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => lang.toggle(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8.0),
        itemCount: items.length + 1,
        separatorBuilder: (context, index) {
          if (index == 0) return const SizedBox.shrink();
          return const Divider();
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                t['shop_items_title'] ?? 'Items',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.pink.shade700),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final itemIndex = index - 1;
            if (itemIndex >= items.length) return const SizedBox.shrink();

            final item = items[itemIndex];
            final owned = gs.user.inventory[item.id]?.owned ?? 0;

            String itemName = '';
            IconData itemIcon = Icons.help;
            switch (item.type) {
              case ItemType.freezeTime:
                itemName = t['freeze_time'] ?? 'Freeze Time';
                itemIcon = Icons.ac_unit;
                break;
              case ItemType.doubleCoins:
                itemName = t['double_coins'] ?? 'Double Coins';
                itemIcon = Icons.monetization_on;
                break;
            }

            return ListTile(
              leading: Icon(
                itemIcon,
                color: Colors.blueAccent,
                size: 30,
              ),
              title: Text(itemName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                "${t['coins'] ?? 'Coins'}: ${item.price} | ${t['owned'] ?? 'Owned'}: $owned",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent),
                onPressed: () {
                  final success = gs.buyItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? "${t['purchased']} $itemName"
                          : (t['not_enough_coins'] ?? 'Not enough coins')),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: Text(t['buy'] ?? 'Buy'),
              ),
            );
          }
        },
      ),
    );
  }
}
