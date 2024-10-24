/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2020 by Hyuk Soo Yeo, All rights reserved.
 *
 *  File name  : rsr_tb.v
 *  Written by : Yeo, Hyuk Soo
 *               2016312761
 *               School of Software
 *               Sungkyunkwan University
 *  Written on : October 10, 2020
 *  Version    : 1.0
 *  Design     : Testbench for 4 bit right shift register (rsr.v)
 *
 *  Modification History:
 *      * October 10, 2020  by Hyuk Soo Yeo
 *        v1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ns

/*-------------------------------------------------------------------------
 *  Module: rsr_tb
 *
 *  Description:
 *    testbench to test 4 bit right shift register.
 *    The 4 bit right shift register module is implemented at file rsr.v.
 *-------------------------------------------------------------------------*/

module rsr_tb;

parameter NUM_TEST_BITS = 12;
parameter CLOCK_PERIOD = 20;  //  We will test in 50 MHz clock environment.

/**
 *   test stimulus and expected output responses for each stimuli
 */
parameter [0:NUM_TEST_BITS-1] STIMULUS = 12'b11001010xxxx;
parameter [0:NUM_TEST_BITS-1] RESPONSE = 12'bxxxx11001010;

/**
 *  Signals that are connected to input and output ports of the module rsr
 *  Test stimulus are assigned to input signals and
 *  Test responses from these signals are stored to output signal.
 */
reg inbit;
reg clk = 1'b0;
always #(CLOCK_PERIOD / 2) clk = ~clk;
wire outbit;

integer idx;
/**
 *  instantiation of 4 bit right shift register which is the module under test.
 *  Test signals are connected to the ports of this module.
 */
rsr rsr4(.si(inbit), .clk(clk), .so(outbit));

/**
 *  The following procedure block applies test stimulus to input signals, and
 *  check output responses from output signals.
 */
initial begin
    #15;
    for (idx = 0 ; idx < NUM_TEST_BITS ; idx = idx+1) begin
        if (STIMULUS[idx] !== 1'bx) begin
            //  Apply stimuli to input signal
            inbit = STIMULUS[idx];
        end
	if (RESPONSE[idx] !== 1'bx) begin
            if (!(outbit === RESPONSE[idx])) begin
                $error("not matched with predicted result!");
            end else begin
                $display("Correct!");
            end
        end
        //  Report a cycle of test procedure
        $display("expected bit: ", RESPONSE[idx], " output bit: ", outbit);
        #CLOCK_PERIOD;
    end
    $display("Test Finished");
    $stop;
end

endmodule
