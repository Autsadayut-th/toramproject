# AI System Architecture

This document defines the intended AI architecture for Toram build analysis and recommendation, and maps that design to the services currently used in this repository.

## Overview

The target design is a hybrid AI system:

- Rule-based AI for deterministic stat checking, thresholds, and recommendation scoring.
- LLM AI for natural-language explanation and player-facing guidance.

That means the system should be accurate at evaluation first, then readable at presentation.

## Target Pipeline

```text
Player Build
  -> Stat Calculator
  -> Rule Engine
  -> Build Analyzer
  -> Stat Optimizer
  -> Crysta Recommender / Equipment Recommender
  -> Upgrade Path Finder
  -> Explanation Engine
  -> Gemini Service
  -> Feedback System
```

## Target Modules

### `ai_recommendation_engine.dart`

Main coordinator. Responsible for invoking the other AI modules and returning one combined result payload for the UI.

### `ai_build_pipeline.dart`

Pipeline entrypoint for full build analysis:

1. Merge stats from character, equipment, crysta, avatar, and personal stats.
2. Calculate final stats.
3. Analyze build quality.
4. Detect missing or weak stats.
5. Request downstream recommendations.

### `ai_rule_engine.dart`

Loads and evaluates rule data such as:

- `assets/data/rules/build_rules.json`
- `assets/data/rules/build_evaluation_rules.json`
- `assets/data/rules/combat_rules.json`
- `assets/data/rules/crysta_slot_rules.json`
- `assets/data/rules/element_rules.json`
- `assets/data/rules/stat_scaling_rules.json`

This is the deterministic layer that answers questions like:

- Is Critical Rate high enough?
- Is Physical Pierce below threshold?
- Does the build match weapon scaling rules?

### `ai_stat_calculator.dart`

Aggregates and computes total build stats from:

- character stats
- equipment stats
- crysta stats
- avatar stats
- personal stats

### `ai_build_analyzer.dart`

Interprets calculated stats and rules into readable build evaluation:

- strengths
- weaknesses
- mismatches
- improvement opportunities

### `ai_stat_optimizer.dart`

Turns analysis into priority stat targets, such as:

- Critical Rate
- Physical Pierce
- Short Range Damage
- Max MP

### `ai_crysta_recommender.dart`

Suggests better crysta options based on missing stats, current slots, and upgrade lineage.

### `ai_equipment_recommender.dart`

Suggests weapon, armor, additional, and special gear that can cover missing stats or reinforce the intended build role.

### `ai_upgrade_path_finder.dart`

Finds crysta upgrade lines using crysta group data so the player can see the path from current crysta to end goal.

### `ai_explanation_engine.dart`

Converts structured recommendation data into readable text. It should support concise and detailed explanation modes.

### `ai_prompt_builder.dart`

Builds LLM prompts from structured build context so Gemini receives stable, compact, machine-prepared input rather than raw UI state.

### `ai_gemini_service.dart`

Calls Google Gemini and returns model output for:

- build explanation
- recommendation wording
- follow-up tips

### `ai_feedback_system.dart`

Stores recommendation feedback so the system can learn which suggestions help and which ones should be deprioritized later.

## Current Repository Mapping

The full `ai_*` module set is still not complete, but the core recommendation modules now exist inside this repository and are wired into the current simulator flow.

| Target module | Current implementation in repo | Status |
| --- | --- | --- |
| `ai_recommendation_engine.dart` | `lib/frontend/build_simulator/services/ai/ai_recommendation_engine.dart` with `lib/frontend/build_simulator/services/build_recommendation_service.dart` as compatibility wrapper | Present |
| `ai_build_pipeline.dart` | `lib/frontend/build_simulator/services/build_calculator_service.dart` plus `lib/frontend/build_simulator/services/build_recommendation_service.dart` | Partial |
| `ai_rule_engine.dart` | `lib/frontend/build_simulator/services/ai/ai_rule_engine.dart` plus `lib/frontend/build_simulator/services/build_rule_set_service.dart` for rule data loading | Present |
| `ai_stat_calculator.dart` | `lib/frontend/build_simulator/services/build_calculator_service.dart` | Present under different name |
| `ai_build_analyzer.dart` | `lib/frontend/build_simulator/services/ai/ai_build_analyzer.dart` | Present |
| `ai_stat_optimizer.dart` | `lib/frontend/build_simulator/services/ai/ai_stat_optimizer.dart` | Present |
| `ai_crysta_recommender.dart` | Crystal checks in `lib/frontend/build_simulator/services/build_recommendation_service.dart` and data loading in `lib/frontend/build_simulator/services/crystal_library_service.dart` | Partial |
| `ai_equipment_recommender.dart` | Equipment data is available, but no dedicated AI recommender class yet | Missing as separate module |
| `ai_upgrade_path_finder.dart` | `lib/frontend/build_simulator/services/crystal_library_service.dart` exposes `upgradeFrom`, but no full path finder yet | Partial |
| `ai_explanation_engine.dart` | Local text output in `build_recommendation_service.dart` and LLM wording through `api/recommend.js` | Partial |
| `ai_prompt_builder.dart` | `buildPromptText()` in `api/recommend.js` | Present under different name |
| `ai_gemini_service.dart` | Gemini integration in `api/recommend.js`; frontend caller in `lib/frontend/build_simulator/services/ai_build_recommendation_service.dart` | Present under split implementation |
| `ai_feedback_system.dart` | No persisted recommendation feedback loop in repo yet | Missing |

## Current Runtime Flow

Today, the app behaves like this:

1. `BuildCalculatorService` calculates build summary stats.
2. `BuildRuleSetService` loads combat/build/crysta/element/scaling rule JSON.
3. `BuildRecommendationService` forwards the request into the local AI modules in `lib/frontend/build_simulator/services/ai/`.
4. `AiBuildRecommendationService` sends compact build data to `/api/recommend`.
5. `api/recommend.js` builds a prompt and calls Gemini.
6. If Gemini fails, the app falls back to local recommendations.

This means the repository already uses the same core strategy as the target design:

- rules for correctness
- Gemini for explanation and wording

## External Prototype Files

The prototype files provided outside the repo:

- `ai_build_analyzer.dart`
- `ai_build_pipeline.dart`
- `ai_crysta_recommender.dart`
- `ai_equipment_recommender.dart`
- `ai_explanation_engine.dart`
- `ai_feedback_system.dart`
- `ai_gemini_service.dart`
- `ai_prompt_builder.dart`
- `ai_recommendation_engine.dart`
- `ai_rule_engine.dart`
- `ai_stat_calculator.dart`
- `ai_stat_optimizer.dart`
- `ai_upgrade_path_finder.dart`

still represent the larger target module boundary set, but several of their responsibilities are now covered by the in-repo AI modules under `lib/frontend/build_simulator/services/ai/`.

## Recommended Refactor Direction

If this architecture is adopted fully inside the repo, the next implementation steps should be:

1. Reuse current `BuildCalculatorService` as the base for `ai_stat_calculator.dart`.
2. Build crysta and equipment recommendation modules on top of the existing library services.
3. Add `ai_build_pipeline.dart` so UI code can ask for one structured AI result instead of raw recommendation strings.
4. Add `ai_upgrade_path_finder.dart` using the existing crystal upgrade metadata.
5. Add `ai_explanation_engine.dart` so local AI can produce structured short/normal/full explanations before hitting Gemini.
6. Add a persistent `ai_feedback_system.dart` only after recommendation identity and storage shape are defined.

## Architecture Decision

The intended direction for this project is:

**Rule-Based AI + LLM AI**

- Rule engine for precise build evaluation.
- Gemini for explanation, phrasing, and player guidance.

That is the correct direction for a game build assistant because the scoring logic must stay deterministic while the player-facing output remains flexible and readable.
