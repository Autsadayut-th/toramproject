class CrystaGroup {
  String groupName;
  List<String> crystas;

  CrystaGroup(this.groupName, this.crystas);
}

class UpgradePath {
  String current;
  List<String> path;
  String finalCrysta;

  UpgradePath(
    this.current,
    this.path,
    this.finalCrysta,
  );
}

class AIUpgradePathFinder {

  List<CrystaGroup> groups;

  AIUpgradePathFinder(this.groups);

  CrystaGroup? findGroup(String crystaName) {

    for (int i = 0; i < groups.length; i++) {

      for (int j = 0; j < groups[i].crystas.length; j++) {

        if (groups[i].crystas[j] == crystaName) {
          return groups[i];
        }

      }

    }

    return null;
  }

  UpgradePath? findUpgradePath(String crystaName) {

    CrystaGroup? group = findGroup(crystaName);

    if (group == null) {
      return null;
    }

    List<String> path = [];

    for (int i = 0; i < group.crystas.length; i++) {
      path.add(group.crystas[i]);
    }

    String finalCrysta =
        group.crystas[group.crystas.length - 1];

    return UpgradePath(
      crystaName,
      path,
      finalCrysta,
    );
  }

  String explainUpgrade(UpgradePath path) {

    String text = "";

    text += "Crysta Upgrade Path\n\n";

    for (int i = 0; i < path.path.length; i++) {

      text += path.path[i];

      if (i < path.path.length - 1) {
        text += " → ";
      }

    }

    text += "\n\nFinal Crysta: ";
    text += path.finalCrysta;

    return text;
  }

}