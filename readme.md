# AXI Dual-Port HyperBus Bridge

## Overview

This project implements a bridge between:

- one 64-bit AXI4 slave interface
- two 32-bit AXI4 master interfaces

The design is intended to sit above two HyperBus controller instances. Each
64-bit AXI beat is split into two 32-bit lane transactions and issued to both
masters in parallel.

The original requirements are captured in `doc/axi_dualport_hb_bridge.rtf`.

## Status

Design status: pending integration and verification in hardware.

## Data Mapping

- slave write `WDATA[31:0]` goes to master 0
- slave write `WDATA[63:32]` goes to master 1
- slave read `RDATA[31:0]` comes from master 0
- slave read `RDATA[63:32]` comes from master 1

The forwarded address is scaled by `addr >> 1` for both masters so the two
32-bit back-end transactions represent one 64-bit upstream beat.

## Supported Behavior

- 64-bit AXI4 slave interface
- two 32-bit AXI4 master interfaces
- bursts up to 32 beats
- one active write burst at a time
- one active read burst at a time
- slave-side full-width transfers only (`AWSIZE`/`ARSIZE == 3`)
- merged write response after both master `B` responses arrive
- merged read response after both lane buffers have matching data available
- tolerance for a one-cycle skew between the two read-data return paths

## Main Files

- `rtl/axi_dualport_hb_bridge.sv`
  - main bridge RTL
- `tb/axi_dualport_hb_bridge_tb.sv`
  - self-checking simulation
- `tb/axi32_ram_model.sv`
  - simple 32-bit AXI memory model used for verification
- `doc/axi_dualport_hb_bridge.rtf`
  - design request

## Verification

Run simulation:

```bash
iverilog -g2012 -o /tmp/axi_dualport_hb_bridge_tb.out \
  rtl/axi_dualport_hb_bridge.sv \
  tb/axi32_ram_model.sv \
  tb/axi_dualport_hb_bridge_tb.sv
vvp /tmp/axi_dualport_hb_bridge_tb.out
```

Run lint:

```bash
verilator --lint-only -Wall --timing \
  rtl/axi_dualport_hb_bridge.sv \
  tb/axi32_ram_model.sv \
  tb/axi_dualport_hb_bridge_tb.sv
```

Current test coverage includes:

- basic write/read striping
- masked write handling
- upper-lane-only masked updates
- mixed byte-enable updates across both 32-bit masters
- partial masked multi-beat bursts
- 32-beat maximum burst transfers
- upstream read backpressure
- one-cycle lane skew on read returns

## Notes

This implementation is intentionally conservative. It does not yet support
multiple outstanding transactions or true narrow transfers generated on the
32-bit master ports. Partial-width behavior is currently exercised through lane
byte strobes on the master side.
