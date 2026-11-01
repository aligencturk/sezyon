import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/game_category.dart';
import '../models/story_node.dart';
import 'language_service.dart';

/// assets/stories/KATEGORI.json dosyalarından dallanan hikayeyi yükler
class StoryService {
  final LanguageService _languageService = LanguageService();

  late Map<String, StoryNode> _nodes;
  late String _startId;

  Future<void> load(GameCategory category) async {
    final raw = await rootBundle.loadString('assets/stories/${category.key}.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _startId = json['start'] as String;
    _nodes = (json['nodes'] as Map<String, dynamic>).map(
      (id, node) => MapEntry(id, StoryNode.fromJson(id, node as Map<String, dynamic>)),
    );
  }

  StoryNode get start => node(_startId);

  StoryNode node(String id) {
    final node = _nodes[id];
    if (node == null) throw StateError('Hikaye sahnesi bulunamadı: $id');
    return node;
  }

  /// Seçilen dile göre metni döndürür, {name} yerine karakter adını koyar
  String localize(Map<String, String> text, String characterName) {
    final lang = _languageService.isTurkish ? 'tr' : 'en';
    return (text[lang] ?? text['tr'] ?? '').replaceAll('{name}', characterName);
  }
}
