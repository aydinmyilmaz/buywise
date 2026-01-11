class AIResponse {
  final String decision;
  final String headline;
  final String message;
  final Map<String, dynamic> costAnalysis;
  final String peerInsight;
  final String? mindsetNote;
  final List<String>? alternatives;
  final Map<String, dynamic>? waitSuggestion;
  final String? emotionalNote;
  final List<String> actionItems;

  AIResponse({
    required this.decision,
    required this.headline,
    required this.message,
    required this.costAnalysis,
    required this.peerInsight,
    required this.actionItems,
    this.mindsetNote,
    this.alternatives,
    this.waitSuggestion,
    this.emotionalNote,
  });

  factory AIResponse.fromMap(Map<String, dynamic> map) {
    return AIResponse(
      decision: map['decision'] ?? 'wait',
      headline: map['headline'] ?? '',
      message: map['message'] ?? '',
      costAnalysis: Map<String, dynamic>.from(map['costAnalysis'] ?? {}),
      peerInsight: map['peerInsight'] ?? '',
      mindsetNote: map['mindsetNote'],
      alternatives: (map['alternatives'] as List?)?.map((e) => e.toString()).toList(),
      waitSuggestion: map['waitSuggestion'] != null
          ? Map<String, dynamic>.from(map['waitSuggestion'])
          : null,
      emotionalNote: map['emotionalNote'],
      actionItems: (map['actionItems'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
