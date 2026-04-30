part of 'build_simulator_page.dart';

extension _BuildSimulatorCustomEquipment on BuildSimulatorScreenState {
  void _onUpsertCustomEquipment(Map<String, dynamic> rawItem) {
    final CustomEquipmentItem item = CustomEquipmentItem.fromJson(
      Map<String, dynamic>.from(rawItem),
    );
    if (!item.isValid) {
      return;
    }
    unawaited(_upsertCustomEquipment(item));
  }

  void _onDeleteCustomEquipmentById(String id) {
    unawaited(_deleteCustomEquipmentById(id));
  }

  Future<void> _openCustomEquipmentCreator({required String category}) async {
    if (!widget.isAuthenticated) {
      _showCustomEquipmentLoginPrompt();
      return;
    }

    final CustomEquipmentItem? item = await showDialog<CustomEquipmentItem>(
      context: context,
      builder: (BuildContext context) {
        return CustomEquipmentEditorDialog(initialCategory: category);
      },
    );

    if (item == null) {
      return;
    }

    await _createCustomEquipment(item);
  }

  CustomEquipmentItem? _findCustomEquipmentItemByKey(String? equipmentKey) {
    final String normalized = (equipmentKey ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return _customEquipmentItemByKey[normalized];
  }

  Future<void> _openCustomEquipmentEditorByKey(String? equipmentKey) async {
    final CustomEquipmentItem? initial = _findCustomEquipmentItemByKey(
      equipmentKey,
    );
    if (initial == null) {
      return;
    }

    final CustomEquipmentItem? updated = await showDialog<CustomEquipmentItem>(
      context: context,
      builder: (BuildContext context) {
        return CustomEquipmentEditorDialog(
          initialItem: initial,
          initialCategory: initial.category,
        );
      },
    );
    if (updated == null) {
      return;
    }

    await _upsertCustomEquipment(updated);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated custom item "${updated.name}".'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDeleteCustomEquipmentByKey(String? equipmentKey) async {
    final CustomEquipmentItem? target = _findCustomEquipmentItemByKey(
      equipmentKey,
    );
    if (target == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete custom item?'),
          content: Text('Delete "${target.name}" permanently?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    await _deleteCustomEquipmentById(target.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted custom item "${target.name}".'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<CustomEquipmentItem> _mergeCustomEquipmentItems({
    required List<CustomEquipmentItem> localItems,
    required List<CustomEquipmentItem> cloudItems,
  }) {
    final Map<String, CustomEquipmentItem> merged =
        <String, CustomEquipmentItem>{};

    void putBest(CustomEquipmentItem item) {
      if (!item.isValid) {
        return;
      }
      final String id = item.id.trim();
      if (id.isEmpty) {
        return;
      }
      final CustomEquipmentItem normalized = item.copyWith(
        category: CustomEquipmentMapper.normalizedCategory(item.category),
      );
      final CustomEquipmentItem? existing = merged[id];
      if (existing == null ||
          normalized.updatedAt.isAfter(existing.updatedAt)) {
        merged[id] = normalized;
      }
    }

    for (final CustomEquipmentItem item in localItems) {
      putBest(item);
    }
    for (final CustomEquipmentItem item in cloudItems) {
      putBest(item);
    }

    final List<CustomEquipmentItem> result =
        merged.values.toList(growable: false)
          ..sort((CustomEquipmentItem a, CustomEquipmentItem b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
    return result;
  }

  void _syncCustomEquipmentCache(List<CustomEquipmentItem> items) {
    final Map<String, EquipmentLibraryItem> byKey =
        <String, EquipmentLibraryItem>{};
    final Map<String, String> categoryByKey = <String, String>{};
    final Map<String, CustomEquipmentItem> customItemByKey =
        <String, CustomEquipmentItem>{};

    for (final CustomEquipmentItem item in items) {
      if (!item.isValid) {
        continue;
      }
      final EquipmentLibraryItem mapped =
          CustomEquipmentMapper.toEquipmentLibraryItem(item);
      final String key = mapped.key.trim().toLowerCase();
      if (key.isEmpty) {
        continue;
      }
      byKey[key] = mapped;
      categoryByKey[key] = CustomEquipmentMapper.normalizedCategory(
        item.category,
      );
      customItemByKey[key] = item;
    }

    _customEquipmentItemByKey = customItemByKey;
    _applyCustomEquipmentCache(byKey, categoryByKey);
  }

  Future<void> _syncCustomEquipmentItemsToCloud(
    List<CustomEquipmentItem> items,
  ) async {
    if (_activeUserId == null) {
      return;
    }
    await _firebaseCustomEquipmentService.saveItems(items);
    _loadedCustomEquipmentUserId = _activeUserId;
  }

  Future<void> _refreshCustomEquipmentAccess({bool force = false}) async {
    final String? activeUserId = _activeUserId;
    if (activeUserId == null) {
      _loadedCustomEquipmentUserId = null;
      _customEquipmentItemByKey = const <String, CustomEquipmentItem>{};
      _applyCustomEquipmentCache(
        const <String, EquipmentLibraryItem>{},
        const <String, String>{},
      );
      return;
    }

    if (!force && _loadedCustomEquipmentUserId == activeUserId) {
      return;
    }
    if (_isSyncingCustomEquipment) {
      return;
    }

    _isSyncingCustomEquipment = true;
    try {
      final List<CustomEquipmentItem> localItems =
          await _customEquipmentStorageService.loadItems();
      final List<CustomEquipmentItem> cloudItems =
          await _firebaseCustomEquipmentService.fetchItems();
      final List<CustomEquipmentItem> mergedItems = _mergeCustomEquipmentItems(
        localItems: localItems,
        cloudItems: cloudItems,
      );

      await _customEquipmentStorageService.saveItems(mergedItems);
      _syncCustomEquipmentCache(mergedItems);
      await _syncCustomEquipmentItemsToCloud(mergedItems);

      if (!mounted) {
        _loadedCustomEquipmentUserId = activeUserId;
        return;
      }
      _loadedCustomEquipmentUserId = activeUserId;
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Custom equipment sync',
        error: error,
        stackTrace: stackTrace,
      );
      try {
        await _customEquipmentStorageService.loadItems();
      } catch (_) {}
    } finally {
      _isSyncingCustomEquipment = false;
    }
  }

  Future<void> _upsertCustomEquipment(CustomEquipmentItem item) async {
    final List<CustomEquipmentItem> items = await _customEquipmentStorageService
        .upsertItem(item);
    _syncCustomEquipmentCache(items);
    try {
      await _syncCustomEquipmentItemsToCloud(items);
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Custom equipment cloud upsert',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _createCustomEquipment(CustomEquipmentItem item) async {
    if (!widget.isAuthenticated) {
      _showCustomEquipmentLoginPrompt();
      return;
    }

    await _upsertCustomEquipment(item);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved custom item "${item.name}".'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteCustomEquipmentById(String id) async {
    final String targetId = id.trim();
    if (targetId.isEmpty) {
      return;
    }
    final List<CustomEquipmentItem> items = await _customEquipmentStorageService
        .deleteItem(targetId);
    _syncCustomEquipmentCache(items);
    try {
      await _syncCustomEquipmentItemsToCloud(items);
    } catch (error, stackTrace) {
      _reportBackgroundLoadFailure(
        label: 'Custom equipment cloud delete',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _showCustomEquipmentLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Login required to save custom items.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Login',
          onPressed: () {
            if (!mounted) {
              return;
            }
            Navigator.of(context).pushNamed('/login');
          },
        ),
      ),
    );
  }
}
