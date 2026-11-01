import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sezyon/models/game_category.dart';
import 'package:sezyon/models/story_node.dart';

Map<String, StoryNode> _load(GameCategory category) {
  final file = File('assets/stories/${category.key}.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in (json['nodes'] as Map<String, dynamic>).entries)
      entry.key: StoryNode.fromJson(entry.key, entry.value as Map<String, dynamic>),
  };
}

String _start(GameCategory category) {
  final file = File('assets/stories/${category.key}.json');
  return (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['start']
      as String;
}

void main() {
  for (final category in GameCategory.values) {
    group('Hikaye: ${category.key}', () {
      late Map<String, StoryNode> nodes;
      late String start;

      setUpAll(() {
        nodes = _load(category);
        start = _start(category);
      });

      test('başlangıç sahnesi var', () {
        expect(nodes.containsKey(start), isTrue);
      });

      test('her seçenek var olan bir sahneye gidiyor', () {
        for (final node in nodes.values) {
          for (final choice in node.choices) {
            expect(
              nodes.containsKey(choice.next),
              isTrue,
              reason: '${node.id} -> ${choice.next} bulunamadı',
            );
          }
        }
      });

      test('tüm sahneler başlangıçtan ulaşılabilir', () {
        final seen = <String>{};
        void visit(String id) {
          if (!seen.add(id)) return;
          for (final choice in nodes[id]!.choices) {
            visit(choice.next);
          }
        }

        visit(start);
        expect(nodes.keys.toSet().difference(seen), isEmpty);
      });

      test('en az iki farklı son var', () {
        final endings = nodes.values.where((n) => n.isEnd).toList();
        expect(endings.length, greaterThanOrEqualTo(2));
      });

      test('her metin ve seçenek TR ve EN dolu, Kiril karakter yok', () {
        final cyrillic = RegExp(r'[Ѐ-ӿ]');
        void check(String where, Map<String, String> text) {
          for (final lang in ['tr', 'en']) {
            final value = text[lang];
            expect(value, isNotNull, reason: '$where: $lang eksik');
            expect(value!.trim(), isNotEmpty, reason: '$where: $lang boş');
            expect(cyrillic.hasMatch(value), isFalse, reason: '$where: Kiril harf');
          }
        }

        for (final node in nodes.values) {
          check(node.id, node.text);
          for (final choice in node.choices) {
            check('${node.id} -> ${choice.next}', choice.text);
          }
        }
      });
    });
  }
}
