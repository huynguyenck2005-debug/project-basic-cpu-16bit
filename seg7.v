module seg7(
    input      [6:0] D,
    input      [2:0] A,
    input            W,
    input            Clock,
    output reg [6:0] HEX0,
    output reg [6:0] HEX1,
    output reg [6:0] HEX2,
    output reg [6:0] HEX3,
    output reg [6:0] HEX4,
    output reg [6:0] HEX5
);
    always @(posedge Clock) begin
        if (W) begin
            case (A)
                3'd0: HEX0 <= D;
                3'd1: HEX1 <= D;
                3'd2: HEX2 <= D;
                3'd3: HEX3 <= D;
                3'd4: HEX4 <= D;
                3'd5: HEX5 <= D;
                default: ;
            endcase
        end
    end
endmodule
