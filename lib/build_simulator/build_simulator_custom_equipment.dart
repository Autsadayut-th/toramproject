part of 'build_simulator_page.dart';

extension _BuildSimulatorCustomEquipment on BuildSimulatorScreenState {
  Future<void> _openCustomEquipmentCreator({
    required String category,
  }) async {
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

  Future<void> _refreshCustomEquipmentAccess() async {
    if (!widget.isAuthenticated) {
      if (!mounted) {
        _customEquipmentCount = 0;
        return;
      }
      _setUiState(() {
        _customEquipmentCount = 0;
      });
      return;
    }

    final List<CustomEquipmentItem> items =
        await _customEquipmentStorageService.loadItems();
    if (!mounted) {
      _customEquipmentCount = items.length;
      return;
    }
    _setUiState(() {
      _customEquipmentCount = items.length;
    });
  }

  Future<void> _createCustomEquipment(CustomEquipmentItem item) async {
    if (!widget.isAuthenticated) {
      _showCustomEquipmentLoginPrompt();
      return;
    }

    final List<CustomEquipmentItem> items =
        await _customEquipmentStorageService.upsertItem(item);
    if (!mounted) {
      _customEquipmentCount = items.length;
      return;
    }
    _setUiState(() {
      _customEquipmentCount = items.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved custom item "${item.name}". Total custom items: ${items.length}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
