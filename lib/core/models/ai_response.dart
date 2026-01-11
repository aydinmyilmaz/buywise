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
  final String? verdictReasoning;
  final List<String>? pros;
  final List<String>? cons;
  final String? longTermValue;

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
    this.verdictReasoning,
    this.pros,
    this.cons,
    this.longTermValue,
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
      verdictReasoning: map['verdictReasoning'],
      pros: (map['pros'] as List?)?.map((e) => e.toString()).toList(),
      cons: (map['cons'] as List?)?.map((e) => e.toString()).toList(),
      longTermValue: map['longTermValue'],
    );
  }
}
