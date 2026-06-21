module part4 (KEY, SW, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input  [0:0] KEY;
    input  [9:0] SW;
    input        CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [15:0] DOUT, ADDR;
    wire        Done, W;
    reg  [15:0] DIN;
    wire        inst_mem_cs, SW_cs, LED_reg_cs, seg7_cs;
    wire [15:0] inst_mem_q;
    wire [8:0]  LED_reg, SW_reg;

    proc U3 (DIN, KEY[0], CLOCK_50, SW[9], DOUT, ADDR, W, Done);

    assign inst_mem_cs = (ADDR[15:12] == 4'h0);
    assign LED_reg_cs  = (ADDR[15:12] == 4'h1);
    assign seg7_cs     = (ADDR[15:12] == 4'h2);
    assign SW_cs       = (ADDR[15:12] == 4'h3);

    inst_mem U4 (ADDR[7:0], CLOCK_50, DOUT, inst_mem_cs & W, inst_mem_q);

    always @(*) begin
        if (inst_mem_cs)
            DIN = inst_mem_q;
        else if (SW_cs)
            DIN = {7'b0000000, SW_reg};
        else
            DIN = 16'hxxxx;
    end

    regn #(.n(9)) U5 (DOUT[8:0], LED_reg_cs & W, CLOCK_50, LED_reg);
    seg7 U6 (DOUT[6:0], ADDR[2:0], seg7_cs & W, CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    assign LEDR[8:0] = LED_reg;
    assign LEDR[9]   = SW[9];

    regn #(.n(9)) U7 (SW[8:0], 1'b1, CLOCK_50, SW_reg);
endmodule
