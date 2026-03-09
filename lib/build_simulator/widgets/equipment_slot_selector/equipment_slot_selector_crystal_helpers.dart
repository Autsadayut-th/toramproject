part of 'equipment_slot_selector.dart';

const Map<String, Color> _crystalAccentColors = <String, Color>{
  'red': Color(0xFFE57373),
  'green': Color(0xFF81C784),
  'blue': Color(0xFF64B5F6),
  'yellow': Color(0xFFFFD54F),
  'purple': Color(0xFFBA68C8),
};

Color _crystalAccentColor(CrystalLibraryEntry? entry) {
  final String colorKey = entry?.colorKey ?? 'blue';
  return _crystalAccentColors[colorKey] ?? const Color(0xFF64B5F6);
}

String _crystalIconPath(CrystalLibraryEntry? entry) {
  return entry?.iconAssetPath ?? 'assets/data/icon/blue_crysta.png';
}

bool _crystalEntryMatchesQuery(CrystalLibraryEntry entry, String query) {
  final ({String mode, String term}) parsed = _parseCrystalSearchQuery(query);
  final String normalized = parsed.term;
  if (normalized.isEmpty) {
    return true;
  }

  switch (parsed.mode) {
    case 'name':
      return entry.name.toLowerCase().contains(normalized);
    case 'key':
      return entry.key.toLowerCase().contains(normalized);
    case 'type':
      return entry.category.toLowerCase().contains(normalized);
    case 'color':
      return entry.colorKey.contains(normalized) ||
          entry.displayColor.toLowerCase().contains(normalized);
    case 'stat':
      return _crystalStatKeyMatches(entry: entry, query: normalized);
    default:
      if (_crystalTextFieldsMatch(
        query: normalized,
        fields: <String>[
          entry.name,
          entry.key,
          entry.category,
          entry.colorKey,
          entry.displayColor,
        ],
      )) {
        return true;
      }
      return _crystalStatKeyMatches(entry: entry, query: normalized);
  }
}

({String mode, String term}) _parseCrystalSearchQuery(String raw) {
  final String normalized = raw.trim().toLowerCase();
  if (normalized.isEmpty || !normalized.startsWith('@')) {
    return (mode: 'all', term: normalized);
  }
  final RegExpMatch? match = RegExp(
    r'^@([a-z_]+)\s*(.*)$',
  ).firstMatch(normalized);
  if (match == null) {
    return (mode: 'all', term: normalized.substring(1).trim());
  }

  final String token = (match.group(1) ?? '').trim();
  final String term = (match.group(2) ?? '').trim();
  switch (token) {
    case 'name':
    case 'n':
      return (mode: 'name', term: term);
    case 'key':
    case 'k':
      return (mode: 'key', term: term);
    case 'type':
    case 't':
      return (mode: 'type', term: term);
    case 'color':
    case 'c':
      return (mode: 'color', term: term);
    case 'stat':
    case 'stats':
    case 'stat_key':
    case 'statkey':
    case 's':
      return (mode: 'stat', term: term);
    default:
      return (mode: 'all', term: term);
  }
}

bool _crystalStatKeyMatches({
  required CrystalLibraryEntry entry,
  required String query,
}) {
  final List<String> queryTokens = _normalizeCrystalStatTokens(query);
  if (queryTokens.isEmpty) {
    return false;
  }

  for (final EquipmentStat stat in entry.stats) {
    final List<String> statTokens = _normalizeCrystalStatTokens(stat.statKey);
    if (statTokens.isEmpty) {
      continue;
    }
    final bool tokenMatch = queryTokens.every((String queryToken) {
      return statTokens.any(
        (String statToken) =>
            statToken == queryToken || statToken.startsWith(queryToken),
      );
    });
    if (tokenMatch) {
      return true;
    }
  }
  return false;
}

bool _crystalTextFieldsMatch({
  required String query,
  required Iterable<String> fields,
}) {
  final List<String> queryTokens = _normalizeCrystalStatTokens(query);
  if (queryTokens.isEmpty) {
    return false;
  }
  final List<String> fieldTokens = <String>[];
  for (final String field in fields) {
    fieldTokens.addAll(_normalizeCrystalStatTokens(field));
  }
  if (fieldTokens.isEmpty) {
    return false;
  }
  return queryTokens.every((String queryToken) {
    return fieldTokens.any(
      (String fieldToken) =>
          fieldToken == queryToken || fieldToken.startsWith(queryToken),
    );
  });
}

List<String> _normalizeCrystalStatTokens(String value) {
  final String normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (normalized.isEmpty) {
    return const <String>[];
  }
  return normalized
      .split('_')
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);
}
