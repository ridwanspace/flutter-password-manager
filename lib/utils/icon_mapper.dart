import 'package:flutter/material.dart';

class IconMapper {
  static final Map<String, IconData> _iconMap = {
    'people': Icons.people,
    'email': Icons.email,
    'account_balance': Icons.account_balance,
    'shopping_cart': Icons.shopping_cart,
    'work': Icons.work,
    'movie': Icons.movie,
    'folder': Icons.folder,
    'lock': Icons.lock,
    'vpn_key': Icons.vpn_key,
    'language': Icons.language,
    'phone': Icons.phone,
    'games': Icons.games,
    'school': Icons.school,
    'fitness_center': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'flight': Icons.flight,
    'computer': Icons.computer,
    'cloud': Icons.cloud,
    'favorite': Icons.favorite,
    'star': Icons.star,
  };

  static IconData getIcon(String name) {
    return _iconMap[name] ?? Icons.folder;
  }

  static List<String> get availableIcons => _iconMap.keys.toList();
}
