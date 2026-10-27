# Technical Specification & Context: sts_sim

## 1. Executive Summary & Core Objective

* **Project Name:** `sts_sim` (Standard Transfer Specification Simulator)

* **Target Platform:** Web (Flutter Web)

* **Primary Objective:** Provide a lightweight, intuitive visual simulation demonstrating
  Standard Transfer Specification (STS - IEC 62055-41 / IEC 62055-51) electricity prepaid meter
  token generation, decryption, offline credit validation, and replay attack prevention directly in the browser.

* **Philosophy:** Clean, interactive, offline-capable, and educational. Demonstrates how electricity prepaid meters validate recharge tokens without an internet connection.

## 2. Technical Stack & Architecture

### Core Tech Stack

* **Framework:** Flutter Web (Dart)

* **State Management:** `provider` (ChangeNotifier pattern)

* **Cryptography:** AES-128 Key Derivation & Token Cipher Engine, CRC-16 Checksum, STS Edition 2 Base Epoch (2014) Minute TID Counter

### Architecture Principles

1. **Separation of Concerns:** Isolated models (`meter_state`, `sts_token`, `appliance_load`), domain cryptographic services (`sts_crypto_service`, `tid_service`), state management (`simulation_provider`), and UI widgets.

2. **Web Compatibility:** 100% client-side Dart operations; no `dart:io` or native platform dependencies.

3. **Responsive Canvas & Dashboard:** Adaptive layout supporting Desktop, Tablet, and Mobile browser windows.

## 3. Key Operational Requirements & Features

### A. Utility Vending Terminal (POS)
* Inputs for Meter Serial Number (PAN), Supply Group Code (SGC), Tariff Rate (₦/kWh), and Purchase Amount (₦).
* Generates 20-digit STS tokens formatted as `XXXX - XXXX - XXXX - XXXX - XXXX`.
* Options to copy token or auto-key directly into meter keypad.

### B. Interactive Prepaid Meter
* Retro LCD display showing available balance (kWh), relay status (`CONNECTED` / `DISCONNECTED`), and keypad entry buffer / feedback messages (`ACCEPT`, `USED`, `REJECTED`, `E-01`).
* 12-key numeric keypad (`0-9`, `<` delete, `↵` enter).
* Status LEDs for Contactor Relay Power and Token Entry.

### C. Household Appliance Load Simulator
* Interactive appliance switches (Light Bulb, Refrigerator, Air Conditioner, Electric Heater).
* Real-time periodic ticker that discharges kWh balance according to active wattage.
* Automatic contactor relay tripping when balance reaches `0.00 kWh`, and automatic power restoration when a valid credit token is accepted.

### D. Cryptographic Inspector & Debugger
* Interactive step-by-step breakdown:
  1. Key Derivation ($VK + SGC + PAN \rightarrow DK$).
  2. Bit Payload Assembly (Class, Subclass, TID, Amount, CRC-16).
  3. AES-128 Encryption & 20-digit Encoding.
  4. Decryption, CRC-16 verification, and TID Replay Attack check.

## 4. Project Directory Structure

```
sts_sim/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── meter_state.dart
│   │   ├── sts_token.dart
│   │   ├── vending_transaction.dart
│   │   └── appliance_load.dart
│   ├── services/
│   │   ├── tid_service.dart
│   │   └── sts_crypto_service.dart
│   ├── providers/
│   │   └── simulation_provider.dart
│   └── ui/
│       ├── theme/
│       │   └── app_theme.dart
│       ├── home_screen.dart
│       └── widgets/
│           ├── vending_terminal_card.dart
│           ├── prepaid_meter_card.dart
│           ├── load_simulator_card.dart
│           └── crypto_inspector_card.dart
├── test/
│   ├── sts_crypto_service_test.dart
│   └── tid_service_test.dart
├── web/
└── pubspec.yaml
```
