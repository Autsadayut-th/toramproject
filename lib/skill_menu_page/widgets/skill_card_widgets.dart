import 'package:flutter/material.dart';

import '../skill_menu_page.dart';

class SkillCardWidgets {
  static Widget buildInfoChip(String text, BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.surfaceContainerHighest,
            colorScheme.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget buildSkillImagePlaceholderContent(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.image_outlined,
          color: colorScheme.onSurface.withValues(alpha: 0.38),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          'Image',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.54),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  static Widget buildSkillImageBox(
    SkillEntry skill, {
    required double height,
    required BuildContext context,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imageAssetPath = skill.imageAssetPath;
    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.22),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imageAssetPath.isEmpty
          ? buildSkillImagePlaceholderContent(context)
          : Image.asset(
              imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  buildSkillImagePlaceholderContent(context),
            ),
    );
  }

  static Widget buildSkillDetailRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: TextStyle(color: colorScheme.onSurface)),
      trailing: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.75),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static void showSkillDetails(
    BuildContext context, {
    required SkillEntry skill,
    required String categoryName,
    required String treeName,
    required String Function(String) present,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (BuildContext context, ScrollController controller) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    skill.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$categoryName - $treeName',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildSkillImageBox(skill, height: 148, context: context),
                  const SizedBox(height: 14),
                  Divider(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 6),
                  buildSkillDetailRow(
                    context: context,
                    label: 'Unlock Level',
                    value: skill.unlockLevel?.toString() ?? '-',
                  ),
                  buildSkillDetailRow(
                    context: context,
                    label: 'MP',
                    value: present(skill.mp),
                  ),
                  buildSkillDetailRow(
                    context: context,
                    label: 'Type',
                    value: present(skill.type),
                  ),
                  buildSkillDetailRow(
                    context: context,
                    label: 'Element',
                    value: present(skill.element),
                  ),
                  buildSkillDetailRow(
                    context: context,
                    label: 'Combo',
                    value: present(skill.combo),
                  ),
                  buildSkillDetailRow(
                    context: context,
                    label: 'Combo Mid',
                    value: present(skill.comboMiddle),
                  ),
                  buildSkillDetailRow(
                    context: context,
                    label: 'Range',
                    value: present(skill.range),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: colorScheme.onSurface.withValues(alpha: 0.14)),
                  const SizedBox(height: 8),
                  Text(
                    'Description',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    present(skill.description),
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.92),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Color getCategoryColor(BuildContext context, String categoryName) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    switch (categoryName.toLowerCase()) {
      case 'weapon':
        return colorScheme.errorContainer;
      case 'buff':
        return colorScheme.tertiaryContainer;
      case 'assist':
        return colorScheme.secondaryContainer;
      default:
        return colorScheme.primaryContainer;
    }
  }

  static Widget buildSkillCard({
    required SkillEntry skill,
    required String categoryName,
    required String treeName,
    required String Function(String) present,
    required BuildContext context,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color categoryColor = getCategoryColor(context, categoryName);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showSkillDetails(
        context,
        skill: skill,
        categoryName: categoryName,
        treeName: treeName,
        present: present,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.surfaceContainerHigh,
              colorScheme.surfaceContainerHighest,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    skill.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    categoryName.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$treeName - Lv ${skill.unlockLevel?.toString() ?? '-'} - MP ${present(skill.mp)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            buildSkillImageBox(skill, height: 72, context: context),
            const SizedBox(height: 10),
            SizedBox(
              height: 24,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  buildInfoChip(
                    'Lv ${skill.unlockLevel?.toString() ?? '-'}',
                    context,
                  ),
                  const SizedBox(width: 6),
                  buildInfoChip('MP ${present(skill.mp)}', context),
                  const SizedBox(width: 6),
                  buildInfoChip(treeName, context),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              present(skill.type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.62),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              present(skill.element),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.62),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                present(skill.description),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Tap for details',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
