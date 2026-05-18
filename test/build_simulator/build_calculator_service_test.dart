import 'package:flutter_test/flutter_test.dart';
import 'package:toramonline/build_simulator/services/build_calculator_service.dart';
import 'package:toramonline/build_simulator/services/build_rule_set_service.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  const Map<String, dynamic> defaultCharacter = <String, dynamic>{
    'STR': 1,
    'DEX': 1,
    'INT': 1,
    'AGI': 1,
    'VIT': 1,
  };

  const Map<String, List<String>> emptySubWeaponRules =
      <String, List<String>>{};

  EquipmentLibraryItem weapon({
    required String key,
    required String type,
    List<EquipmentStat> stats = const <EquipmentStat>[],
  }) {
    return EquipmentLibraryItem(
      id: 1,
      key: key,
      name: key,
      color: 'unknown',
      type: type,
      stats: stats,
      imageAssetPath: '',
      obtainedFrom: const <EquipmentObtainedSource>[],
    );
  }

  Map<String, num> calculate({
    Map<String, dynamic> character = defaultCharacter,
    int level = 1,
    String personalStatType = 'CRT',
    int personalStatValue = 0,
    int enhanceMain = 0,
    int enhanceSub = 0,
    int enhanceArmor = 0,
    int enhanceHelmet = 0,
    int enhanceRing = 0,
    String armorState = 'normal',
    EquipmentLibraryItem? mainWeapon,
    EquipmentLibraryItem? subWeapon,
    EquipmentLibraryItem? armor,
    EquipmentLibraryItem? helmet,
    EquipmentLibraryItem? ring,
    Iterable<EquipmentStat> equippedCrystalStats = const <EquipmentStat>[],
    Iterable<EquipmentStat> avatarStats = const <EquipmentStat>[],
    Map<String, List<String>> mainToAllowedSubTypes = emptySubWeaponRules,
    BuildRuleSet? ruleSet,
  }) {
    return BuildCalculatorService.calculateSummary(
      character: character,
      level: level,
      personalStatType: personalStatType,
      personalStatValue: personalStatValue,
      enhanceMain: enhanceMain,
      enhanceSub: enhanceSub,
      enhanceArmor: enhanceArmor,
      enhanceHelmet: enhanceHelmet,
      enhanceRing: enhanceRing,
      armorState: armorState,
      mainWeapon: mainWeapon,
      subWeapon: subWeapon,
      armor: armor,
      helmet: helmet,
      ring: ring,
      equippedCrystalStats: equippedCrystalStats,
      avatarStats: avatarStats,
      mainToAllowedSubTypes: mainToAllowedSubTypes,
      ruleSet: ruleSet,
    );
  }

  group('BuildCalculatorService.calculateSummary', () {
    test(
      'bare-hand baseline uses default primary stats and weapon scaling',
      () {
        final Map<String, num> summary = calculate();

        expect(summary['STR'], 1);
        expect(summary['ATK'], 2);
        expect(summary['MATK'], 5);
        expect(summary['DEF'], 1);
        expect(summary['MDEF'], 1);
        expect(summary['ASPD'], 110);
        expect(summary['CSPD'], 5);
        expect(summary['FLEE'], 3);
        expect(summary['CritRate'], 25);
        expect(summary['Accuracy'], 2);
        expect(summary['HP'], 100);
        expect(summary['MP'], 100);
      },
    );

    test('dual 1H swords resolve to DUAL_SWORD combat type', () {
      final EquipmentLibraryItem main = weapon(
        key: 'main_sword',
        type: '1H_SWORD',
        stats: const <EquipmentStat>[
          EquipmentStat(statKey: 'weapon_atk', value: 10, valueType: 'base'),
        ],
      );
      final EquipmentLibraryItem sub = weapon(
        key: 'sub_sword',
        type: '1H_SWORD',
        stats: const <EquipmentStat>[
          EquipmentStat(statKey: 'weapon_atk', value: 5, valueType: 'base'),
        ],
      );

      final BuildCalculationContext context =
          BuildCalculatorService.buildCalculationContext(
            armorState: 'normal',
            mainWeapon: main,
            subWeapon: sub,
            armor: null,
            helmet: null,
            ring: null,
            equippedCrystalStats: const <EquipmentStat>[],
            avatarStats: const <EquipmentStat>[],
            mainToAllowedSubTypes: emptySubWeaponRules,
          );

      expect(context.combatWeaponType, 'DUAL_SWORD');
      expect(context.mainWeaponType, '1H_SWORD');
      expect(context.subWeaponType, '1H_SWORD');
      expect(context.mainWeaponAtkBase, 10);
      expect(context.supplementalWeaponAtkBase, 5);
    });

    test('CRT personal stat increases CritRate', () {
      final Map<String, num> summary = calculate(
        personalStatType: 'CRT',
        personalStatValue: 34,
      );

      expect(summary['CritRate'], 35);
    });

    test('TEC personal stat increases MP', () {
      final Map<String, num> summary = calculate(
        level: 50,
        character: const <String, dynamic>{
          'STR': 1,
          'DEX': 1,
          'INT': 100,
          'AGI': 1,
          'VIT': 1,
        },
        personalStatType: 'TEC',
        personalStatValue: 50,
      );

      expect(summary['MP'], 209);
    });

    test('heavy armor increases DEF contribution from VIT', () {
      final Map<String, num> summary = calculate(
        level: 10,
        character: const <String, dynamic>{
          'STR': 1,
          'DEX': 1,
          'INT': 1,
          'AGI': 1,
          'VIT': 10,
        },
        armorState: 'heavy',
        armor: weapon(key: 'heavy_armor', type: 'armor'),
      );

      expect(summary['DEF'], 20);
    });

    test('light armor increases MDEF contribution from INT', () {
      final Map<String, num> summary = calculate(
        level: 10,
        character: const <String, dynamic>{
          'STR': 1,
          'DEX': 1,
          'INT': 10,
          'AGI': 1,
          'VIT': 1,
        },
        armorState: 'light',
        armor: weapon(key: 'light_armor', type: 'armor'),
      );

      expect(summary['MDEF'], 20);
    });

    test('no armor applies VIT bonus to HP', () {
      final Map<String, num> summary = calculate(
        level: 100,
        character: const <String, dynamic>{
          'STR': 1,
          'DEX': 1,
          'INT': 1,
          'AGI': 1,
          'VIT': 30,
        },
        armorState: 'no_armor',
      );

      expect(summary['HP'], 1940);
    });

    test('main weapon refine increases ATK', () {
      final Map<String, num> summary = calculate(
        level: 1,
        character: const <String, dynamic>{
          'STR': 1,
          'DEX': 1,
          'INT': 1,
          'AGI': 1,
          'VIT': 1,
        },
        enhanceMain: 1,
        mainWeapon: weapon(
          key: 'refined_sword',
          type: '1H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 100, valueType: 'base'),
          ],
        ),
      );

      expect(summary['ATK'], 107);
    });

    test('equipment flat and percent bonuses affect derived stats', () {
      final Map<String, num> summary = calculate(
        level: 10,
        character: const <String, dynamic>{
          'STR': 10,
          'DEX': 10,
          'INT': 10,
          'AGI': 10,
          'VIT': 10,
        },
        mainWeapon: weapon(
          key: 'bonus_sword',
          type: '1H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 50, valueType: 'base'),
            EquipmentStat(statKey: 'str', value: 5, valueType: 'flat'),
            EquipmentStat(statKey: 'atk', value: 10, valueType: 'percent'),
          ],
        ),
      );

      expect(summary['STR'], 15);
      expect(summary['ATK'], 121);
    });

    test('crystal and avatar stats are included in summary', () {
      final Map<String, num> summary = calculate(
        level: 10,
        character: const <String, dynamic>{
          'STR': 10,
          'DEX': 10,
          'INT': 10,
          'AGI': 10,
          'VIT': 10,
        },
        mainWeapon: weapon(
          key: 'plain_sword',
          type: '1H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 20, valueType: 'base'),
          ],
        ),
        equippedCrystalStats: const <EquipmentStat>[
          EquipmentStat(statKey: 'dex', value: 3, valueType: 'flat'),
        ],
        avatarStats: const <EquipmentStat>[
          EquipmentStat(
            statKey: 'physical_pierce',
            value: 5,
            valueType: 'flat',
          ),
        ],
      );

      expect(summary['DEX'], 13);
      expect(summary['PhysicalPierce'], 5);
    });

    test(
      'point-based pierce stats add flat values instead of percent scaling',
      () {
        final Map<String, num> summary = calculate(
          level: 10,
          character: defaultCharacter,
          equippedCrystalStats: const <EquipmentStat>[
            EquipmentStat(
              statKey: 'physical_pierce',
              value: 12,
              valueType: 'flat',
            ),
            EquipmentStat(
              statKey: 'magic_pierce',
              value: 8,
              valueType: 'percent',
            ),
          ],
        );

        expect(summary['PhysicalPierce'], 12);
        expect(summary['MagicPierce'], 8);
        expect(summary['ElementPierce'], summary['MagicPierce']);
      },
    );

    test('conditional equipment stats respect weapon requirement', () {
      final EquipmentLibraryItem main = weapon(
        key: 'bow',
        type: 'BOW',
        stats: const <EquipmentStat>[
          EquipmentStat(statKey: 'weapon_atk', value: 10, valueType: 'base'),
          EquipmentStat(
            statKey: 'dex',
            value: 99,
            valueType: 'flat',
            condition: EquipmentStatCondition(weaponRequired: 'STAFF'),
          ),
          EquipmentStat(
            statKey: 'dex',
            value: 7,
            valueType: 'flat',
            condition: EquipmentStatCondition(weaponRequired: 'BOW'),
          ),
        ],
      );

      final Map<String, num> summary = calculate(
        level: 10,
        character: defaultCharacter,
        mainWeapon: main,
      );

      expect(summary['DEX'], 8);
    });

    test(
      'disallowed sub weapon type is ignored for supplemental weapon ATK',
      () {
        final EquipmentLibraryItem main = weapon(
          key: 'main_sword',
          type: '1H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 20, valueType: 'base'),
          ],
        );
        final EquipmentLibraryItem sub = weapon(
          key: 'invalid_sub',
          type: 'STAFF',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 50, valueType: 'base'),
          ],
        );

        final BuildCalculationContext context =
            BuildCalculatorService.buildCalculationContext(
              armorState: 'normal',
              mainWeapon: main,
              subWeapon: sub,
              armor: null,
              helmet: null,
              ring: null,
              equippedCrystalStats: const <EquipmentStat>[],
              avatarStats: const <EquipmentStat>[],
              mainToAllowedSubTypes: const <String, List<String>>{
                '1H_SWORD': <String>['1H_SWORD'],
              },
            );

        expect(context.isSubWeaponAllowed, isFalse);
        expect(context.supplementalWeaponAtkBase, 0);
      },
    );

    test(
      'sub weapon rules accept normalized aliases for main and sub weapon types',
      () {
        final EquipmentLibraryItem main = weapon(
          key: 'main_sword',
          type: '1H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 20, valueType: 'base'),
          ],
        );
        final EquipmentLibraryItem sub = weapon(
          key: 'sub_sword',
          type: '1H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 50, valueType: 'base'),
          ],
        );

        final BuildCalculationContext context =
            BuildCalculatorService.buildCalculationContext(
              armorState: 'normal',
              mainWeapon: main,
              subWeapon: sub,
              armor: null,
              helmet: null,
              ring: null,
              equippedCrystalStats: const <EquipmentStat>[],
              avatarStats: const <EquipmentStat>[],
              mainToAllowedSubTypes: const <String, List<String>>{
                'one hand sword': <String>['1h sword'],
              },
            );

        expect(context.isSubWeaponAllowed, isTrue);
        expect(context.supplementalWeaponAtkBase, 50);
      },
    );

    test(
      'calculateSummaryFromContext matches full calculateSummary pipeline',
      () {
        final EquipmentLibraryItem main = weapon(
          key: 'context_sword',
          type: '2H_SWORD',
          stats: const <EquipmentStat>[
            EquipmentStat(statKey: 'weapon_atk', value: 30, valueType: 'base'),
            EquipmentStat(statKey: 'str', value: 4, valueType: 'flat'),
          ],
        );
        final Map<String, dynamic> character = const <String, dynamic>{
          'STR': 20,
          'DEX': 5,
          'INT': 5,
          'AGI': 5,
          'VIT': 5,
        };

        final Map<String, num> direct = calculate(
          character: character,
          level: 40,
          enhanceMain: 2,
          mainWeapon: main,
          armor: weapon(
            key: 'armor',
            type: 'armor',
            stats: const <EquipmentStat>[
              EquipmentStat(statKey: 'def', value: 25, valueType: 'base'),
            ],
          ),
          enhanceArmor: 3,
          armorState: 'normal',
        );

        final BuildCalculationContext context =
            BuildCalculatorService.buildCalculationContext(
              armorState: 'normal',
              mainWeapon: main,
              subWeapon: null,
              armor: weapon(
                key: 'armor',
                type: 'armor',
                stats: const <EquipmentStat>[
                  EquipmentStat(statKey: 'def', value: 25, valueType: 'base'),
                ],
              ),
              helmet: null,
              ring: null,
              equippedCrystalStats: const <EquipmentStat>[],
              avatarStats: const <EquipmentStat>[],
              mainToAllowedSubTypes: emptySubWeaponRules,
            );

        final Map<String, num> fromContext =
            BuildCalculatorService.calculateSummaryFromContext(
              context: context,
              character: character,
              level: 40,
              personalStatType: 'CRT',
              personalStatValue: 0,
              enhanceMain: 2,
              enhanceSub: 0,
              enhanceArmor: 3,
              enhanceHelmet: 0,
              enhanceRing: 0,
              ruleSet: null,
            );

        expect(fromContext, direct);
      },
    );

    test('clamps invalid level and personal stat inputs', () {
      final Map<String, num> summary = calculate(
        level: 0,
        personalStatType: 'crt',
        personalStatValue: 999,
      );

      expect(summary['ATK'], 2);
      expect(summary['CritRate'], 25 + (255 / 3.4).truncate());
    });
  });
}
