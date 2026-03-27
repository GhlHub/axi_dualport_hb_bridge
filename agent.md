# Agent Notes

## Purpose

This repository implements `rtl/axi_dualport_hb_bridge.sv`, a bridge that accepts
one 64-bit AXI4 slave interface and forwards traffic in parallel to two 32-bit
AXI4 master interfaces intended to connect to two HyperBus controller instances.

The split is lane-based:

- slave `WDATA[31:0]` / `RDATA[31:0]` map to master 0
- slave `WDATA[63:32]` / `RDATA[63:32]` map to master 1

Addressing is scaled by `addr >> 1` when forwarded to each 32-bit master so a
64-bit beat on the slave side becomes one 32-bit beat on each back-end lane.

## Current Behavioral Scope

- Single outstanding write transaction at a time
- Single outstanding read transaction at a time
- Slave-side data width fixed at 64 bits
- Master-side data width fixed at 32 bits per lane
- Burst length support up to 32 beats
- Slave-side full-width beats only (`AWSIZE`/`ARSIZE == 3`)
- `INCR` and legal `WRAP` bursts accepted at the slave interface
- Read-data recombination tolerates a one-cycle skew between the two master read
  channels by buffering both lanes before presenting a 64-bit beat upstream

## Repository Layout

- `rtl/axi_dualport_hb_bridge.sv`
  - bridge RTL
- `tb/axi_dualport_hb_bridge_tb.sv`
  - self-checking simulation
- `tb/axi32_ram_model.sv`
  - simple AXI memory model used by the testbench
- `doc/axi_dualport_hb_bridge.rtf`
  - original design request

## Verification

Primary checks covered by the testbench:

- basic 64-bit write/read striping across the two 32-bit masters
- masked writes using split `WSTRB`
- upper-lane-only and mixed byte-enable updates
- multi-beat partial masked bursts
- 32-beat maximum burst handling
- read backpressure on the 64-bit slave side
- one-cycle skew between the two 32-bit read return paths

Recommended commands:

```bash
iverilog -g2012 -o /tmp/axi_dualport_hb_bridge_tb.out \
  rtl/axi_dualport_hb_bridge.sv \
  tb/axi32_ram_model.sv \
  tb/axi_dualport_hb_bridge_tb.sv
vvp /tmp/axi_dualport_hb_bridge_tb.out

verilator --lint-only -Wall --timing \
  rtl/axi_dualport_hb_bridge.sv \
  tb/axi32_ram_model.sv \
  tb/axi_dualport_hb_bridge_tb.sv
```

## Integration Assumptions

- AXI clock is expected to be 50 MHz, matching the RTF request
- Attached HyperBus controllers are expected to present 32-bit AXI4 slave ports
- The attached back-end targets are assumed not to backpressure writes heavily
  and not to throttle reads in a way that breaks the intended parallel flow

## Change Guidance

- Preserve the lane mapping unless the memory striping model is intentionally
  changed system-wide
- If narrow master transactions are added later, update both the bridge RTL and
  the memory model/testbench to exercise `AWSIZE`/`ARSIZE` changes explicitly
- If multiple outstanding transactions are added, revisit response tracking and
  read-lane alignment rather than extending the current single-transaction state
  machine ad hoc
