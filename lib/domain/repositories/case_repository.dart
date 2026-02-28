import 'package:my_reunify_app/domain/entities/case.dart';

abstract class CaseRepository {
  Future<Case> createCase(Case caseData);
  Future<Case> getCase(String caseId);
  Future<List<Case>> getUserCases(String userId);
  Future<List<Case>> getCasesByType(CaseType type);
  Future<void> updateCase(Case caseData);
  Future<void> deleteCase(String caseId);
  Future<List<Case>> searchCases(String query);
}
