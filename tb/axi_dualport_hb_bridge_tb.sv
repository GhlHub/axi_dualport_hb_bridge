// SPDX-FileCopyrightText: 2026 Glen Lowe
// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps

module axi_dualport_hb_bridge_tb;
    localparam int AXI_ADDR_WIDTH = 32;
    localparam int AXI_ID_WIDTH   = 4;
    localparam int MAX_BEATS      = 32;

    logic clk;
    logic rstn;

    logic [AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
    logic [AXI_ID_WIDTH-1:0]   s_axi_awid;
    logic [7:0]                s_axi_awlen;
    logic [2:0]                s_axi_awsize;
    logic [1:0]                s_axi_awburst;
    logic                      s_axi_awvalid;
    logic                      s_axi_awready;

    logic [63:0]               s_axi_wdata;
    logic [7:0]                s_axi_wstrb;
    logic                      s_axi_wlast;
    logic                      s_axi_wvalid;
    logic                      s_axi_wready;

    logic [1:0]                s_axi_bresp;
    logic [AXI_ID_WIDTH-1:0]   s_axi_bid;
    logic                      s_axi_bvalid;
    logic                      s_axi_bready;

    logic [AXI_ADDR_WIDTH-1:0] s_axi_araddr;
    logic [AXI_ID_WIDTH-1:0]   s_axi_arid;
    logic [7:0]                s_axi_arlen;
    logic [2:0]                s_axi_arsize;
    logic [1:0]                s_axi_arburst;
    logic                      s_axi_arvalid;
    logic                      s_axi_arready;

    logic [63:0]               s_axi_rdata;
    logic [AXI_ID_WIDTH-1:0]   s_axi_rid;
    logic [1:0]                s_axi_rresp;
    logic                      s_axi_rlast;
    logic                      s_axi_rvalid;
    logic                      s_axi_rready;

    logic [AXI_ADDR_WIDTH-1:0] m0_axi_awaddr;
    logic [AXI_ID_WIDTH-1:0]   m0_axi_awid;
    logic [7:0]                m0_axi_awlen;
    logic [2:0]                m0_axi_awsize;
    logic [1:0]                m0_axi_awburst;
    logic                      m0_axi_awvalid;
    logic                      m0_axi_awready;
    logic [31:0]               m0_axi_wdata;
    logic [3:0]                m0_axi_wstrb;
    logic                      m0_axi_wlast;
    logic                      m0_axi_wvalid;
    logic                      m0_axi_wready;
    logic [1:0]                m0_axi_bresp;
    logic [AXI_ID_WIDTH-1:0]   m0_axi_bid;
    logic                      m0_axi_bvalid;
    logic                      m0_axi_bready;
    logic [AXI_ADDR_WIDTH-1:0] m0_axi_araddr;
    logic [AXI_ID_WIDTH-1:0]   m0_axi_arid;
    logic [7:0]                m0_axi_arlen;
    logic [2:0]                m0_axi_arsize;
    logic [1:0]                m0_axi_arburst;
    logic                      m0_axi_arvalid;
    logic                      m0_axi_arready;
    logic [31:0]               m0_axi_rdata;
    logic [AXI_ID_WIDTH-1:0]   m0_axi_rid;
    logic [1:0]                m0_axi_rresp;
    logic                      m0_axi_rlast;
    logic                      m0_axi_rvalid;
    logic                      m0_axi_rready;

    logic [AXI_ADDR_WIDTH-1:0] m1_axi_awaddr;
    logic [AXI_ID_WIDTH-1:0]   m1_axi_awid;
    logic [7:0]                m1_axi_awlen;
    logic [2:0]                m1_axi_awsize;
    logic [1:0]                m1_axi_awburst;
    logic                      m1_axi_awvalid;
    logic                      m1_axi_awready;
    logic [31:0]               m1_axi_wdata;
    logic [3:0]                m1_axi_wstrb;
    logic                      m1_axi_wlast;
    logic                      m1_axi_wvalid;
    logic                      m1_axi_wready;
    logic [1:0]                m1_axi_bresp;
    logic [AXI_ID_WIDTH-1:0]   m1_axi_bid;
    logic                      m1_axi_bvalid;
    logic                      m1_axi_bready;
    logic [AXI_ADDR_WIDTH-1:0] m1_axi_araddr;
    logic [AXI_ID_WIDTH-1:0]   m1_axi_arid;
    logic [7:0]                m1_axi_arlen;
    logic [2:0]                m1_axi_arsize;
    logic [1:0]                m1_axi_arburst;
    logic                      m1_axi_arvalid;
    logic                      m1_axi_arready;
    logic [31:0]               m1_axi_rdata;
    logic [AXI_ID_WIDTH-1:0]   m1_axi_rid;
    logic [1:0]                m1_axi_rresp;
    logic                      m1_axi_rlast;
    logic                      m1_axi_rvalid;
    logic                      m1_axi_rready;

    logic [63:0] wr_data_mem [0:MAX_BEATS-1];
    logic [7:0]  wr_strb_mem [0:MAX_BEATS-1];
    logic [63:0] rd_data_mem [0:MAX_BEATS-1];

    axi_dualport_hb_bridge #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .MAX_BURST_BEATS(MAX_BEATS)
    ) dut (
        .i_axi_aclk(clk),
        .i_axi_aresetn(rstn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bid(s_axi_bid),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .m0_axi_awaddr(m0_axi_awaddr),
        .m0_axi_awid(m0_axi_awid),
        .m0_axi_awlen(m0_axi_awlen),
        .m0_axi_awsize(m0_axi_awsize),
        .m0_axi_awburst(m0_axi_awburst),
        .m0_axi_awvalid(m0_axi_awvalid),
        .m0_axi_awready(m0_axi_awready),
        .m0_axi_wdata(m0_axi_wdata),
        .m0_axi_wstrb(m0_axi_wstrb),
        .m0_axi_wlast(m0_axi_wlast),
        .m0_axi_wvalid(m0_axi_wvalid),
        .m0_axi_wready(m0_axi_wready),
        .m0_axi_bresp(m0_axi_bresp),
        .m0_axi_bid(m0_axi_bid),
        .m0_axi_bvalid(m0_axi_bvalid),
        .m0_axi_bready(m0_axi_bready),
        .m0_axi_araddr(m0_axi_araddr),
        .m0_axi_arid(m0_axi_arid),
        .m0_axi_arlen(m0_axi_arlen),
        .m0_axi_arsize(m0_axi_arsize),
        .m0_axi_arburst(m0_axi_arburst),
        .m0_axi_arvalid(m0_axi_arvalid),
        .m0_axi_arready(m0_axi_arready),
        .m0_axi_rdata(m0_axi_rdata),
        .m0_axi_rid(m0_axi_rid),
        .m0_axi_rresp(m0_axi_rresp),
        .m0_axi_rlast(m0_axi_rlast),
        .m0_axi_rvalid(m0_axi_rvalid),
        .m0_axi_rready(m0_axi_rready),
        .m1_axi_awaddr(m1_axi_awaddr),
        .m1_axi_awid(m1_axi_awid),
        .m1_axi_awlen(m1_axi_awlen),
        .m1_axi_awsize(m1_axi_awsize),
        .m1_axi_awburst(m1_axi_awburst),
        .m1_axi_awvalid(m1_axi_awvalid),
        .m1_axi_awready(m1_axi_awready),
        .m1_axi_wdata(m1_axi_wdata),
        .m1_axi_wstrb(m1_axi_wstrb),
        .m1_axi_wlast(m1_axi_wlast),
        .m1_axi_wvalid(m1_axi_wvalid),
        .m1_axi_wready(m1_axi_wready),
        .m1_axi_bresp(m1_axi_bresp),
        .m1_axi_bid(m1_axi_bid),
        .m1_axi_bvalid(m1_axi_bvalid),
        .m1_axi_bready(m1_axi_bready),
        .m1_axi_araddr(m1_axi_araddr),
        .m1_axi_arid(m1_axi_arid),
        .m1_axi_arlen(m1_axi_arlen),
        .m1_axi_arsize(m1_axi_arsize),
        .m1_axi_arburst(m1_axi_arburst),
        .m1_axi_arvalid(m1_axi_arvalid),
        .m1_axi_arready(m1_axi_arready),
        .m1_axi_rdata(m1_axi_rdata),
        .m1_axi_rid(m1_axi_rid),
        .m1_axi_rresp(m1_axi_rresp),
        .m1_axi_rlast(m1_axi_rlast),
        .m1_axi_rvalid(m1_axi_rvalid),
        .m1_axi_rready(m1_axi_rready)
    );

    axi32_ram_model #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .MEM_WORDS(256),
        .READ_SKEW(0)
    ) u_mem0 (
        .i_axi_aclk(clk),
        .i_axi_aresetn(rstn),
        .s_axi_awaddr(m0_axi_awaddr),
        .s_axi_awid(m0_axi_awid),
        .s_axi_awlen(m0_axi_awlen),
        .s_axi_awsize(m0_axi_awsize),
        .s_axi_awburst(m0_axi_awburst),
        .s_axi_awvalid(m0_axi_awvalid),
        .s_axi_awready(m0_axi_awready),
        .s_axi_wdata(m0_axi_wdata),
        .s_axi_wstrb(m0_axi_wstrb),
        .s_axi_wlast(m0_axi_wlast),
        .s_axi_wvalid(m0_axi_wvalid),
        .s_axi_wready(m0_axi_wready),
        .s_axi_bresp(m0_axi_bresp),
        .s_axi_bid(m0_axi_bid),
        .s_axi_bvalid(m0_axi_bvalid),
        .s_axi_bready(m0_axi_bready),
        .s_axi_araddr(m0_axi_araddr),
        .s_axi_arid(m0_axi_arid),
        .s_axi_arlen(m0_axi_arlen),
        .s_axi_arsize(m0_axi_arsize),
        .s_axi_arburst(m0_axi_arburst),
        .s_axi_arvalid(m0_axi_arvalid),
        .s_axi_arready(m0_axi_arready),
        .s_axi_rdata(m0_axi_rdata),
        .s_axi_rid(m0_axi_rid),
        .s_axi_rresp(m0_axi_rresp),
        .s_axi_rlast(m0_axi_rlast),
        .s_axi_rvalid(m0_axi_rvalid),
        .s_axi_rready(m0_axi_rready)
    );

    axi32_ram_model #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .MEM_WORDS(256),
        .READ_SKEW(1)
    ) u_mem1 (
        .i_axi_aclk(clk),
        .i_axi_aresetn(rstn),
        .s_axi_awaddr(m1_axi_awaddr),
        .s_axi_awid(m1_axi_awid),
        .s_axi_awlen(m1_axi_awlen),
        .s_axi_awsize(m1_axi_awsize),
        .s_axi_awburst(m1_axi_awburst),
        .s_axi_awvalid(m1_axi_awvalid),
        .s_axi_awready(m1_axi_awready),
        .s_axi_wdata(m1_axi_wdata),
        .s_axi_wstrb(m1_axi_wstrb),
        .s_axi_wlast(m1_axi_wlast),
        .s_axi_wvalid(m1_axi_wvalid),
        .s_axi_wready(m1_axi_wready),
        .s_axi_bresp(m1_axi_bresp),
        .s_axi_bid(m1_axi_bid),
        .s_axi_bvalid(m1_axi_bvalid),
        .s_axi_bready(m1_axi_bready),
        .s_axi_araddr(m1_axi_araddr),
        .s_axi_arid(m1_axi_arid),
        .s_axi_arlen(m1_axi_arlen),
        .s_axi_arsize(m1_axi_arsize),
        .s_axi_arburst(m1_axi_arburst),
        .s_axi_arvalid(m1_axi_arvalid),
        .s_axi_arready(m1_axi_arready),
        .s_axi_rdata(m1_axi_rdata),
        .s_axi_rid(m1_axi_rid),
        .s_axi_rresp(m1_axi_rresp),
        .s_axi_rlast(m1_axi_rlast),
        .s_axi_rvalid(m1_axi_rvalid),
        .s_axi_rready(m1_axi_rready)
    );

    always #10 clk <= ~clk;

    task automatic drive_write_burst(
        input logic [AXI_ADDR_WIDTH-1:0] addr,
        input logic [AXI_ID_WIDTH-1:0]   id,
        input int                        beats
    );
        int beat;
        begin
            @(posedge clk);
            s_axi_awaddr  = addr;
            s_axi_awid    = id;
            s_axi_awlen   = beats[7:0] - 8'd1;
            s_axi_awsize  = 3'd3;
            s_axi_awburst = 2'b01;
            s_axi_awvalid = 1'b1;
            while (!s_axi_awready) @(posedge clk);
            @(posedge clk);
            s_axi_awvalid = 1'b0;

            for (beat = 0; beat < beats; beat = beat + 1) begin
                s_axi_wdata  = wr_data_mem[beat];
                s_axi_wstrb  = wr_strb_mem[beat];
                s_axi_wlast  = (beat == (beats - 1));
                s_axi_wvalid = 1'b1;
                while (!s_axi_wready) @(posedge clk);
                @(posedge clk);
                s_axi_wvalid = 1'b0;
            end

            s_axi_bready = 1'b1;
            while (!s_axi_bvalid) @(posedge clk);
            if (s_axi_bresp !== 2'b00) begin
                $fatal(1, "unexpected BRESP %0b", s_axi_bresp);
            end
            if (s_axi_bid !== id) begin
                $fatal(1, "unexpected BID %0d", s_axi_bid);
            end
            @(posedge clk);
            s_axi_bready = 1'b0;
        end
    endtask

    task automatic drive_read_burst(
        input logic [AXI_ADDR_WIDTH-1:0] addr,
        input logic [AXI_ID_WIDTH-1:0]   id,
        input int                        beats,
        input int                        ready_hold_cycles
    );
        int beat;
        begin
            @(posedge clk);
            s_axi_araddr  = addr;
            s_axi_arid    = id;
            s_axi_arlen   = beats[7:0] - 8'd1;
            s_axi_arsize  = 3'd3;
            s_axi_arburst = 2'b01;
            s_axi_arvalid = 1'b1;
            while (!s_axi_arready) @(posedge clk);
            @(posedge clk);
            s_axi_arvalid = 1'b0;

            s_axi_rready = 1'b0;
            repeat (ready_hold_cycles) @(posedge clk);
            s_axi_rready = 1'b1;

            for (beat = 0; beat < beats; beat = beat + 1) begin
                while (!s_axi_rvalid) @(posedge clk);
                rd_data_mem[beat] = s_axi_rdata;
                if (s_axi_rresp !== 2'b00) begin
                    $fatal(1, "unexpected RRESP %0b at beat %0d", s_axi_rresp, beat);
                end
                if (s_axi_rid !== id) begin
                    $fatal(1, "unexpected RID %0d at beat %0d", s_axi_rid, beat);
                end
                if ((beat == (beats - 1)) && !s_axi_rlast) begin
                    $fatal(1, "missing RLAST on final beat");
                end
                if ((beat != (beats - 1)) && s_axi_rlast) begin
                    $fatal(1, "early RLAST on beat %0d", beat);
                end
                @(posedge clk);
            end

            s_axi_rready = 1'b0;
        end
    endtask

    task automatic expect_equal64(
        input logic [63:0] actual,
        input logic [63:0] expected,
        input string       label
    );
        begin
            if (actual !== expected) begin
                $fatal(1, "%s actual=0x%016h expected=0x%016h", label, actual, expected);
            end
        end
    endtask

    function automatic logic [63:0] apply_wstrb64(
        input logic [63:0] old_data,
        input logic [63:0] new_data,
        input logic [7:0]  wstrb
    );
        begin
            apply_wstrb64 = old_data;
            if (wstrb[0]) apply_wstrb64[7:0]   = new_data[7:0];
            if (wstrb[1]) apply_wstrb64[15:8]  = new_data[15:8];
            if (wstrb[2]) apply_wstrb64[23:16] = new_data[23:16];
            if (wstrb[3]) apply_wstrb64[31:24] = new_data[31:24];
            if (wstrb[4]) apply_wstrb64[39:32] = new_data[39:32];
            if (wstrb[5]) apply_wstrb64[47:40] = new_data[47:40];
            if (wstrb[6]) apply_wstrb64[55:48] = new_data[55:48];
            if (wstrb[7]) apply_wstrb64[63:56] = new_data[63:56];
        end
    endfunction

    integer idx;
    logic [63:0] exp_word0;
    logic [63:0] exp_word1;

    initial begin
        #200000;
        $fatal(1, "timeout");
    end

    initial begin
        clk = 1'b0;
        rstn = 1'b0;

        s_axi_awaddr = '0;
        s_axi_awid = '0;
        s_axi_awlen = '0;
        s_axi_awsize = '0;
        s_axi_awburst = '0;
        s_axi_awvalid = 1'b0;
        s_axi_wdata = '0;
        s_axi_wstrb = '0;
        s_axi_wlast = 1'b0;
        s_axi_wvalid = 1'b0;
        s_axi_bready = 1'b0;
        s_axi_araddr = '0;
        s_axi_arid = '0;
        s_axi_arlen = '0;
        s_axi_arsize = '0;
        s_axi_arburst = '0;
        s_axi_arvalid = 1'b0;
        s_axi_rready = 1'b0;

        repeat (5) @(posedge clk);
        rstn = 1'b1;
        repeat (2) @(posedge clk);

        wr_data_mem[0] = 64'h11223344_55667788;
        wr_data_mem[1] = 64'h99AABBCC_DDEEFF00;
        wr_data_mem[2] = 64'h01234567_89ABCDEF;
        wr_data_mem[3] = 64'hCAFEBABE_13579BDF;
        wr_strb_mem[0] = 8'hFF;
        wr_strb_mem[1] = 8'hFF;
        wr_strb_mem[2] = 8'hFF;
        wr_strb_mem[3] = 8'hFF;
        drive_write_burst(32'h0000_0020, 4'h3, 4);

        if (u_mem0.mem[4] !== 32'h55667788) $fatal(1, "lane0 address scaling mismatch beat0");
        if (u_mem1.mem[4] !== 32'h11223344) $fatal(1, "lane1 address scaling mismatch beat0");
        if (u_mem0.mem[5] !== 32'hDDEEFF00) $fatal(1, "lane0 address scaling mismatch beat1");
        if (u_mem1.mem[5] !== 32'h99AABBCC) $fatal(1, "lane1 address scaling mismatch beat1");

        drive_read_burst(32'h0000_0020, 4'h3, 4, 0);
        expect_equal64(rd_data_mem[0], wr_data_mem[0], "readback beat0");
        expect_equal64(rd_data_mem[1], wr_data_mem[1], "readback beat1");
        expect_equal64(rd_data_mem[2], wr_data_mem[2], "readback beat2");
        expect_equal64(rd_data_mem[3], wr_data_mem[3], "readback beat3");

        wr_data_mem[0] = 64'hFFFF0000_A5A5A5A5;
        wr_strb_mem[0] = 8'b0000_1111;
        drive_write_burst(32'h0000_0020, 4'h4, 1);
        drive_read_burst(32'h0000_0020, 4'h4, 1, 0);
        expect_equal64(rd_data_mem[0], 64'h11223344_A5A5A5A5, "masked readback");

        wr_data_mem[0] = 64'h55AA7733_66778899;
        wr_strb_mem[0] = 8'hF0;
        drive_write_burst(32'h0000_0020, 4'h6, 1);
        drive_read_burst(32'h0000_0020, 4'h6, 1, 0);
        expect_equal64(rd_data_mem[0], 64'h55AA7733_A5A5A5A5, "upper-lane-only masked readback");
        if (u_mem0.mem[4] !== 32'hA5A5A5A5) $fatal(1, "lane0 changed during upper-lane-only write");
        if (u_mem1.mem[4] !== 32'h55AA7733) $fatal(1, "lane1 upper-lane-only write mismatch");

        wr_data_mem[0] = 64'h12345678_89ABCDEF;
        wr_strb_mem[0] = 8'b0101_1010;
        drive_write_burst(32'h0000_0020, 4'h7, 1);
        drive_read_burst(32'h0000_0020, 4'h7, 1, 0);
        expect_equal64(rd_data_mem[0], 64'h55347778_89A5CDA5, "mixed byte-enable readback");
        if (u_mem0.mem[4] !== 32'h89A5CDA5) $fatal(1, "lane0 mixed byte-enable mismatch");
        if (u_mem1.mem[4] !== 32'h55347778) $fatal(1, "lane1 mixed byte-enable mismatch");

        drive_read_burst(32'h0000_0030, 4'h8, 2, 0);
        exp_word0 = rd_data_mem[0];
        exp_word1 = rd_data_mem[1];

        wr_data_mem[0] = 64'h0F1E2D3C_4B5A6978;
        wr_strb_mem[0] = 8'b0011_1100;
        wr_data_mem[1] = 64'h89ABCDEF_10213243;
        wr_strb_mem[1] = 8'b1100_0011;
        drive_write_burst(32'h0000_0030, 4'h8, 2);
        drive_read_burst(32'h0000_0030, 4'h8, 2, 0);
        exp_word0 = apply_wstrb64(exp_word0, 64'h0F1E2D3C_4B5A6978, 8'b0011_1100);
        exp_word1 = apply_wstrb64(exp_word1, 64'h89ABCDEF_10213243, 8'b1100_0011);
        expect_equal64(rd_data_mem[0], exp_word0, "beat0 partial burst readback");
        expect_equal64(rd_data_mem[1], exp_word1, "beat1 partial burst readback");
        if (u_mem0.mem[6] !== exp_word0[31:0]) $fatal(1, "lane0 burst beat0 partial mismatch");
        if (u_mem1.mem[6] !== exp_word0[63:32]) $fatal(1, "lane1 burst beat0 partial mismatch");
        if (u_mem0.mem[7] !== exp_word1[31:0]) $fatal(1, "lane0 burst beat1 partial mismatch");
        if (u_mem1.mem[7] !== exp_word1[63:32]) $fatal(1, "lane1 burst beat1 partial mismatch");

        for (idx = 0; idx < MAX_BEATS; idx = idx + 1) begin
            wr_data_mem[idx] = {32'h7000_0000 + idx, 32'h1000_0000 + idx};
            wr_strb_mem[idx] = 8'hFF;
        end
        drive_write_burst(32'h0000_0100, 4'h5, MAX_BEATS);
        drive_read_burst(32'h0000_0100, 4'h5, MAX_BEATS, 20);
        for (idx = 0; idx < MAX_BEATS; idx = idx + 1) begin
            expect_equal64(rd_data_mem[idx], wr_data_mem[idx], "max burst readback");
        end

        $display("PASS");
        $finish;
    end
endmodule
