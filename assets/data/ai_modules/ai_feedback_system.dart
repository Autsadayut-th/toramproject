class AIFeedback {
  String recommendation;
  bool liked;

  AIFeedback(this.recommendation, this.liked);
}

class AIFeedbackSystem {

  List<AIFeedback> history = [];

  void addFeedback(String recommendation, bool liked) {
    history.add(AIFeedback(recommendation, liked));
  }

  int countLiked() {
    int total = 0;

    for (int i = 0; i < history.length; i++) {
      if (history[i].liked) {
        total++;
      }
    }

    return total;
  }

  int countDisliked() {
    int total = 0;

    for (int i = 0; i < history.length; i++) {
      if (!history[i].liked) {
        total++;
      }
    }

    return total;
  }
}