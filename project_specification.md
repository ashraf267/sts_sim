# Technical Specification & Context: sts_sim

## 1. Executive Summary & Core Objective

* **Project Name:** `sts_sim` (Standard Transfer Specification Simulator)

* **Target Platform:** Web (Flutter Web)

* **Primary Objective:** Provide a lightweight, intuitive visual simulation demonstrating
  standard-transfer-specification (STS) transfer operations, maneuvering, or interactions directly
  in the browser.

* **Philosophy:** Keep it simple, un-overengineered, robust, and clean. The goal is clear
  problem-solving and clean demonstration over complex architectural overhead.

## 2. Technical Stack & Architecture

### Core Tech Stack

* **Framework:** Flutter Web (Dart)

* **Rendering:** HTML/Canvas/CanvasKit (Targeting lightweight Web deployment)

* **State Management:** Simple `Provider` / `Notifier` pattern or lightweight `signals` (Avoid
  over-engineered heavy architectures like BLoC unless necessary).

### Architecture Principles

1. **Single Responsibility Components:** Keep UI views, simulation physics/math models, and control
   panels clearly separated.

2. **Minimal External Dependencies:** Rely primarily on core Flutter packages unless specialized
   math/canvas support is needed.

3. **Responsive Web Canvas:** Responsive layout tailored for desktop and tablet browsers.

## 3. Key Operational Requirements & Features

### A. Simulation Canvas

* Interactive visual viewport displaying 2+ vessel objects.

* Visual indicators for heading, velocity, distance vectors, and alignment/clearance zones.

### B. Dynamic Control Panel

* Simple controls to alter vessel parameters (e.g., speed, heading angle, distance/towing lines,
  rate of approach).

* Real-time updates reflected smoothly on screen.

### C. Metric & Status Display

* Real-time telemetry: Distance between vessels, relative speed, contact risk, mooring line
  tension/status (if applicable).

* Safety/Collision alerts or status indicators (e.g., Safe, Warning, Contact).

## 4. Coding Agent Conventions & Guidelines

When generating code or suggesting modifications for `sts_sim`:

1. **Simplicity First:** Prefer straightforward standard Flutter widgets and CustomPainters over
   heavy external visual engines.

2. **Clean Math Abstractions:** Keep mathematical calculations for distance, angle, and vector
   positions isolated in a simple `utils/` or `math/` helper file.

3. **Web Compatibility:** Avoid using `dart:io` or desktop/mobile native plugins. Use web-safe Dart
   libraries.

4. **Readable Code & Comments:** Keep function signatures clean, type-safe, and self-documenting.

## 5. Project Directory Blueprint

```
sts_sim/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── vessel.dart
│   │   └── simulation_state.dart
│   ├── painters/
│   │   └── simulation_painter.dart
│   ├── widgets/
│   │   ├── control_panel.dart
│   │   └── telemetry_overlay.dart
│   └── utils/
│       └── math_helpers.dart
├── web/
└── pubspec.yaml

```

## 6. Immediate Next Steps for AI Agent

1. Initialize core models (`Vessel`, `SimulationState`).

2. Implement a simple `CustomPainter` to render vessel icons/shapes and vector lines on canvas.

3. Build the primary interactive layout with a control panel sidebar and dynamic canvas viewport.