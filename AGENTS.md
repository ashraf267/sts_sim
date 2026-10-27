# Agent Execution Guidelines & Flutter Web Best Practices

## MANDATORY RULE FOR AGENT WORKFLOW

**BEFORE writing code or making modifications to existing files, you MUST:**

1. **Generate a detailed Implementation Plan** outlining the proposed changes, affected files, state
   management impact, and web-specific considerations.
2. **Explicitly request user review and approval** for the implementation plan.
3. **Wait for explicit user approval** before writing or editing any line of code.

---

## Flutter Web Best Practices & Architecture Standards

### 1. Rendering & Performance Optimization

* **Renderer Selection:** Use `--web-renderer auto` for production or explicitly configure
  `canvaskit` for graphic-intensive tasks and `html` for light text-heavy pages where bundle size is
  critical.
* **Asset & Image Optimization:**
    * Use cached web images or SVGs (`flutter_svg`) where applicable.
    * Avoid uncompressed assets; optimize network image loads with appropriate caching headers.
* **Deferred Loading (Code Splitting):**
    * Use deferred loading for large packages or secondary feature modules to reduce initial JS
      bundle size:
      ```dart
      import 'package:deferred_package/deferred_package.dart' deferred as deferred_pkg;
      ```

### 2. Responsiveness & Screen Adaptation

* **Adaptive Layouts:** Design using `LayoutBuilder`, `MediaQuery`, or `Breakpoints` to support
  dynamic window resizing across desktop, tablet, and mobile web browsers.
* **Touch vs. Mouse Inputs:** Account for desktop hover states (`InkWell`, `MouseRegion`) alongside
  touch interactions.

### 3. Web Navigation & Routing

* **Declarative Routing:** Use GoRouter or AutoRoute to support browser URL sync, deep linking,
  query parameters, and browser back/forward buttons seamlessly.
* **URL Strategy:** Ensure `usePathUrlStrategy()` is initialized to eliminate the `#` hash from web
  URLs in modern browsers.

### 4. Memory Hygiene & Web Lifecycle

* **Dispose Controllers:** Always dispose `ScrollController`, `TextEditingController`, and
  `StreamSubscription` instances to prevent memory leaks in persistent web browser sessions.
* **Web Lifecycle Listeners:** Use `AppLifecycleListener` or `WidgetsBindingObserver` to handle
  browser tab switching, focus, and backgrounding states.

### 5. State Management & Architecture

* Maintain clean architectural boundaries (Presentation, Domain, Data layers).
* Decouple business logic from UI widgets using scalable state management (e.g., Riverpod, Bloc, or
  Provider).
* Ensure web persistent storage uses secure, web-compatible plugins (e.g., `shared_preferences` with
  web support or `hive` with web adapter).

---

## Agent Action Checklist

- [ ] Formulate and present an **Implementation Plan**.
- [ ] Ask: *"Would you like me to proceed with this implementation plan?"*
- [ ] Receive confirmation prior to executing code modifications.