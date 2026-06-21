`timescale 1ns/1ps

module part2_tb;
    reg  [1:0] KEY;
    reg  [9:0] SW;
    wire [9:0] LEDR;

    part2 dut (
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR)
    );

    task pulse_mclock;
        begin
            #5 KEY[0] = 1'b1;
            #5 KEY[0] = 1'b0;
            #10;
        end
    endtask

    task pulse_pclock;
        begin
            #5 KEY[1] = 1'b1;
            #5 KEY[1] = 1'b0;
            #10;
        end
    endtask

    task exec_simple;
        begin
            pulse_mclock; // fetch next instruction from ROM onto DIN
            pulse_pclock; // T0
            pulse_pclock; // T1, instruction done
        end
    endtask

    task exec_alu;
        begin
            pulse_mclock; // fetch next instruction from ROM onto DIN
            pulse_pclock; // T0
            pulse_pclock; // T1
            pulse_pclock; // T2
            pulse_pclock; // T3, instruction done
        end
    endtask

    initial begin
        $dumpfile("part2_tb.vcd");
        $dumpvars(0, part2_tb);

        KEY = 2'b00;
        SW  = 10'b0000000000;

        // Reset
        SW[0] = 1'b0;
        SW[9] = 1'b0;
        #20;

        // Release reset and run
        SW[0] = 1'b1;
        SW[9] = 1'b1;
        #20;

        exec_simple; // mv  r0, #28
        exec_simple; // mvt r1, #0xFF00
        exec_alu;    // add r1, #0x00FF
        exec_alu;    // sub r1, r0
        exec_alu;    // add r1, #1

        #40;
        $stop;
    end
endmodule

