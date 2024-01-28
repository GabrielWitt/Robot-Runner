import 'package:ranger_gabo/player_progress/persistence/player_progress_persistence.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture =
    SharedPreferences.getInstance();

  @override
  Future<List<int>> getFinishedLevels() async {
    final prefs = await instanceFuture;
    final serialized = prefs.getStringList('levelFinished') ?? [];

    return serialized.map(int.parse).toList();
  }

  @override
  Future<void> saveLevelFinished(int level, int time) async {
    final prefs = await instanceFuture;
    final serialized = prefs.getStringList('levelsFinished') ?? [];
    if (level <= serialized.length) {
      final currentTime = int.parse(serialized[level -1]);
      if (time < currentTime) {
        serialized[level -1] = time.toString();
      }
    } else {
      serialized.add(time.toString());
    }
    await prefs.setStringList('levelsFinished', serialized);
  }

  @override
  Future<void> reset() async {
    final prefs = await instanceFuture;
    await prefs.remove('levelFinished');
  }
}