import 'package:flutter/foundation.dart';
import 'services/ai/recommendation_item.dart';

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
    'CSPD': 0,
    'FLEE': 0,
    'CritRate': 0,
    'PhysicalPierce': 0,
    'MagicPierce': 0,
    'ElementPierce': 0,
    'Accuracy': 0,
    'Stability': 0,
    'HP': 0,
    'MP': 0,
  };

  List<Map<String, dynamic>> _savedBuilds = const <Map<String, dynamic>>[];
  bool _showRecommendations = true;
  int _equipmentCacheCount = 0;
  Map<String, num> _summary = Map<String, num>.unmodifiable(_summaryTemplate);
  List<Map<String, dynamic>> _selectedItemDetails =
      const <Map<String, dynamic>>[];
  List<String> _aiRecommendations = const <String>[];
  List<AiRecommendationItem> _aiRecommendationItems =
      const <AiRecommendationItem>[];
  Map<String, String> _feedbackByRecommendationId = const <String, String>{};
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
  void Function(Map<String, dynamic> item)? _upsertCustomEquipment;
  void Function(String id)? _deleteCustomEquipmentById;
  VoidCallback? _clearAllData;
  VoidCallback? _generateAiRecommendations;
  Future<void> Function(AiRecommendationItem recommendation, String reaction)?
  _submitRecommendationFeedback;

  List<Map<String, dynamic>> get savedBuilds => _savedBuilds;

  bool get showRecommendations => _showRecommendations;
  int get equipmentCacheCount => _equipmentCacheCount;
  Map<String, num> get summary => _summary;
  List<Map<String, dynamic>> get selectedItemDetails => _selectedItemDetails;
  List<String> get aiRecommendations => _aiRecommendations;
  List<AiRecommendationItem> get aiRecommendationItems => _aiRecommendationItems;
  Map<String, String> get feedbackByRecommendationId =>
      _feedbackByRecommendationId;
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
    required void Function(Map<String, dynamic> item) onUpsertCustomEquipment,
    required void Function(String id) onDeleteCustomEquipmentById,
    required VoidCallback onClearAllData,
    required VoidCallback onGenerateAiRecommendations,
    required Future<void> Function(
      AiRecommendationItem recommendation,
      String reaction,
    )
    onSubmitRecommendationFeedback,
  }) {
    _loadBuildById = onLoadBuildById;
    _saveBuildByName = onSaveBuildByName;
    _deleteBuildById = onDeleteBuildById;
    _renameBuildById = onRenameBuildById;
    _toggleFavoriteBuildById = onToggleFavoriteBuildById;
    _replaceSavedBuilds = onReplaceSavedBuilds;
    _mergeSavedBuilds = onMergeSavedBuilds;
    _setShowRecommendations = onSetShowRecommendations;
    _upsertCustomEquipment = onUpsertCustomEquipment;
    _deleteCustomEquipmentById = onDeleteCustomEquipmentById;
    _clearAllData = onClearAllData;
    _generateAiRecommendations = onGenerateAiRecommendations;
    _submitRecommendationFeedback = onSubmitRecommendationFeedback;
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
    _upsertCustomEquipment = null;
    _deleteCustomEquipmentById = null;
    _clearAllData = null;
    _generateAiRecommendations = null;
    _submitRecommendationFeedback = null;
  }

  void _clearSnapshotData() {
    _savedBuilds = const <Map<String, dynamic>>[];
    _summary = Map<String, num>.unmodifiable(_summaryTemplate);
    _selectedItemDetails = const <Map<String, dynamic>>[];
    _aiRecommendations = const <String>[];
    _aiRecommendationItems = const <AiRecommendationItem>[];
    _feedbackByRecommendationId = const <String, String>{};
    _isAiRecommendationLoading = false;
    _aiRecommendationSource = 'rule';
    _aiRecommendationMessage = 'Using local recommendation rules.';
  }

  void updateSnapshot({
    required List<Map<String, dynamic>> savedBuilds,
    required bool showRecommendations,
    required int equipmentCacheCount,
    required Map<String, num> summary,
    required List<Map<String, dynamic>> selectedItemDetails,
    required List<String> aiRecommendations,
    required List<AiRecommendationItem> aiRecommendationItems,
    required Map<String, String> feedbackByRecommendationId,
    required bool isAiRecommendationLoading,
    required String aiRecommendationSource,
    required String aiRecommendationMessage,
  }) {
    _savedBuilds = List<Map<String, dynamic>>.unmodifiable(
      savedBuilds.map((Map<String, dynamic> item) {
        return Map<String, dynamic>.unmodifiable(item);
      }),
    );
    _showRecommendations = showRecommendations;
    _equipmentCacheCount = equipmentCacheCount;
    final Map<String, num> nextSummary = Map<String, num>.from(_summaryTemplate)
      ..addAll(summary);
    _summary = Map<String, num>.unmodifiable(nextSummary);
    _selectedItemDetails = List<Map<String, dynamic>>.unmodifiable(
      selectedItemDetails.map((Map<String, dynamic> item) {
          final Map<String, dynamic> copy = Map<String, dynamic>.from(item);
          final dynamic rawStats = item['stats'];
          if (rawStats is List) {
            copy['stats'] = List<Map<String, dynamic>>.unmodifiable(
              rawStats.whereType<Map>().map((Map<dynamic, dynamic> stat) {
                return Map<String, dynamic>.unmodifiable(
                  Map<String, dynamic>.from(stat),
                );
              }),
            );
          }
          return Map<String, dynamic>.unmodifiable(copy);
        }),
    );
    _aiRecommendations = List<String>.unmodifiable(aiRecommendations);
    _aiRecommendationItems = List<AiRecommendationItem>.unmodifiable(
      aiRecommendationItems,
    );
    _feedbackByRecommendationId = Map<String, String>.unmodifiable(
      feedbackByRecommendationId,
    );
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

  void upsertCustomEquipment(Map<String, dynamic> item) {
    _upsertCustomEquipment?.call(Map<String, dynamic>.from(item));
  }

  void deleteCustomEquipmentById(String id) {
    _deleteCustomEquipmentById?.call(id);
  }

  void clearAllData() {
    _clearAllData?.call();
  }

  bool get canGenerateAiRecommendations => _generateAiRecommendations != null;

  void generateAiRecommendations() {
    _generateAiRecommendations?.call();
  }

  Future<void> submitRecommendationFeedback({
    required AiRecommendationItem recommendation,
    required String reaction,
  }) async {
    final handler = _submitRecommendationFeedback;
    if (handler == null) {
      return;
    }
    await handler(recommendation, reaction);
  }

  @override
  void dispose() {
    detachHandlers();
    _clearSnapshotData();
    super.dispose();
  }
}
