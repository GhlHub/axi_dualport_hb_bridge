// SPDX-FileCopyrightText: 2026 Glen Lowe
// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps

module axi_dualport_hb_bridge #(
    parameter int AXI_ADDR_WIDTH   = 32,
    parameter int AXI_ID_WIDTH     = 1,
    parameter int MAX_BURST_BEATS  = 32
) (
    input  wire                         i_axi_aclk,
    input  wire                         i_axi_aresetn,

    // 64-bit AXI4 full slave.
    input  wire [AXI_ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire [AXI_ID_WIDTH-1:0]      s_axi_awid,
    input  wire [7:0]                   s_axi_awlen,
    input  wire [2:0]                   s_axi_awsize,
    input  wire [1:0]                   s_axi_awburst,
    input  wire                         s_axi_awvalid,
    output wire                         s_axi_awready,

    input  wire [63:0]                  s_axi_wdata,
    input  wire [7:0]                   s_axi_wstrb,
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

    output logic [63:0]                 s_axi_rdata,
    output logic [AXI_ID_WIDTH-1:0]     s_axi_rid,
    output logic [1:0]                  s_axi_rresp,
    output logic                        s_axi_rlast,
    output logic                        s_axi_rvalid,
    input  wire                         s_axi_rready,

    // 32-bit AXI4 full master 0.
    output logic [AXI_ADDR_WIDTH-1:0]   m0_axi_awaddr,
    output logic [AXI_ID_WIDTH-1:0]     m0_axi_awid,
    output logic [7:0]                  m0_axi_awlen,
    output logic [2:0]                  m0_axi_awsize,
    output logic [1:0]                  m0_axi_awburst,
    output logic                        m0_axi_awvalid,
    input  wire                         m0_axi_awready,

    output logic [31:0]                 m0_axi_wdata,
    output logic [3:0]                  m0_axi_wstrb,
    output logic                        m0_axi_wlast,
    output logic                        m0_axi_wvalid,
    input  wire                         m0_axi_wready,

    input  wire [1:0]                   m0_axi_bresp,
    input  wire [AXI_ID_WIDTH-1:0]      m0_axi_bid,
    input  wire                         m0_axi_bvalid,
    output wire                         m0_axi_bready,

    output logic [AXI_ADDR_WIDTH-1:0]   m0_axi_araddr,
    output logic [AXI_ID_WIDTH-1:0]     m0_axi_arid,
    output logic [7:0]                  m0_axi_arlen,
    output logic [2:0]                  m0_axi_arsize,
    output logic [1:0]                  m0_axi_arburst,
    output logic                        m0_axi_arvalid,
    input  wire                         m0_axi_arready,

    input  wire [31:0]                  m0_axi_rdata,
    input  wire [AXI_ID_WIDTH-1:0]      m0_axi_rid,
    input  wire [1:0]                   m0_axi_rresp,
    input  wire                         m0_axi_rlast,
    input  wire                         m0_axi_rvalid,
    output wire                         m0_axi_rready,

    // 32-bit AXI4 full master 1.
    output logic [AXI_ADDR_WIDTH-1:0]   m1_axi_awaddr,
    output logic [AXI_ID_WIDTH-1:0]     m1_axi_awid,
    output logic [7:0]                  m1_axi_awlen,
    output logic [2:0]                  m1_axi_awsize,
    output logic [1:0]                  m1_axi_awburst,
    output logic                        m1_axi_awvalid,
    input  wire                         m1_axi_awready,

    output logic [31:0]                 m1_axi_wdata,
    output logic [3:0]                  m1_axi_wstrb,
    output logic                        m1_axi_wlast,
    output logic                        m1_axi_wvalid,
    input  wire                         m1_axi_wready,

    input  wire [1:0]                   m1_axi_bresp,
    input  wire [AXI_ID_WIDTH-1:0]      m1_axi_bid,
    input  wire                         m1_axi_bvalid,
    output wire                         m1_axi_bready,

    output logic [AXI_ADDR_WIDTH-1:0]   m1_axi_araddr,
    output logic [AXI_ID_WIDTH-1:0]     m1_axi_arid,
    output logic [7:0]                  m1_axi_arlen,
    output logic [2:0]                  m1_axi_arsize,
    output logic [1:0]                  m1_axi_arburst,
    output logic                        m1_axi_arvalid,
    input  wire                         m1_axi_arready,

    input  wire [31:0]                  m1_axi_rdata,
    input  wire [AXI_ID_WIDTH-1:0]      m1_axi_rid,
    input  wire [1:0]                   m1_axi_rresp,
    input  wire                         m1_axi_rlast,
    input  wire                         m1_axi_rvalid,
    output wire                         m1_axi_rready
);
    localparam int FIFO_PTR_W = (MAX_BURST_BEATS <= 2) ? 1 : $clog2(MAX_BURST_BEATS);
    localparam logic [1:0] AXI_RESP_OKAY   = 2'b00;
    localparam logic [1:0] AXI_RESP_SLVERR = 2'b10;
    localparam logic [7:0] MAX_BURST_BEATS_U8 = MAX_BURST_BEATS[7:0];
    localparam logic [FIFO_PTR_W:0] MAX_BURST_COUNT = MAX_BURST_BEATS[FIFO_PTR_W:0];

    logic                        wr_active_q;
    logic [AXI_ID_WIDTH-1:0]     wr_id_q;
    logic [7:0]                  wr_len_q;
    logic [7:0]                  wr_beats_rcvd_q;
    logic                        wr_proto_err_q;
    logic                        wr_m0_b_seen_q;
    logic                        wr_m1_b_seen_q;
    logic [1:0]                  wr_m0_bresp_q;
    logic [1:0]                  wr_m1_bresp_q;

    logic                        rd_active_q;
    logic [AXI_ID_WIDTH-1:0]     rd_id_q;
    logic [7:0]                  rd_beats_left_q;
    logic [31:0]                 rd_lane0_data_mem [0:MAX_BURST_BEATS-1];
    logic [31:0]                 rd_lane1_data_mem [0:MAX_BURST_BEATS-1];
    logic [1:0]                  rd_lane0_resp_mem [0:MAX_BURST_BEATS-1];
    logic [1:0]                  rd_lane1_resp_mem [0:MAX_BURST_BEATS-1];
    logic [FIFO_PTR_W-1:0]       rd_lane0_wr_ptr_q;
    logic [FIFO_PTR_W-1:0]       rd_lane0_rd_ptr_q;
    logic [FIFO_PTR_W-1:0]       rd_lane1_wr_ptr_q;
    logic [FIFO_PTR_W-1:0]       rd_lane1_rd_ptr_q;
    logic [FIFO_PTR_W:0]         rd_lane0_count_q;
    logic [FIFO_PTR_W:0]         rd_lane1_count_q;

    function automatic logic f_is_wrap_len_legal(input logic [7:0] len);
        begin
            f_is_wrap_len_legal = (len == 8'd1) || (len == 8'd3) ||
                                  (len == 8'd7) || (len == 8'd15);
        end
    endfunction

    function automatic logic [1:0] f_worst_resp(
        input logic [1:0] a,
        input logic [1:0] b
    );
        begin
            f_worst_resp = (a >= b) ? a : b;
        end
    endfunction

    function automatic logic [AXI_ADDR_WIDTH-1:0] f_scaled_addr(
        input logic [AXI_ADDR_WIDTH-1:0] addr
    );
        begin
            // 64-bit beats on the slave side become 32-bit beats on each lane.
            f_scaled_addr = addr >> 1;
        end
    endfunction

    wire write_req_ok = (s_axi_awsize == 3'd3) &&
                        ((s_axi_awburst == 2'b01) ||
                         ((s_axi_awburst == 2'b10) && f_is_wrap_len_legal(s_axi_awlen))) &&
                        (s_axi_awlen < MAX_BURST_BEATS_U8);
    wire read_req_ok  = (s_axi_arsize == 3'd3) &&
                        ((s_axi_arburst == 2'b01) ||
                         ((s_axi_arburst == 2'b10) && f_is_wrap_len_legal(s_axi_arlen))) &&
                        (s_axi_arlen < MAX_BURST_BEATS_U8);

    wire wr_aw_sent = wr_active_q && !m0_axi_awvalid && !m1_axi_awvalid;
    wire wr_data_done = wr_active_q &&
                        (wr_beats_rcvd_q > wr_len_q) &&
                        !m0_axi_wvalid && !m1_axi_wvalid;

    assign s_axi_awready = i_axi_aresetn &&
                           !wr_active_q &&
                           !rd_active_q &&
                           !s_axi_bvalid &&
                           write_req_ok;

    assign s_axi_wready = i_axi_aresetn &&
                          wr_active_q &&
                          wr_aw_sent &&
                          !m0_axi_wvalid &&
                          !m1_axi_wvalid &&
                          (wr_beats_rcvd_q <= wr_len_q);

    assign s_axi_arready = i_axi_aresetn &&
                           !wr_active_q &&
                           !rd_active_q &&
                           !s_axi_rvalid &&
                           !s_axi_awvalid &&
                           read_req_ok;

    assign m0_axi_bready = wr_data_done && !wr_m0_b_seen_q && !s_axi_bvalid;
    assign m1_axi_bready = wr_data_done && !wr_m1_b_seen_q && !s_axi_bvalid;

    assign m0_axi_rready = rd_active_q && (rd_lane0_count_q < MAX_BURST_COUNT);
    assign m1_axi_rready = rd_active_q && (rd_lane1_count_q < MAX_BURST_COUNT);

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

            m0_axi_awaddr <= '0;
            m0_axi_awid <= '0;
            m0_axi_awlen <= '0;
            m0_axi_awsize <= 3'd2;
            m0_axi_awburst <= 2'b01;
            m0_axi_awvalid <= 1'b0;
            m0_axi_wdata <= '0;
            m0_axi_wstrb <= '0;
            m0_axi_wlast <= 1'b0;
            m0_axi_wvalid <= 1'b0;
            m0_axi_araddr <= '0;
            m0_axi_arid <= '0;
            m0_axi_arlen <= '0;
            m0_axi_arsize <= 3'd2;
            m0_axi_arburst <= 2'b01;
            m0_axi_arvalid <= 1'b0;

            m1_axi_awaddr <= '0;
            m1_axi_awid <= '0;
            m1_axi_awlen <= '0;
            m1_axi_awsize <= 3'd2;
            m1_axi_awburst <= 2'b01;
            m1_axi_awvalid <= 1'b0;
            m1_axi_wdata <= '0;
            m1_axi_wstrb <= '0;
            m1_axi_wlast <= 1'b0;
            m1_axi_wvalid <= 1'b0;
            m1_axi_araddr <= '0;
            m1_axi_arid <= '0;
            m1_axi_arlen <= '0;
            m1_axi_arsize <= 3'd2;
            m1_axi_arburst <= 2'b01;
            m1_axi_arvalid <= 1'b0;

            wr_active_q <= 1'b0;
            wr_id_q <= '0;
            wr_len_q <= '0;
            wr_beats_rcvd_q <= '0;
            wr_proto_err_q <= 1'b0;
            wr_m0_b_seen_q <= 1'b0;
            wr_m1_b_seen_q <= 1'b0;
            wr_m0_bresp_q <= AXI_RESP_OKAY;
            wr_m1_bresp_q <= AXI_RESP_OKAY;

            rd_active_q <= 1'b0;
            rd_id_q <= '0;
            rd_beats_left_q <= '0;
            rd_lane0_wr_ptr_q <= '0;
            rd_lane0_rd_ptr_q <= '0;
            rd_lane1_wr_ptr_q <= '0;
            rd_lane1_rd_ptr_q <= '0;
            rd_lane0_count_q <= '0;
            rd_lane1_count_q <= '0;
        end else begin
            if (m0_axi_awvalid && m0_axi_awready) begin
                m0_axi_awvalid <= 1'b0;
            end
            if (m1_axi_awvalid && m1_axi_awready) begin
                m1_axi_awvalid <= 1'b0;
            end
            if (m0_axi_wvalid && m0_axi_wready) begin
                m0_axi_wvalid <= 1'b0;
            end
            if (m1_axi_wvalid && m1_axi_wready) begin
                m1_axi_wvalid <= 1'b0;
            end
            if (m0_axi_arvalid && m0_axi_arready) begin
                m0_axi_arvalid <= 1'b0;
            end
            if (m1_axi_arvalid && m1_axi_arready) begin
                m1_axi_arvalid <= 1'b0;
            end

            if (s_axi_awvalid && s_axi_awready) begin
                wr_active_q <= 1'b1;
                wr_id_q <= s_axi_awid;
                wr_len_q <= s_axi_awlen;
                wr_beats_rcvd_q <= 8'd0;
                wr_proto_err_q <= 1'b0;
                wr_m0_b_seen_q <= 1'b0;
                wr_m1_b_seen_q <= 1'b0;
                wr_m0_bresp_q <= AXI_RESP_OKAY;
                wr_m1_bresp_q <= AXI_RESP_OKAY;

                m0_axi_awaddr <= f_scaled_addr(s_axi_awaddr);
                m0_axi_awid <= s_axi_awid;
                m0_axi_awlen <= s_axi_awlen;
                m0_axi_awsize <= 3'd2;
                m0_axi_awburst <= s_axi_awburst;
                m0_axi_awvalid <= 1'b1;

                m1_axi_awaddr <= f_scaled_addr(s_axi_awaddr);
                m1_axi_awid <= s_axi_awid;
                m1_axi_awlen <= s_axi_awlen;
                m1_axi_awsize <= 3'd2;
                m1_axi_awburst <= s_axi_awburst;
                m1_axi_awvalid <= 1'b1;
            end

            if (s_axi_wvalid && s_axi_wready) begin
                m0_axi_wdata <= s_axi_wdata[31:0];
                m0_axi_wstrb <= s_axi_wstrb[3:0];
                m0_axi_wlast <= s_axi_wlast;
                m0_axi_wvalid <= 1'b1;

                m1_axi_wdata <= s_axi_wdata[63:32];
                m1_axi_wstrb <= s_axi_wstrb[7:4];
                m1_axi_wlast <= s_axi_wlast;
                m1_axi_wvalid <= 1'b1;

                if (((wr_beats_rcvd_q == wr_len_q) && !s_axi_wlast) ||
                    ((wr_beats_rcvd_q != wr_len_q) && s_axi_wlast)) begin
                    wr_proto_err_q <= 1'b1;
                end

                wr_beats_rcvd_q <= wr_beats_rcvd_q + 8'd1;
            end

            if (m0_axi_bvalid && m0_axi_bready) begin
                wr_m0_b_seen_q <= 1'b1;
                wr_m0_bresp_q <= m0_axi_bresp;
            end
            if (m1_axi_bvalid && m1_axi_bready) begin
                wr_m1_b_seen_q <= 1'b1;
                wr_m1_bresp_q <= m1_axi_bresp;
            end

            if (!s_axi_bvalid && wr_active_q && wr_m0_b_seen_q && wr_m1_b_seen_q) begin
                s_axi_bvalid <= 1'b1;
                s_axi_bid <= wr_id_q;
                s_axi_bresp <= f_worst_resp(
                    wr_proto_err_q ? AXI_RESP_SLVERR : wr_m0_bresp_q,
                    wr_proto_err_q ? AXI_RESP_SLVERR : wr_m1_bresp_q
                );
            end
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
                wr_active_q <= 1'b0;
                wr_m0_b_seen_q <= 1'b0;
                wr_m1_b_seen_q <= 1'b0;
                wr_proto_err_q <= 1'b0;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                rd_active_q <= 1'b1;
                rd_id_q <= s_axi_arid;
                rd_beats_left_q <= s_axi_arlen + 8'd1;
                rd_lane0_wr_ptr_q <= '0;
                rd_lane0_rd_ptr_q <= '0;
                rd_lane1_wr_ptr_q <= '0;
                rd_lane1_rd_ptr_q <= '0;
                rd_lane0_count_q <= '0;
                rd_lane1_count_q <= '0;
                s_axi_rvalid <= 1'b0;
                s_axi_rlast <= 1'b0;

                m0_axi_araddr <= f_scaled_addr(s_axi_araddr);
                m0_axi_arid <= s_axi_arid;
                m0_axi_arlen <= s_axi_arlen;
                m0_axi_arsize <= 3'd2;
                m0_axi_arburst <= s_axi_arburst;
                m0_axi_arvalid <= 1'b1;

                m1_axi_araddr <= f_scaled_addr(s_axi_araddr);
                m1_axi_arid <= s_axi_arid;
                m1_axi_arlen <= s_axi_arlen;
                m1_axi_arsize <= 3'd2;
                m1_axi_arburst <= s_axi_arburst;
                m1_axi_arvalid <= 1'b1;
            end

            if (m0_axi_rvalid && m0_axi_rready) begin
                rd_lane0_data_mem[rd_lane0_wr_ptr_q] <= m0_axi_rdata;
                rd_lane0_resp_mem[rd_lane0_wr_ptr_q] <= m0_axi_rresp;
                rd_lane0_wr_ptr_q <= rd_lane0_wr_ptr_q + FIFO_PTR_W'(1);
                rd_lane0_count_q <= rd_lane0_count_q + (FIFO_PTR_W+1)'(1);
            end
            if (m1_axi_rvalid && m1_axi_rready) begin
                rd_lane1_data_mem[rd_lane1_wr_ptr_q] <= m1_axi_rdata;
                rd_lane1_resp_mem[rd_lane1_wr_ptr_q] <= m1_axi_rresp;
                rd_lane1_wr_ptr_q <= rd_lane1_wr_ptr_q + FIFO_PTR_W'(1);
                rd_lane1_count_q <= rd_lane1_count_q + (FIFO_PTR_W+1)'(1);
            end

            if (!s_axi_rvalid &&
                rd_active_q &&
                !m0_axi_rvalid &&
                !m1_axi_rvalid &&
                (rd_lane0_count_q != 0) &&
                (rd_lane1_count_q != 0)) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rid <= rd_id_q;
                s_axi_rdata <= {rd_lane1_data_mem[rd_lane1_rd_ptr_q], rd_lane0_data_mem[rd_lane0_rd_ptr_q]};
                s_axi_rresp <= f_worst_resp(
                    rd_lane0_resp_mem[rd_lane0_rd_ptr_q],
                    rd_lane1_resp_mem[rd_lane1_rd_ptr_q]
                );
                s_axi_rlast <= (rd_beats_left_q == 8'd1);

                rd_lane0_rd_ptr_q <= rd_lane0_rd_ptr_q + FIFO_PTR_W'(1);
                rd_lane1_rd_ptr_q <= rd_lane1_rd_ptr_q + FIFO_PTR_W'(1);
                rd_lane0_count_q <= rd_lane0_count_q - (FIFO_PTR_W+1)'(1);
                rd_lane1_count_q <= rd_lane1_count_q - (FIFO_PTR_W+1)'(1);
            end

            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                if (rd_beats_left_q != 0) begin
                    rd_beats_left_q <= rd_beats_left_q - 8'd1;
                end
                if (rd_beats_left_q == 8'd1) begin
                    rd_active_q <= 1'b0;
                    s_axi_rlast <= 1'b0;
                end
            end
        end
    end

    wire unused_master_ids = &{
        1'b0,
        m0_axi_bid,
        m0_axi_rid,
        m0_axi_rlast,
        m1_axi_bid,
        m1_axi_rid,
        m1_axi_rlast
    };

endmodule
