import 'package:flutter/foundation.dart';

class BuildSimulatorCoordinator extends ChangeNotifier {
  static const Map<String, num> _summaryTemplate = <String, num>{
    'ATK': 0,
    'MATK': 0,
    'DEF': 0,
    'MDEF': 0,
    'STR': 0,
    'DEX': 0,
    'INT': 0,
    'AGI': 0,
    'VIT': 0,
    'ASPD': 0,
    'CritRate': 0,
    'PhysicalPierce': 0,
    'ElementPierce': 0,
    'Accuracy': 0,
    'Stability': 0,
    'HP': 0,
    'MP': 0,
  };

  List<Map<String, dynamic>> _savedBuilds = <Map<String, dynamic>>[];
  bool _showRecommendations = true;
  int _equipmentCacheCount = 0;
  Map<String, num> _summary = Map<String, num>.from(_summaryTemplate);
  List<String> _aiRecommendations = const <String>[];
  bool _isAiRecommendationLoading = false;
  String _aiRecommendationSource = 'rule';
  String _aiRecommendationMessage = 'Using local recommendation rules.';

  void Function(String buildId)? _loadBuildById;
  void Function(String name)? _saveBuildByName;
  void Function(String buildId)? _deleteBuildById;
  void Function(String buildId, String nextName)? _renameBuildById;
  void Function(String buildId)? _toggleFavoriteBuildById;
  void Function(List<Map<String, dynamic>> builds)? _replaceSavedBuilds;
  void Function(List<Map<String, dynamic>> builds)? _mergeSavedBuilds;
  void Function(bool value)? _setShowRecommendations;
  VoidCallback? _clearAllData;

  List<Map<String, dynamic>> get savedBuilds => _savedBuilds
      .map((Map<String, dynamic> item) {
        return Map<String, dynamic>.from(item);
      })
      .toList(growable: false);

  bool get showRecommendations => _showRecommendations;
  int get equipmentCacheCount => _equipmentCacheCount;
  Map<String, num> get summary => Map<String, num>.from(_summary);
  List<String> get aiRecommendations => List<String>.from(_aiRecommendations);
  bool get isAiRecommendationLoading => _isAiRecommendationLoading;
  String get aiRecommendationSource => _aiRecommendationSource;
  String get aiRecommendationMessage => _aiRecommendationMessage;

  void attachHandlers({
    required void Function(String buildId) onLoadBuildById,
    required void Function(String name) onSaveBuildByName,
    required void Function(String buildId) onDeleteBuildById,
    required void Function(String buildId, String nextName) onRenameBuildById,
    required void Function(String buildId) onToggleFavoriteBuildById,
    required void Function(List<Map<String, dynamic>> builds)
    onReplaceSavedBuilds,
    required void Function(List<Map<String, dynamic>> builds)
    onMergeSavedBuilds,
    required void Function(bool value) onSetShowRecommendations,
    required VoidCallback onClearAllData,
  }) {
    _loadBuildById = onLoadBuildById;
    _saveBuildByName = onSaveBuildByName;
    _deleteBuildById = onDeleteBuildById;
    _renameBuildById = onRenameBuildById;
    _toggleFavoriteBuildById = onToggleFavoriteBuildById;
    _replaceSavedBuilds = onReplaceSavedBuilds;
    _mergeSavedBuilds = onMergeSavedBuilds;
    _setShowRecommendations = onSetShowRecommendations;
    _clearAllData = onClearAllData;
  }

  void detachHandlers() {
    _loadBuildById = null;
    _saveBuildByName = null;
    _deleteBuildById = null;
    _renameBuildById = null;
    _toggleFavoriteBuildById = null;
    _replaceSavedBuilds = null;
    _mergeSavedBuilds = null;
    _setShowRecommendations = null;
    _clearAllData = null;
  }

  void updateSnapshot({
    required List<Map<String, dynamic>> savedBuilds,
    required bool showRecommendations,
    required int equipmentCacheCount,
    required Map<String, num> summary,
    required List<String> aiRecommendations,
    required bool isAiRecommendationLoading,
    required String aiRecommendationSource,
    required String aiRecommendationMessage,
  }) {
    _savedBuilds = savedBuilds
        .map((Map<String, dynamic> item) {
          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
    _showRecommendations = showRecommendations;
    _equipmentCacheCount = equipmentCacheCount;
    _summary = Map<String, num>.from(_summaryTemplate)..addAll(summary);
    _aiRecommendations = List<String>.from(aiRecommendations);
    _isAiRecommendationLoading = isAiRecommendationLoading;
    _aiRecommendationSource = aiRecommendationSource;
    _aiRecommendationMessage = aiRecommendationMessage;
    notifyListeners();
  }

  void loadBuildById(String buildId) {
    _loadBuildById?.call(buildId);
  }

  void saveBuildByName(String name) {
    _saveBuildByName?.call(name);
  }

  void deleteBuildById(String buildId) {
    _deleteBuildById?.call(buildId);
  }

  void renameBuildById(String buildId, String nextName) {
    _renameBuildById?.call(buildId, nextName);
  }

  void toggleFavoriteBuildById(String buildId) {
    _toggleFavoriteBuildById?.call(buildId);
  }

  void replaceSavedBuilds(List<Map<String, dynamic>> builds) {
    _replaceSavedBuilds?.call(builds);
  }

  void mergeSavedBuilds(List<Map<String, dynamic>> builds) {
    _mergeSavedBuilds?.call(builds);
  }

  void setShowRecommendations(bool value) {
    _setShowRecommendations?.call(value);
  }

  void clearAllData() {
    _clearAllData?.call();
  }
}
