# 🔠 FPGA-Based Morse Code Encoder

This project implements a **Morse Code Encoder** using **Verilog HDL** on the **Nexys A7 (or Nexys DDR4)** FPGA board. It translates numeric digits (0–9) into Morse code using **LED output**, and supports two modes of operation: **Digit Mode** (single digit encoding) and **Number Mode** (encoding a sequence of stored digits). The system is built around a clean, modular **Finite State Machine (FSM)** design and uses clock-accurate timing control to display Morse signals.

---

## 🔧 Features

* ✅ **Two Modes of Operation:**

  * **Digit Mode**: Encodes the current digit from switches directly.
  * **Number Mode**: Allows storing up to 6 digits and encodes them sequentially.
* ✅ **Morse Code LED Blinking:**

  * LED blinks `DOT` and `DASH` patterns corresponding to each digit.
* ✅ **Accurate Timing:**

  * DOT: 1 second
  * DASH: 3 seconds
  * GAP between signals: 0.5 seconds
  * GAP between digits: 10 seconds
* ✅ **Edge Detection** for buttons to initiate storing or sequence playback.
* ✅ Fully synchronous design using **100 MHz FPGA clock**.

---

## 🧠 Functional Overview

The system is designed as a finite state machine with states such as `IDLE`, `STORE`, `LOAD`, `SEND`, `GAP`, `DIGIT_GAP`, `NEXT_DIGIT`, and `DONE`.

### Operation Modes:

#### 🔢 Number Mode (Switch 4 = High)

* Press **BTN1** to store a digit (using SW\[3:0]).
* Press **BTN2** to start encoding all stored digits.

#### 🔤 Digit Mode (Switch 4 = Low)

* Press **BTN1** to immediately encode the digit on SW\[3:0].

---

## 🧰 Input/Output Mapping

| Signal                  | Description                          |
| ----------------------- | ------------------------------------ |
| `clk`                   | 100 MHz system clock                 |
| `rst` (BTN0)            | Reset button                         |
| `start_single` (BTN1)   | Store/Start digit based on mode      |
| `start_sequence` (BTN2) | Start encoding stored digits         |
| `digit_in` (SW0–SW3)    | 4-bit input for numeric digit        |
| `mode_select` (SW4)     | 0 = Digit mode, 1 = Number mode      |
| `led`                   | Output LED for Morse signal blinking |

---

## 📦 Morse Code Mapping for Digits

| Digit | Morse Code | Pattern (MSB to LSB) |
| ----- | ---------- | -------------------- |
| 0     | `-----`    | `11111`              |
| 1     | `.----`    | `01111`              |
| 2     | `..---`    | `00111`              |
| 3     | `...--`    | `00011`              |
| 4     | `....-`    | `00001`              |
| 5     | `.....`    | `00000`              |
| 6     | `-....`    | `10000`              |
| 7     | `--...`    | `11000`              |
| 8     | `---..`    | `11100`              |
| 9     | `----.`    | `11110`              |

---

## 🛠️ Tools Used

* 💡 **Vivado Design Suite** (for simulation & synthesis)
* 🖥️ **Nexys A7 / DDR4 FPGA Board**
* 📝 **Verilog HDL**
* 🔌 On-board **LEDs and Push Buttons** for I/O
