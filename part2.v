module part2 (
    input  [1:0] KEY,
    input  [9:0] SW,
    output [9:0] LEDR
);
    wire Done, Resetn, PClock, MClock, Run;
    wire [15:0] DIN;
    wire [4:0]  pc;

    assign Resetn = SW[0];
    assign MClock = KEY[0];
    assign PClock = KEY[1];
    assign Run    = SW[9];

    proc     U1 (.DIN(DIN), .Resetn(Resetn), .Clock(PClock), .Run(Run), .Done(Done));
    inst_mem U2 (.address(pc), .clock(MClock), .q(DIN));
    count5   U3 (.Resetn(Resetn), .Clock(MClock), .Q(pc));

    assign LEDR[9]   = Done;
    assign LEDR[8:0] = 9'b000000000;
endmodule

module count5 (
    input             Resetn,
    input             Clock,
    output reg [4:0]  Q
);
    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            Q <= 5'b00000;
        else
            Q <= Q + 1'b1;
    end
endmodule
