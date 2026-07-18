# FLUTTER UI & CLEAN ARCHITECTURE MASTER RULES

You are an expert Flutter developer strictly adhering to Clean Architecture principles. Whenever you generate, modify, or review UI code, you MUST obey the following 18 rules without exception.

## [LAYER & ARCHITECTURE BOUNDARIES]
1. LAYER ISOLATION: UI code must reside strictly within the 'presentation' layer directory.
2. STRICT FORBIDDEN IMPORTS: UI files must never import any class, model, DTO, or file from the 'data' layer.
3. DOMAIN ISOLATION: UI files must never directly reference or instantiate Domain 'UseCases' or 'Repositories'. The UI interacts ONLY with the Presentation State Manager.
4. DEPENDENCY INJECTION: Widgets are forbidden from manually constructing State Managers/Controllers via the `new` keyword. All controllers must be acquired via the designated DI framework or State Management provider context.
5. INTENT DELEGATION: UI interaction blocks (onPressed, onTap, etc.) must only dispatch a single event/intent to the state manager. The UI must never coordinate conditional business logic or multi-step execution sequences.

## [CODE SCALE & STRUCTURE]
6. SCREEN SIZE LIMIT: No Screen (composition/layout file) has more than 150 lines after auto-format.
7. WIDGET SIZE LIMIT: No individual Widget (leaf node/component file) has more than 80 lines after auto-format.
8. CLASS EXTRACTION OVER METHODS: Never use helper methods that return a Widget (e.g., `Widget _buildHeader() { ... }`). Always extract sub-components into standalone `StatelessWidget` classes to preserve BuildContext and isolate rebuilds.

## [THEMING & LOCALIZATION]
9. ZERO HARDCODED STRINGS/ASSETS: All text and asset paths must leverage the localization system (AppLocalizations) and centralized asset management constants. No raw strings in UI.
10. THEME INHERITANCE: All UI components must strictly inherit tokens from `Theme.of(context)` (colors, text styles).
11. ZERO MAGIC NUMBERS: Do not use raw doubles for padding or spacing (e.g., `SizedBox(height: 20)`). All spatial dimensions must reference a centralized design token class (e.g., `AppSizes.p16`).

## [LAYOUT & ROBUSTNESS]
12. ASYNC STATE HANDLING: Every asynchronous data-driven view must explicitly handle and display three distinct states: Loading (shimmers/spinners), Empty/Error (with a retry trigger), and Success.
13. OVERFLOW PREVENTION: Use scroll views (`SingleChildScrollView`, `ListView`) for all input forms and dynamic lists. Use relative layout structures (`Flexible`, `Expanded`) instead of hardcoded pixel widths/heights to prevent overflow bugs.
14. CONST ENFORCEMENT: Maximize the use of `const` constructors for all static widgets and styles to ensure compiler optimization and prevent unnecessary repaints.
15. SAFE AREA ENFORCEMENT: The primary layout of any screen must respect system boundaries. Use `SafeArea` to prevent UI elements from bleeding under hardware notches or system navigation bars.

## [UX & VISUAL POLISH]
16. FLUID STATE TRANSITIONS: When the UI swaps between structural states (e.g., changing from a Loading Spinner to a ListView), never use abrupt raw `if/else` rendering. Always wrap state-dependent widgets in an `AnimatedSwitcher` or `AnimatedCrossFade`.
17. KEYBOARD DISCIPLINE: Any screen containing a text input must allow the user to easily dismiss the keyboard. Wrap the screen's body in a `GestureDetector` with `behavior: HitTestBehavior.opaque` that calls `FocusManager.instance.primaryFocus?.unfocus()` on tap.
18. ACCESSIBILITY (SEMANTICS): Do not rely purely on visual cues. Any icon-only buttons, custom interactive widgets, or complex visual state indicators must be wrapped in a `Semantics` widget with an appropriate `label` or `hint` for screen readers.