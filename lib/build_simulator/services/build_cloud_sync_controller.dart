import 'build_calculator_service.dart';
import 'build_persistence_service.dart';

class BuildCloudSyncController {
  const BuildCloudSyncController();

  List<Map<String, dynamic>> normalizeCloudBuilds(
    List<Map<String, dynamic>> cloudBuilds,
  ) {
    return BuildPersistenceService.normalizeBuildList(
      cloudBuilds,
      summaryTemplate: BuildCalculatorService.summaryTemplate,
    );
  }

  List<Map<String, dynamic>> applySavedBuildLimit({
    required List<Map<String, dynamic>> builds,
    required int? maxSavedBuilds,
  }) {
    if (maxSavedBuilds == null || builds.length <= maxSavedBuilds) {
      return builds;
    }
    return builds.take(maxSavedBuilds).toList(growable: false);
  }
}
