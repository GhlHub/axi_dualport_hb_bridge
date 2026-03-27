// SPDX-FileCopyrightText: 2026 Glen Lowe
// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps

module axi32_ram_model #(
    parameter int AXI_ADDR_WIDTH = 32,
    parameter int AXI_ID_WIDTH   = 1,
    parameter int MEM_WORDS      = 256,
    parameter int READ_SKEW      = 0
) (
    input  wire                         i_axi_aclk,
    input  wire                         i_axi_aresetn,

    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire [AXI_ID_WIDTH-1:0]      s_axi_awid,
    input  wire [7:0]                   s_axi_awlen,
    input  wire [2:0]                   s_axi_awsize,
    input  wire [1:0]                   s_axi_awburst,
    input  wire                         s_axi_awvalid,
    output wire                         s_axi_awready,

    input  wire [31:0]                  s_axi_wdata,
    input  wire [3:0]                   s_axi_wstrb,
    input  wire                         s_axi_wlast,
    input  wire                         s_axi_wvalid,
    output wire                         s_axi_wready,

    output logic [1:0]                  s_axi_bresp,
    output logic [AXI_ID_WIDTH-1:0]     s_axi_bid,
    output logic                        s_axi_bvalid,
    input  wire                         s_axi_bready,

    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire [AXI_ID_WIDTH-1:0]      s_axi_arid,
    input  wire [7:0]                   s_axi_arlen,
    input  wire [2:0]                   s_axi_arsize,
    input  wire [1:0]                   s_axi_arburst,
    input  wire                         s_axi_arvalid,
    output wire                         s_axi_arready,

    output logic [31:0]                 s_axi_rdata,
    output logic [AXI_ID_WIDTH-1:0]     s_axi_rid,
    output logic [1:0]                  s_axi_rresp,
    output logic                        s_axi_rlast,
    output logic                        s_axi_rvalid,
    input  wire                         s_axi_rready
);
    localparam logic [1:0] AXI_RESP_OKAY = 2'b00;
    localparam int MEM_ADDR_W = (MEM_WORDS <= 2) ? 1 : $clog2(MEM_WORDS);

    logic                         wr_active_q;
    logic [AXI_ADDR_WIDTH-1:0]    wr_addr_q;
    logic [AXI_ID_WIDTH-1:0]      wr_id_q;
    logic [7:0]                   wr_beats_left_q;
    logic [2:0]                   wr_size_q;
    logic [1:0]                   wr_burst_q;

    logic                         rd_active_q;
    logic [AXI_ADDR_WIDTH-1:0]    rd_addr_q;
    logic [AXI_ID_WIDTH-1:0]      rd_id_q;
    logic [7:0]                   rd_beats_left_q;
    logic [2:0]                   rd_size_q;
    logic [1:0]                   rd_burst_q;
    logic [7:0]                   rd_skew_q;

    logic [31:0] mem [0:MEM_WORDS-1];

    function automatic logic [AXI_ADDR_WIDTH-1:0] f_next_addr(
        input logic [AXI_ADDR_WIDTH-1:0] addr,
        input logic [2:0]                size,
        input logic [1:0]                burst
    );
        logic [AXI_ADDR_WIDTH-1:0] incr;
        begin
            incr = AXI_ADDR_WIDTH'(1) << size;
            if (burst == 2'b00) begin
                f_next_addr = addr;
            end else begin
                f_next_addr = addr + incr;
            end
        end
    endfunction

    function automatic logic [31:0] f_apply_wstrb(
        input logic [31:0] old_data,
        input logic [31:0] new_data,
        input logic [3:0]  wstrb
    );
        begin
            f_apply_wstrb = old_data;
            if (wstrb[0]) f_apply_wstrb[7:0]   = new_data[7:0];
            if (wstrb[1]) f_apply_wstrb[15:8]  = new_data[15:8];
            if (wstrb[2]) f_apply_wstrb[23:16] = new_data[23:16];
            if (wstrb[3]) f_apply_wstrb[31:24] = new_data[31:24];
        end
    endfunction

    assign s_axi_awready = i_axi_aresetn && !wr_active_q && !s_axi_bvalid;
    assign s_axi_wready  = i_axi_aresetn && wr_active_q && !s_axi_bvalid;
    assign s_axi_arready = i_axi_aresetn && !rd_active_q;

    always_ff @(posedge i_axi_aclk) begin
        if (!i_axi_aresetn) begin
            s_axi_bresp <= AXI_RESP_OKAY;
            s_axi_bid <= '0;
            s_axi_bvalid <= 1'b0;
            s_axi_rdata <= '0;
            s_axi_rid <= '0;
            s_axi_rresp <= AXI_RESP_OKAY;
            s_axi_rlast <= 1'b0;
            s_axi_rvalid <= 1'b0;
            wr_active_q <= 1'b0;
            wr_addr_q <= '0;
            wr_id_q <= '0;
            wr_beats_left_q <= '0;
            wr_size_q <= 3'd2;
            wr_burst_q <= 2'b01;
            rd_active_q <= 1'b0;
            rd_addr_q <= '0;
            rd_id_q <= '0;
            rd_beats_left_q <= '0;
            rd_size_q <= 3'd2;
            rd_burst_q <= 2'b01;
            rd_skew_q <= READ_SKEW[7:0];
        end else begin
            if (s_axi_awvalid && s_axi_awready) begin
                wr_active_q <= 1'b1;
                wr_addr_q <= s_axi_awaddr;
                wr_id_q <= s_axi_awid;
                wr_beats_left_q <= s_axi_awlen + 8'd1;
                wr_size_q <= s_axi_awsize;
                wr_burst_q <= s_axi_awburst;
            end

            if (s_axi_wvalid && s_axi_wready) begin
                mem[wr_addr_q[MEM_ADDR_W+1:2]] <= f_apply_wstrb(
                    mem[wr_addr_q[MEM_ADDR_W+1:2]],
                    s_axi_wdata,
                    s_axi_wstrb
                );

                if (wr_beats_left_q == 8'd1) begin
                    wr_active_q <= 1'b0;
                    s_axi_bvalid <= 1'b1;
                    s_axi_bid <= wr_id_q;
                    s_axi_bresp <= AXI_RESP_OKAY;
                end else begin
                    wr_beats_left_q <= wr_beats_left_q - 8'd1;
                    wr_addr_q <= f_next_addr(wr_addr_q, wr_size_q, wr_burst_q);
                end
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                rd_active_q <= 1'b1;
                rd_addr_q <= s_axi_araddr;
                rd_id_q <= s_axi_arid;
                rd_beats_left_q <= s_axi_arlen + 8'd1;
                rd_size_q <= s_axi_arsize;
                rd_burst_q <= s_axi_arburst;
                rd_skew_q <= READ_SKEW[7:0];
            end

            if (rd_active_q && !s_axi_rvalid) begin
                if (rd_skew_q != 0) begin
                    rd_skew_q <= rd_skew_q - 8'd1;
                end else begin
                    s_axi_rvalid <= 1'b1;
                    s_axi_rid <= rd_id_q;
                    s_axi_rresp <= AXI_RESP_OKAY;
                    s_axi_rdata <= mem[rd_addr_q[MEM_ADDR_W+1:2]];
                    s_axi_rlast <= (rd_beats_left_q == 8'd1);
                end
            end

            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                if (rd_beats_left_q == 8'd1) begin
                    rd_active_q <= 1'b0;
                    s_axi_rlast <= 1'b0;
                end else begin
                    rd_beats_left_q <= rd_beats_left_q - 8'd1;
                    rd_addr_q <= f_next_addr(rd_addr_q, rd_size_q, rd_burst_q);
                end
            end
        end
    end

    wire unused_wlast = s_axi_wlast;

endmodule
