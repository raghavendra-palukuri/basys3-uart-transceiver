# 📡 UART Transceiver — Full Duplex FPGA Implementation

![Platform](https://img.shields.io/badge/Platform-Basys3%20Artix--7-red)
![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue)
![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-orange)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## 📌 Overview
Full-duplex UART transceiver implemented in Verilog HDL on Basys3 (Artix-7) FPGA at 115200 baud rate. The design includes separate TX and RX modules each controlled by a 5-state FSM, with a 2-flip-flop synchronizer for CDC handling.

## 🏗️ System Architecture

```
Serial Input (RsRx)
      |
      v
2-FF Synchronizer (CDC)
      |
      v
UART_RX FSM
(IDLE → START_BIT → DATA_BITS → STOP_BIT → CLEANUP)
      |
      v
Received Byte → LED Display + 7-Segment

Switch Input (sw)
      |
      v
UART_TX FSM
(IDLE → START_BIT → DATA_BITS → STOP_BIT → CLEANUP)
      |
      v
Serial Output (RsTx)
```

## ✨ Features
- 5-state FSM for both TX and RX modules
- 2-flip-flop synchronizer for Clock Domain Crossing (CDC)
- Parameterized baud rate (CLKS_PER_BIT = 868 for 115200 baud)
- Received byte displayed on LEDs and 7-segment display
- Button-triggered transmission of switch value
- Loopback testbench with automated pass/fail checking

## 📁 Repository Structure

```
basys3-uart-transceiver/
├── src/
│   ├── Basys3_UART_Top.v    ← Top level module
│   ├── UART_RX.v            ← Receiver FSM
│   └── UART_TX.v            ← Transmitter FSM
├── testbench/
│   └── UART_TB.v            ← Loopback testbench
├── constraints/
│   └── basys3.xdc           ← Pin constraints
└── README.md
```

## 🔬 Key Concepts Demonstrated

| Concept | Where Used |
|---|---|
| 5-state FSM | UART_RX and UART_TX modules |
| CDC — 2-FF Synchronizer | UART_RX input stage |
| Parameterized design | CLKS_PER_BIT parameter |
| Baud rate generation | Clock counter in FSM |
| Loopback verification | UART_TB testbench |

## 🛠️ Tools & Platform

| Item | Details |
|---|---|
| FPGA Board | Digilent Basys3 (Artix-7 XC7A35T) |
| Language | Verilog HDL |
| Tool | Xilinx Vivado |
| Baud Rate | 115200 bps |
| Clock | 100 MHz |

## ▶️ How to Run

**Simulation:**
```
1. Open Vivado → Create Project
2. Add src/*.v as Design Sources
3. Add testbench/UART_TB.v as Simulation Source
4. Run Behavioral Simulation
5. Check $display output — PASS for 0x3F and 0xAB
```

**Hardware:**
```
1. Add constraints/basys3.xdc
2. Run Synthesis → Implementation → Generate Bitstream
3. Program Basys3 via Hardware Manager
4. Connect USB-UART adapter
5. Open PuTTY at 115200 baud — type characters
```

## 👤 Author
**Raghavendra Palukuri**  
M.Tech VLSI & ES — DIAT Pune (DRDO)  
📧 raghavapalukuri25p@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/raghavendra-palukuri)
