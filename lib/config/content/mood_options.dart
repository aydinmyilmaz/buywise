class MoodOptions {
  static const List<Map<String, String>> options = [
    {'id': 'great', 'emoji': '😊', 'label': 'Great'},
    {'id': 'calm', 'emoji': '😌', 'label': 'Calm'},
    {'id': 'tired', 'emoji': '😔', 'label': 'Tired'},
    {'id': 'stressed', 'emoji': '😤', 'label': 'Stressed'},
    {'id': 'sad', 'emoji': '😢', 'label': 'Down'},
    {'id': 'bored', 'emoji': '😐', 'label': 'Bored'},
  ];

  static String getDescription(String id) {
    switch (id) {
      case 'great':
        return 'feeling great and energetic';
      case 'calm':
        return 'calm and relaxed';
      case 'tired':
        return 'tired and low energy';
      case 'stressed':
        return 'stressed and overwhelmed';
      case 'sad':
        return 'feeling down';
      case 'bored':
        return 'bored and restless';
      default:
        return id;
    }
  }
}
