/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : timer_tb.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write his/her student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 11, 2018  (version 1.0)
 *  Version    : 1.1
 *  Design     : Homework #3
 *               Test bench of TIMER
 *
 *  Modification History:
 *      * version 1.1, Oct 30, 2019  by Hyoung Bok Min
 *        - macro perr()'s are used instead of $error()'s.
 *      * version 1.0, July 11, 2018  by Hyoung Bok Min
 *        version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*---------------------------
 *  MODULE: TIMER_test
 *
 *  Testbench for module TIMER in timer.v
 *
 *   NOTE: We assume that we use system clock of 100 Hz for TIMER
 *         as given at design specification in this testbench.
 *         In other words, you have to count 100 clocks to get time
 *         duration of 1 second (sec_sw) when you design your TIMER.
 *---------------------------*/

module TIMER_test;

/*------------------------------------------------------------
 *  Time constants
 *  WARNING: Please do not assume that clock period is a specific value.
 *           These time constants may be changed when grading, and
 *           may be any value from 10 ps to 100 ms.
 *           CLOCK_PS should be a multiple of 10, and we assume that
 *           time resolution at `timescale is 1ps.
 *  CLOCK_PS : This is simulation clock period in pico seconds.
 *           You can change simulation clock frequency by using this one.
 *           This natural number should be a multiple of 10.
 *-------------------------------------------------------------------*/
parameter  CLOCK_PS          = 10000;     // should be a multiple of 10
localparam clock_period      = CLOCK_PS/1000.0;
localparam half_clock_period = clock_period / 2;
localparam minimum_period    = clock_period / 10;
/*------------------------------------------------------------*/

/*------------------------------------------------------------
// Constant: Maximum number of errors of same style to be prined.
 *------------------------------------------------------------*/
parameter MAX_ERRORS = 20;
/*------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  RESET_FORM
 *       Choice of return-to-1 waveform of asynchronous reset signal.
 *       You have to choose a natural number of range 0 thru 2 as follows.
 *
 *               -----+          +----------+
 *          clk       +----------+          +---------
 *
 *                                      +-------------
 *            0  -----------------------+
 *
 *                                          +---------   (falling edge of clk)
 *            1  ---------------------------+
 *
 *                                              +-----
 *            2  -------------------------------+
 *
 *                               +--------------------   (rising edge of clk)
 *            3  ----------------+
 *
 *  RESET_PERIOD
 *       Minimum number of clocks during which the asynchronous reset (reset_n)
 *       is active.
 *
 *-------------------------------------------------------------------*/
parameter RESET_FORM  = 0;    // reset waveform: 0 ~ 3
parameter RESET_PERIOD = 1;   // shall be non-negative

// Definitions of mode1/mode2 values
`include "dclockshare.v"


// signals on which logic values will be assigned
reg clk, reset_n;
reg [1:0] mode1, mode2;

// signals which will be observed
wire [5:0] min_sw, sec_sw;
wire [3:0] secc_sw;

/*--------------------------
 *  Check whether the new time is larger than old time by 1.
 *  Return true if new = old+1,
 *         false otherwise.
 *  new time : i_min, i_sec, and i_secc
 *  old time : o_min, o_sec, and o_secc
 *--------------------------*/
function check_time (
    input integer i_min, i_sec, i_secc, o_min, o_sec, o_secc
);
reg decided;
begin
    decided = 0;
    check_time = 1;
    if (o_secc === 9) begin
        if (i_secc !== 0) begin
            check_time = 0;
            decided = 1;
        end
    end else if ((o_secc + 1) !== i_secc) begin
        check_time = 0;
        decided = 1;
    end else if (i_min !== o_min | i_sec !== o_sec) begin
        check_time = 0;
        decided = 1;
    end
    if (!decided) begin
        if (o_secc !== 9) begin
            check_time = 1;
            decided = 1;
        end
    end

    if (!decided) begin
        if (o_sec === 59) begin
            if (i_sec !== 0) begin
                check_time = 0;
                decided = 1;
            end
        end else if ((o_sec + 1) !== i_sec) begin
            check_time = 0;
            decided = 1;
        end else if (i_min !== o_min) begin
            check_time = 0;
            decided = 1;
        end
    end
    if (!decided) begin
        if (o_sec !== 59) begin
            check_time = 1;
            decided = 1;
        end
    end

    if (!decided) begin
        if (o_min === 59) begin
            if (i_min !== 0) begin
                check_time = 0;
                decided = 1;
            end
        end else if ((o_min + 1) !== i_min) begin
            check_time = 0;
            decided = 1;
        end
    end
end
endfunction


/*--------------------------
 *  Instantiation of the design
 *  The following statement connects signals defined above to ports of design
 *--------------------------*/
TIMER U1 (
    .clk(clk),           // input: system clock
    .reset_n(reset_n),   // input: master reset, active low
    .mode1(mode1),       // input: major mode, one of TIME/DATE/TIMER/ALARM
    .mode2(mode2),       // input: minor mode, GEN/START/STOP for TIMER
    .min_sw(min_sw),     // output: timer minutes
    .sec_sw(sec_sw),     // output: timer seconds
    .secc_sw(secc_sw)    // output: timer 1/10 seconds
);

// Clock signal generation
initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # half_clock_period clk = ~clk;
end


// Variables used for test program
reg ok;
integer count;
integer i_min, i_sec, i_secc;    // new time values
integer o_min, o_sec, o_secc;    // old time values

// The following variables are used to count error messages.
reg be_quiet, expected;
integer num_errors;

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif

/*--------------------------
 *  Now, test program begins.
 *--------------------------*/
initial
begin : TEST_PROGRAM
    // parameters for timeformat is:  unit (-9 means ns), digits after dot,
    // string after $time, minimum string length
    $timeformat(-9, 0, " ns", 5);

    // Students may think that the following 3 lines do not exist.
    `ifdef PCODE2
    `include "pcode2.v"
    `endif

    // Check validity of mode constants (localparam's) in dclockshare.v.
    check_mode_consts;

    /*----------
     *  Set initial values for timer.
     *----------*/
    mode1 = M1_TIMER;
    mode2 = M2_TIMER_G;
    reset_n = 1;      // normal state of active low signal

    // Test initial reset.
    # minimum_period;
    reset_n = 0;
    # (clock_period*RESET_PERIOD);
    @ (posedge clk);
    if (RESET_FORM == 0) begin
        # (half_clock_period - 2*minimum_period);
    end else if (RESET_FORM == 1) begin
        @ (negedge clk);
    end else if (RESET_FORM == 2) begin
        @ (negedge clk);
        # (2*minimum_period);
    end
    reset_n = 1;
    # minimum_period;
    expected = (min_sw === 0 && sec_sw === 0 && secc_sw === 0);
    if (!expected) `perr(("Timer should be 0 at initial state."));

    // Start timer for testing reset.
    @ (posedge clk);         // synchronized at rising edge
    mode2 = M2_TIMER_START;
    # (10050*clock_period);  // count of 10050 clock ticks (100.5 secs)
    expected = (min_sw !== 0 && sec_sw !== 0 && secc_sw !== 0);
    if (!expected) `perr(("Timer should NOT be 0 since timer starts."));

    // Test initial reset.
    $display("Testing TIMER reset by using reset_n at %0t", $time);
    # (2*minimum_period);
    reset_n = 0;
    # (clock_period*RESET_PERIOD);
    @ (posedge clk);
    if (RESET_FORM == 0) begin
        # (half_clock_period - 2*minimum_period);
    end else if (RESET_FORM == 1) begin
        @ (negedge clk);
    end else if (RESET_FORM == 2) begin
        @ (negedge clk);
        # (2*minimum_period);
    end
    reset_n = 1;
    # minimum_period;
    expected = (min_sw === 0 && sec_sw === 0 && secc_sw === 0);
    if (!expected)
        `perr(("Timer should be 0 at initial state."));
    if (expected)
        $display("We confirm that reset_n works at %0t", $time);
    mode2 = M2_TIMER_G;

    /*----------
     *  TIMER starts.
     *----------*/
    @ (posedge clk);    // synchronized at rising edge
    mode2 = M2_TIMER_START;
    $display("TIMER START test begins at %0t", $time);

    // wait for the 1st event
    fork
        // wait for event at secc_sw
        begin : WAIT_SEC_SW
            @ (min_sw or sec_sw or secc_sw);
        end
        // The above wait shall expire in about 10 clocks
        begin : TIMEOUT_SECC_SW
            #(12*clock_period);
            if (min_sw == 0 && sec_sw == 0 && secc_sw == 0) begin
                // There was no event, and timeout has occured
                disable WAIT_SEC_SW;
                `perr(("The 1st event does not occur."));
            end
        end
    join
    expected = (min_sw == 0 && sec_sw == 0 && secc_sw == 1);
    if (!expected) `perr(("%s:%0d:%0d:%0d, expected=0:0:1.",
                          "The 1st count of timer is wrong: timer_values=",
                          min_sw, sec_sw, secc_sw));

    o_min = 0;
    o_sec = 0;
    o_secc = 1;
    num_errors = 0;
    be_quiet = 0;       // false
    # minimum_period;   // guard to make sure that this testbench works
    for (count = 2 ; count <= 40000 ; count = count+1) begin
        # (10*clock_period);   // count of 10 clock ticks
        i_min = min_sw;
        i_sec = sec_sw;
        i_secc = secc_sw;
        ok = check_time(i_min, i_sec, i_secc, o_min, o_sec, o_secc);
        if (!be_quiet) begin
            if (!ok) `perr(("%s%0d:%0d:%0d, previous_timer=%0d:%0d:%0d",
                            "Timer count is wrong, current_timer=",
                            i_min, i_sec, i_secc, o_min, o_sec, o_secc));
        end
        if (!ok) begin
            num_errors = num_errors + 1;
            if (num_errors >= MAX_ERRORS)
                be_quiet = 1;
        end

        if (i_min != o_min)
            $display("Simulating timer minutes %0d", i_min);
        o_min = i_min;
        o_sec = i_sec;
        o_secc = i_secc;
    end
    expected = (!be_quiet);
    if (!expected) `perr(("Mismatch:: %0d TIMER output mismatches are found.",
                          num_errors));

    /*----------
     *  TIMER stops.
     *----------*/
    # clock_period;
    mode2 = M2_TIMER_STOP;

    @ (posedge clk);   // synchronized at rising edge
    $display("TIMER STOPs at %0t", $time);

    /*----------
     *  Check whether timer values hold after a few clocks.
     *----------*/
    # (1000*clock_period);
    i_min = min_sw;
    i_sec = sec_sw;
    i_secc = secc_sw;
    expected = (i_min === o_min && i_sec === o_sec && i_secc === o_secc);
    if (!expected) `perr(("TIMER value should hold after STOP."));

    /*----------
     *  Reset timer by mode2.
     *----------*/
    # half_clock_period;
    mode2 = M2_TIMER_G;
    # (2*clock_period);
    expected = (min_sw === 0 && sec_sw === 0 && secc_sw === 0);
    if (!expected) `perr(("TIMER value should be reset at GENERAL mode."));
    # clock_period;

    disable CLOCK_GENERATOR;
    $display("SIMULATION TERMINATED at %0t", $time);
    $stop(2);
end
endmodule

/*--- TIMER_test ---*/
