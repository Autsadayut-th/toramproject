import 'package:flutter/material.dart';

import '../skill_menu_page.dart';

class SkillCardWidgets {
  static Widget buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF666666), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Widget buildSkillImagePlaceholderContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.image_outlined, color: Colors.white38, size: 24),
        SizedBox(height: 4),
        Text('Image', style: TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  static Widget buildSkillImageBox(SkillEntry skill, {required double height}) {
    final String imageAssetPath = skill.imageAssetPath;
    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF666666), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imageAssetPath.isEmpty
          ? buildSkillImagePlaceholderContent()
          : Image.asset(
              imageAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => buildSkillImagePlaceholderContent(),
            ),
    );
  }

  static Widget buildSkillDetailRow({
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Colors.white70,
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
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF090909),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
                        color: const Color(0x55FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    skill.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$categoryName - $treeName',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  buildSkillImageBox(skill, height: 148),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x33FFFFFF)),
                  const SizedBox(height: 6),
                  buildSkillDetailRow(
                    label: 'Unlock Level',
                    value: skill.unlockLevel?.toString() ?? '-',
                  ),
                  buildSkillDetailRow(label: 'MP', value: present(skill.mp)),
                  buildSkillDetailRow(
                    label: 'Type',
                    value: present(skill.type),
                  ),
                  buildSkillDetailRow(
                    label: 'Element',
                    value: present(skill.element),
                  ),
                  buildSkillDetailRow(
                    label: 'Combo',
                    value: present(skill.combo),
                  ),
                  buildSkillDetailRow(
                    label: 'Combo Mid',
                    value: present(skill.comboMiddle),
                  ),
                  buildSkillDetailRow(
                    label: 'Range',
                    value: present(skill.range),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0x22FFFFFF)),
                  const SizedBox(height: 8),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    present(skill.description),
                    style: const TextStyle(
                      color: Color(0xFFE0E0E0),
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

  static Color getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'weapon':
        return const Color(0xFF8B1A1A);
      case 'buff':
        return const Color(0xFF1A3A6B);
      case 'assist':
        return const Color(0xFF1A5A3A);
      default:
        return const Color(0xFF4A4A4A);
    }
  }

  static Widget buildSkillCard({
    required SkillEntry skill,
    required String categoryName,
    required String treeName,
    required String Function(String) present,
    required BuildContext context,
  }) {
    final Color categoryColor = getCategoryColor(categoryName);

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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF666666), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        ),
                      ],
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
                    style: const TextStyle(
                      color: Colors.white,
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
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            buildSkillImageBox(skill, height: 72),
            const SizedBox(height: 10),
            SizedBox(
              height: 24,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  buildInfoChip('Lv ${skill.unlockLevel?.toString() ?? '-'}'),
                  const SizedBox(width: 6),
                  buildInfoChip('MP ${present(skill.mp)}'),
                  const SizedBox(width: 6),
                  buildInfoChip(treeName),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              present(skill.type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              present(skill.element),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
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
                style: const TextStyle(
                  color: Colors.white,
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
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF666666), width: 1),
              ),
              child: const Text(
                'Tap for details',
                style: TextStyle(
                  color: Colors.white,
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
