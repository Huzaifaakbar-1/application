import 'dart:math';

class Quotes {
  static const _list = [
    "Every morning is a new chance. Wake up, show up, win the day.",
    "Small steps every day lead to big results over time.",
    "Discipline is choosing what you want most over what you want right now.",
    "Going to the gym today is a promise to your future self.",
    "Learning a new language opens a new world. Keep going!",
    "Cybersecurity skills are the future. Every lesson counts.",
    "Consistency beats talent every single time.",
    "You don't have to be great to start, but you have to start to be great.",
    "Your habits today are your results tomorrow.",
    "One more rep. One more lesson. One more day. That's how legends are built.",
    "Tired? Rest. But never quit.",
    "Your future self is watching you right now. Make them proud.",
    "Progress, not perfection. Keep moving.",
    "The hardest part is starting. You've already done that — keep going!",
    "Every expert was once a beginner who refused to give up.",
  ];

  static final _rng = Random();
  static int _last = -1;

  static String next() {
    int i;
    do { i = _rng.nextInt(_list.length); } while (i == _last && _list.length > 1);
    _last = i;
    return _list[i];
  }
}
