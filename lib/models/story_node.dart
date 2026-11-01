/// Dallanan hikayedeki bir seçenek
class StoryChoice {
  final Map<String, String> text;
  final String next;

  const StoryChoice({required this.text, required this.next});

  factory StoryChoice.fromJson(Map<String, dynamic> json) => StoryChoice(
    text: Map<String, String>.from(json['text'] as Map),
    next: json['next'] as String,
  );
}

/// Dallanan hikayedeki bir sahne. Seçeneği olmayan sahne hikayenin sonudur.
class StoryNode {
  final String id;
  final Map<String, String> text;
  final List<StoryChoice> choices;

  const StoryNode({
    required this.id,
    required this.text,
    required this.choices,
  });

  bool get isEnd => choices.isEmpty;

  factory StoryNode.fromJson(String id, Map<String, dynamic> json) => StoryNode(
    id: id,
    text: Map<String, String>.from(json['text'] as Map),
    choices: (json['choices'] as List? ?? const [])
        .map((c) => StoryChoice.fromJson(c as Map<String, dynamic>))
        .toList(),
  );
}
