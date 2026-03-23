**Implementation Plan: Desktop UI for Memno**  
**Target Agent: Google Antigravity**  
**Version: 1.0 (March 2026)**  
**Project Goal:** Build a production-quality, native-feeling **Desktop UI** for Memno while preserving **100% of existing functionality** (Hive DB, Provider state, metadata fetching, 6-digit codes, import/export, OTA, sharing intent, etc.).

---

### 1. Project Overview & Success Criteria

**What we are building**  
A fully responsive/adaptive desktop experience that feels like a native Windows/macOS/Linux app:
- Master-Detail layout (sidebar list + large preview pane)
- Keyboard shortcuts (Ctrl+K search, Ctrl+N new, etc.)
- Drag & drop URL/files support
- Resizable window with proper title bar handling
- Hover states, tooltips, context menus
- Dark mode + glassmorphism preserved
- Same data & logic as mobile

**Non-goals (strictly forbidden)**  
- Do NOT rewrite any business logic, database, provider, or functionality code.  
- Do NOT create a separate Flutter project.  
- Do NOT break Android/iOS builds.

**Success Metrics**  
- Mobile UI remains 100% unchanged on phones/tablets.  
- Desktop build feels native (window size, shortcuts, drag-drop).  
- All existing features work identically.  
- APK size increase < 400 KB after tree-shaking.  
- Code is clean, well-commented, and follows 2026 Flutter best practices.

---

### 2. Detailed Project Structure (Clear Separation)

We will create a **clean separation** between Mobile UI and Desktop UI while sharing business logic.

```
lib/
├── core/                          # ← UNTOUCHED (existing)
│   ├── database/
│   ├── functionality/
│   ├── theme/
│   └── providers/                 # (move existing Provider logic here if not already)

├── ui/                            # ← NEW: All UI code goes here
│   ├── adaptive/
│   │   ├── adaptive_home.dart          # Main entry point (chooses mobile or desktop)
│   │   ├── responsive_breakpoints.dart
│   │   └── platform_utils.dart
│   │
│   ├── mobile/                     # ← Existing mobile UI (refactored here)
│   │   ├── screens/
│   │   │   ├── home_screen.dart        # (extracted from old home.dart)
│   │   │   ├── inner_page_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── sub_tile_mobile.dart
│   │   │   ├── custom_overlay_mobile.dart
│   │   │   └── bottom_nav.dart
│   │   └── mobile_home.dart            # Old home.dart content moved here
│   │
│   ├── desktop/                    # ← NEW: Desktop-specific UI
│   │   ├── screens/
│   │   │   ├── desktop_home_screen.dart   # Master-Detail layout
│   │   │   ├── desktop_inner_page.dart
│   │   │   └── desktop_settings.dart
│   │   ├── widgets/
│   │   │   ├── sidebar_list.dart          # Left panel with search + list
│   │   │   ├── preview_pane.dart          # Large right preview (reuse inner_page logic)
│   │   │   ├── desktop_app_bar.dart
│   │   │   ├── keyboard_shortcuts.dart
│   │   │   └── drop_target_overlay.dart
│   │   └── desktop_layout.dart
│   │
│   └── shared/                     # ← Reusable widgets & components
│       ├── widgets/
│       │   ├── link_preview_card.dart     # Used by both mobile & desktop
│       │   ├── toast_wrapper.dart
│       │   └── empty_state.dart
│       └── extensions/             # (e.g. responsive extensions)

├── main.dart                      # ← Updated (platform-aware entry)
├── routes.dart                    # (optional – for future navigation)
└── utils/
    └── desktop_window_manager.dart
```

**Important:**  
- All `lib/core/` and `lib/database/` remain **completely untouched**.  
- Only `lib/ui/` and `main.dart` will be modified/added.

---

### 3. Tech Stack & New Dependencies (Add to pubspec.yaml)

```yaml
dependencies:
  flutter_adaptive_scaffold: ^0.3.1          # Official Google adaptive layout
  window_manager: ^3.0.2                     # Window size, titlebar, always-on-top
  desktop_drop: ^0.4.3                       # Drag & drop URLs/files
  hotkey_manager: ^0.2.3                     # Global keyboard shortcuts
  flutter_staggered_grid_view: ^0.7.0        # Optional for nice desktop grids
```

Run `flutter pub get` after adding.

---

### 4. Implementation Phases (Follow in exact order)

**Phase 0 – Preparation (1–2 hours)**
- Create the `lib/ui/` folder structure exactly as shown above.
- Move existing `home.dart`, `inner_page.dart`, `settings_page.dart` into `lib/ui/mobile/screens/`.
- Rename them to `mobile_home.dart`, `mobile_inner_page.dart`, etc.
- Update all internal imports.

**Phase 1 – Main Entry & Adaptive Router (2 hours)**
- Update `lib/main.dart` to:
  - Initialize `window_manager` on desktop platforms.
  - Set minimum window size (1024×700).
  - Use `MediaQuery.sizeOf(context).width > 900 || Platform.isDesktop` to decide layout.
- Create `lib/ui/adaptive/adaptive_home.dart` (see sketch in Phase 3).

**Phase 2 – Desktop Master-Detail Layout (4–6 hours)**
- Build `desktop_home_screen.dart`:
  - Left sidebar (380 px wide): search + scrollable list of `SubTile` (reuse logic).
  - Right pane: large `PreviewPane` (reuse `inner_page` logic).
  - Use `flutter_adaptive_scaffold` + `Row` + `VerticalDivider`.
- Add hover effects, selection state, and keyboard navigation.

**Phase 3 – Desktop-Specific Features (3–4 hours)**
- Drag & drop support (`desktop_drop`).
- Keyboard shortcuts via `hotkey_manager`:
  - Ctrl/Cmd + K → focus search
  - Ctrl/Cmd + N → new link
  - Ctrl/Cmd + S → sync (if implemented later)
  - Esc → clear selection
- Custom desktop AppBar with window controls (minimize/maximize/close).
- Context menu on right-click of items.

**Phase 4 – Shared Components & Polish (2–3 hours)**
- Extract truly reusable widgets into `lib/ui/shared/`.
- Ensure glassmorphism, dark mode, and animations work on both platforms.
- Add responsive text scaling and padding.

**Phase 5 – Testing & Final Integration**
- Test on Windows, macOS, Linux.
- Verify mobile build is unchanged (`flutter build apk`).
- Run `flutter analyze` and fix all lints.

---

### 5. DOs and DON'Ts (Strict Rules)

**DO:**
- Reuse **every** existing Provider, Hive model, `functionality/` class, and business logic.
- Keep all state management in the existing Provider pattern.
- Use `flutter_adaptive_scaffold` for layout decisions.
- Make the desktop UI feel native (proper spacing, hover states, keyboard focus).
- Add comments explaining why a widget is in `desktop/` vs `mobile/`.
- Use `kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux` for platform checks.
- Follow Material 3 + your existing glassmorphism theme.

**DON'T:**
- Do NOT touch `lib/database/`, `lib/functionality/`, or any model class.
- Do NOT create new state management (no Riverpod, Bloc, etc.).
- Do NOT hardcode screen sizes — use `MediaQuery` and breakpoints.
- Do NOT duplicate code between mobile & desktop (extract to `shared/` when possible).
- Do NOT break any existing mobile feature or UI.
- Do NOT add Firebase, Supabase, or any backend.

---

### 6. Best Practices That MUST Be Followed

1. **Responsive-First Design**  
   Use `flutter_adaptive_scaffold` + `LayoutBuilder` + custom breakpoints (`<600 mobile`, `600-900 tablet`, `>900 desktop`).

2. **Performance**  
   - Use `const` constructors everywhere possible.  
   - Avoid rebuilding entire tree on every state change (use `Selector` from Provider).  
   - Lazy-load preview images.

3. **Accessibility**  
   - Add semantics labels.  
   - Support keyboard navigation fully.  
   - Respect system high-contrast mode.

4. **Code Quality**  
   - Follow official Flutter style guide + `flutter_lints`.  
   - Every new file must have header comment with purpose.  
   - Use named parameters and clear variable names.

5. **Desktop-Specific**  
   - Always use `window_manager` for window persistence.  
   - Handle `FocusNode` for keyboard shortcuts correctly.  
   - Use `desktop_drop` only inside desktop layout.

6. **Separation of Concerns**  
   - UI layer only contains widgets and layout.  
   - All data & logic stay in `core/`.

---

### 7. Final Deliverables Expected

- Complete `lib/ui/` folder with all files.
- Updated `main.dart` and any routing files.
- All new dependencies added and working.
- `README_DESKTOP.md` explaining how to run desktop builds.
- Screenshots of desktop UI (sidebar + preview pane in both light/dark mode).

---

**Ready to start?**

Copy this entire plan and begin implementation.  
When you finish a phase, reply with “Phase X complete” so we can review.

This plan guarantees:
- Zero breakage on mobile
- Beautiful native desktop experience
- Clean, maintainable, and scalable code

Let’s build something Memno users will love on desktop too!  

**Start with Phase 0 & Phase 1.**  
I’m standing by for any questions or code reviews.