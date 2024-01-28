abstract class PlayerProgressPersistence {
  Future<List<int>> getFinishedLevels();

  Future<void> saveLevelFinished(int level, int time);

  Future<void> reset();
}