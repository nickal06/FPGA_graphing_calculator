# FPGA Quadratic & Polar Function Plotter

## Overview

This project implements a hardware-based function generator on an FPGA. The user enters the coefficients of a quadratic equation directly on the FPGA, which packages the data into a serial packet and transmits it over USB UART to a Python application. The Python application decodes the received data and plots either a Cartesian quadratic function or a polar function in real time.

The project demonstrates communication between digital hardware and software using UART, while combining FPGA design with Python-based data visualization.

---

## Features

* FPGA implementation of coefficient input logic
* USB UART communication between the FPGA and a computer
* Real-time transmission of function parameters
* Support for both Cartesian and polar plotting
* Automatic decoding of transmitted data in Python
* Graph generation using NumPy and Matplotlib

---

## Technologies Used

### Hardware

* Digilent Zybo Z7 FPGA
* Logisim Evolution
* Vivado
* VHDL

### Software

* Python 3
* PySerial
* NumPy
* Matplotlib

---

## Packet Format

The FPGA transmits a 16-bit packet over UART. Although only 13 bits contain useful information, the packet is padded to two bytes for UART transmission.

| Bits  | Description                  |
| ----- | ---------------------------- |
| 15–13 | Reserved (unused)            |
| 12    | Coordinate System            |
| 11–8  | Coefficient A (4-bit signed) |
| 7–4   | Coefficient B (4-bit signed) |
| 3–0   | Coefficient C (4-bit signed) |

### Coordinate Bit

* `0` — Cartesian Plot
* `1` — Polar Plot

### Coefficients

The coefficients **A**, **B**, and **C** are transmitted as 4-bit two's complement signed integers.

Range:

* Minimum: **-8**
* Maximum: **7**

---

## UART Configuration

| Setting   |  Value |
| --------- | -----: |
| Baud Rate | 115200 |
| Data Bits |      8 |
| Parity    |   None |
| Stop Bits |      1 |

---

## Python Visualization

The Python application continuously waits for two bytes from the FPGA.

After decoding the packet:

### Cartesian Mode

$$
y = Ax^2 + Bx + C
$$

The graph is displayed using Matplotlib over a configurable x-range.

### Polar Mode

$$
r = A\theta^2 + B\theta + C
$$

The graph is displayed on a polar axis.

---

## Project Structure

```text
FPGA-Function-Plotter/
│
├── Logisim/
│   └── Calculator.circ
│
├── VHDL/
│   ├── main.vhd
│   ├── calculator_fsm.vhd
│   └── uart_tx.vhd
│
├── Python/
│   └── plotter.py
│
├── Constraints/
│   └── zybo_z7.xdc
│
└── README.md
```
---

## Workflow

1. The user selects Cartesian or polar mode, then sequentially latches the 4-bit coefficients A, B, and C using the on-board switches and pushbuttons.

2. The FPGA packs the values into a 16-bit UART packet.

3. The UART transmitter sends the packet over USB.

4. Python receives the packet using PySerial.

5. The packet is decoded into the original coefficient values.

6. NumPy generates the function values.

7. Matplotlib displays the resulting graph.

---

## Learning Outcomes

This project demonstrates:

* FPGA digital design
* VHDL development
* UART serial communication
* Hardware/software co-design
* Data packet design
* Python serial communication
* Scientific plotting with NumPy and Matplotlib

---

## Future Improvements

* Continuous real-time graph updates
* Higher precision coefficient values
* Additional mathematical functions
* Interactive graphical user interface
* Bidirectional UART communication
* On-board LCD or HDMI output support

---

## Authors

Developed as an FPGA hardware/software integration project using Logisim Evolution, VHDL, Vivado, and Python.
