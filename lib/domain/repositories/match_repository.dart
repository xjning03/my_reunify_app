import 'package:my_reunify_app/domain/entities/match.dart';

abstract class MatchRepository {
  Future<Match> createMatch(Match match);
  Future<Match> getMatch(String matchId);
  Future<List<Match>> getMatchesByParentCase(String parentCaseId);
  Future<List<Match>> getMatchesByChildCase(String childCaseId);
  Future<List<Match>> getPendingMatches();
  Future<void> updateMatch(Match match);
  Future<void> deleteMatch(String matchId);
}
