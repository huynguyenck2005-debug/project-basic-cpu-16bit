module proc(
    input      [15:0] DIN,
    input             Resetn,
    input             Clock,
    input             Run,
    output     [15:0] DOUT,
    output     [15:0] ADDR,
    output reg        W,
    output reg        Done
);
    localparam T0 = 2'b00,
               T1 = 2'b01,
               T2 = 2'b10,
               T3 = 2'b11;

    localparam OP_MV   = 3'b000,
               OP_MVT  = 3'b001,
               OP_ADD  = 3'b010,
               OP_SUB  = 3'b011,
               OP_LD   = 3'b100,
               OP_ST   = 3'b101,
               OP_AND  = 3'b110,
               OP_BR   = 3'b111;

    localparam COND_AL = 3'b000,
               COND_EQ = 3'b001,
               COND_NE = 3'b010,
               COND_CC = 3'b011,
               COND_CS = 3'b100;

    localparam Sel_R0   = 4'd0,
               Sel_R1   = 4'd1,
               Sel_R2   = 4'd2,
               Sel_R3   = 4'd3,
               Sel_R4   = 4'd4,
               Sel_R5   = 4'd5,
               Sel_R6   = 4'd6,
               Sel_R7   = 4'd7,
               Sel_G    = 4'd8,
               Sel_D    = 4'd9,
               Sel_D8   = 4'd10,
               Sel_DIN  = 4'd11;

    reg  [1:0] Tstep_D, Tstep_Q;
    reg        IRin, Ain, Gin, DOUTin, ADDRin, Zin, Cin, AddSub, LogicAnd, incr_pc;
    reg  [3:0] Sel;
    reg  [7:0] Rin;
    wire [7:0] Xreg;

    wire [2:0] III  = IR[15:13];
    wire       IMM  = IR[12];
    wire [2:0] rX   = IR[11:9];
    wire [2:0] rY   = IR[2:0];
    wire [2:0] cond = IR[11:9];

    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [15:0] A, G, IR;
    wire [15:0] ADDR_reg, DOUT_reg;
    reg  [15:0] BusWires;

    wire [16:0] addsub_ext = AddSub ? ({1'b0, A} - {1'b0, BusWires})
                                    : ({1'b0, A} + {1'b0, BusWires});
    wire [15:0] ALU_addsub = addsub_ext[15:0];
    wire        ALU_carry  = addsub_ext[16];
    wire [15:0] ALU_and    = A & BusWires;
    wire [15:0] ALU_result = LogicAnd ? ALU_and : ALU_addsub;
    wire        ALU_zero   = (ALU_result == 16'h0000);

    reg z, c;
    wire branch_taken = (cond == COND_AL) |
                        ((cond == COND_EQ) &  z) |
                        ((cond == COND_NE) & ~z) |
                        ((cond == COND_CC) & ~c) |
                        ((cond == COND_CS) &  c);

    dec3to8 decX (.W(rX), .En(1'b1), .Y(Xreg));

    always @(*) begin
        case (Tstep_Q)
            T0: Tstep_D = Run ? T1 : T0;
            T1: begin
                case (III)
                    OP_LD, OP_ST, OP_ADD, OP_SUB, OP_AND: Tstep_D = T2;
                    default: Tstep_D = T0;
                endcase
            end
            T2: begin
                case (III)
                    OP_ST, OP_ADD, OP_SUB, OP_AND: Tstep_D = T3;
                    default: Tstep_D = T0;
                endcase
            end
            default: Tstep_D = T0;
        endcase
    end

    always @(*) begin
        Done    = 1'b0;
        W       = 1'b0;
        IRin    = 1'b0;
        Ain     = 1'b0;
        Gin     = 1'b0;
        DOUTin  = 1'b0;
        ADDRin  = 1'b0;
        Zin     = 1'b0;
        Cin     = 1'b0;
        AddSub  = 1'b0;
        LogicAnd= 1'b0;
        incr_pc = 1'b0;
        Rin     = 8'b00000000;
        Sel     = Sel_R0;

        case (Tstep_Q)
            T0: begin
                if (Run) begin
                    IRin    = 1'b1;
                    incr_pc = 1'b1;
                end
            end

            T1: begin
                case (III)
                    OP_MV: begin
                        Sel  = IMM ? Sel_D : {1'b0, rY};
                        Rin  = Xreg;
                        Done = 1'b1;
                    end

                    OP_MVT: begin
                        Sel  = Sel_D8;
                        Rin  = Xreg;
                        Done = 1'b1;
                    end

                    OP_LD: begin
                        Sel    = {1'b0, rY};
                        ADDRin = 1'b1;
                    end

                    OP_ST: begin
                        Sel    = {1'b0, rY};
                        ADDRin = 1'b1;
                    end

                    OP_ADD, OP_SUB, OP_AND: begin
                        Sel = {1'b0, rX};
                        Ain = 1'b1;
                    end

                    OP_BR: begin
                        if (IMM && branch_taken) begin
                            Sel = Sel_D;
                            Rin = 8'b10000000; // pc
                        end
                        Done = 1'b1;
                    end

                    default: begin
                        Done = 1'b1;
                    end
                endcase
            end

            T2: begin
                case (III)
                    OP_LD: begin
                        Sel  = Sel_DIN;
                        Rin  = Xreg;
                        Done = 1'b1;
                    end

                    OP_ST: begin
                        Sel    = {1'b0, rX};
                        DOUTin = 1'b1;
                    end

                    OP_ADD: begin
                        Sel    = IMM ? Sel_D : {1'b0, rY};
                        AddSub = 1'b0;
                        Gin    = 1'b1;
                        Zin    = 1'b1;
                        Cin    = 1'b1;
                    end

                    OP_SUB: begin
                        Sel    = IMM ? Sel_D : {1'b0, rY};
                        AddSub = 1'b1;
                        Gin    = 1'b1;
                        Zin    = 1'b1;
                        Cin    = 1'b1;
                    end

                    OP_AND: begin
                        Sel      = IMM ? Sel_D : {1'b0, rY};
                        LogicAnd = 1'b1;
                        Gin      = 1'b1;
                        Zin      = 1'b1;
                    end

                    default: begin
                        Done = 1'b1;
                    end
                endcase
            end

            T3: begin
                case (III)
                    OP_ST: begin
                        W    = 1'b1;
                        Done = 1'b1;
                    end

                    OP_ADD, OP_SUB, OP_AND: begin
                        Sel  = Sel_G;
                        Rin  = Xreg;
                        Done = 1'b1;
                    end

                    default: begin
                        Done = 1'b1;
                    end
                endcase
            end
        endcase
    end

    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            Tstep_Q <= T0;
        else
            Tstep_Q <= Tstep_D;
    end

    regn reg_0    (.R(BusWires),   .Rin(Rin[0]), .Clock(Clock), .Q(R0));
    regn reg_1    (.R(BusWires),   .Rin(Rin[1]), .Clock(Clock), .Q(R1));
    regn reg_2    (.R(BusWires),   .Rin(Rin[2]), .Clock(Clock), .Q(R2));
    regn reg_3    (.R(BusWires),   .Rin(Rin[3]), .Clock(Clock), .Q(R3));
    regn reg_4    (.R(BusWires),   .Rin(Rin[4]), .Clock(Clock), .Q(R4));
    regn reg_5    (.R(BusWires),   .Rin(Rin[5]), .Clock(Clock), .Q(R5));
    regn reg_6    (.R(BusWires),   .Rin(Rin[6]), .Clock(Clock), .Q(R6));

    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            z <= 1'b0;
        else if (Zin)
            z <= ALU_zero;
    end

    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            c <= 1'b0;
        else if (Cin)
            c <= ALU_carry;
    end


    reg [15:0] pc_reg;
    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            pc_reg <= 16'h0000;
        else if (incr_pc)
            pc_reg <= pc_reg + 16'h0001;
        else if (Rin[7])
            pc_reg <= BusWires;
    end

    regn reg_A    (.R(BusWires),   .Rin(Ain),    .Clock(Clock), .Q(A));
    regn reg_G    (.R(ALU_result), .Rin(Gin),    .Clock(Clock), .Q(G));
    regn reg_IR   (.R(DIN),        .Rin(IRin),   .Clock(Clock), .Q(IR));
    regn reg_ADDR (.R(BusWires),   .Rin(ADDRin), .Clock(Clock), .Q(ADDR_reg));
    regn reg_DOUT (.R(BusWires),   .Rin(DOUTin), .Clock(Clock), .Q(DOUT_reg));

    assign R7   = pc_reg;
    assign ADDR = (Tstep_Q == T0 && Run) ? pc_reg : ADDR_reg;
    assign DOUT = DOUT_reg;

    always @(*) begin
        case (Sel)
            Sel_R0:  BusWires = R0;
            Sel_R1:  BusWires = R1;
            Sel_R2:  BusWires = R2;
            Sel_R3:  BusWires = R3;
            Sel_R4:  BusWires = R4;
            Sel_R5:  BusWires = R5;
            Sel_R6:  BusWires = R6;
            Sel_R7:  BusWires = R7;
            Sel_G:   BusWires = G;
            Sel_D:   BusWires = {7'b0000000, IR[8:0]};
            Sel_D8:  BusWires = {IR[7:0], 8'b00000000};
            Sel_DIN: BusWires = DIN;
            default: BusWires = 16'hxxxx;
        endcase
    end
endmodule

module regn #(parameter n = 16)(
    input      [n-1:0] R,
    input              Rin,
    input              Clock,
    output reg [n-1:0] Q
);
    always @(posedge Clock) begin
        if (Rin)
            Q <= R;
    end
endmodule

module dec3to8(
    input      [2:0] W,
    input            En,
    output reg [7:0] Y
);
    always @(*) begin
        if (!En)
            Y = 8'b00000000;
        else begin
            case (W)
                3'b000: Y = 8'b00000001;
                3'b001: Y = 8'b00000010;
                3'b010: Y = 8'b00000100;
                3'b011: Y = 8'b00001000;
                3'b100: Y = 8'b00010000;
                3'b101: Y = 8'b00100000;
                3'b110: Y = 8'b01000000;
                3'b111: Y = 8'b10000000;
                default: Y = 8'b00000000;
            endcase
        end
    end
endmodule
