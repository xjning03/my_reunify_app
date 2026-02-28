import 'package:my_reunify_app/domain/entities/memory_clue.dart';

abstract class MemoryClueRepository {
  Future<MemoryClue> createMemoryClue(MemoryClue clue);
  Future<MemoryClue> getMemoryClue(String clueId);
  Future<List<MemoryClue>> getCaseClues(String caseId);
  Future<void> updateMemoryClue(MemoryClue clue);
  Future<void> deleteMemoryClue(String clueId);
}
