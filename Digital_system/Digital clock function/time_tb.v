/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : time_tb.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write his/her student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 10, 2018  (version 1.0)
 *  Version    : 1.1
 *  Design     : Homework #3
 *               Test bench of TIME
 *
 *  Modification History:
 *      * version 1.1, Oct 30, 2019  by Hyoung Bok Min
 *        - macro perr()'s are used instead of $error()'s.
 *      * version 1.0, July 10, 2018  by Hyoung Bok Min
 *        version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*---------------------------
 *  MODULE: TIME_test
 *
 *  Testbench for module TIME in time.v
 *---------------------------*/

module TIME_test;

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
localparam half_clock_period = clock_period / 2;      // for clock
localparam minimum_period    = clock_period / 10;     // for reset test
/*------------------------------------------------------------*/

/*------------------------------------------------------------------
 *  NOTE :
 *  The following value 'time_per_sec' is the time duration of a second,
 *  and it should be the time duration for 100 clocks. In other words,
 *  we count 100 clocks to measure a second. The duation for 100 clocks
 *  matches the design specification of 100 Hz system clock.
 *
 *  But, we may use the time duration for less than 100 clocks for faster
 *  simulation, for example, we may count 10 clocks to measure a second,
 *  and the number of clocks to measure a second is decided by parameter,
 *  CLOCKS4SEC.
 *
 *  If you modify the parameter CLOCKS4SEC for faster simulation, you also
 *  have to modify the definition of CLOCKS4SEC in the design file
 *  'time.v' and in another testbench file 'tb12.v'. The simulation
 *  run time in 'time.do' and 'tb12.do' should also be modified.
 *------------------------------------------------------------------*/
// CLOCKS4SEC : number of clocks in order to measure a second
parameter  CLOCKS4SEC = 100;
localparam time_per_sec = CLOCKS4SEC * clock_period;
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
parameter RESET_PERIOD = 1;   // should be non-negative

// Definitions of mode1/mode2 values
`include "dclockshare.v"


// signals on which logic values will be assigned
reg clk, increase, reset_n;
reg [1:0] mode1, mode2;

// signals which will be observed
wire [4:0] hours;
wire [5:0] mins, secs;
wire hour_carry;

/*----------
 *  Instantiation of the design
 *  The following statement connects signals defined above to ports of design
 *----------*/
TIME #(.CLOCKS4SEC(CLOCKS4SEC)) U1 (
    .clk(clk),               // input: system clock
    .increase(increase),     // input: 1 if need increasing hours, mins,secs 
    .reset_n(reset_n),       // input: master reset, active low
    .mode1(mode1),           // input: major mode, one of TIME/DATE/TIMER/...
    .mode2(mode2),           // input: minor mode, one of GEN/TIME_HOUR/...
    .hours(hours),           // output: current hours of day
    .mins(mins),             // output: current minutes
    .secs(secs),             // output: current seconds
    .hour_carry(hour_carry)  // output: 1 if day should be increased
);

// Clock signal generation
initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # half_clock_period clk = ~clk;
end


// Variables for test program.
integer i_hour, i_min, i_sec;     // loop indices
integer ii_hour, ii_min, ii_sec;  // 0~23 hours, 0~59 minutes
integer begin_sec;                // range of seconds
reg [4:0] hour_expected;   // expected value of hours
reg [5:0] min_expected;    // expected value of mins
reg expected, expected2;   // expected values
reg hour_carry_found;

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif

// Now, a test program follows.
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
     *  Set initial values although most of them had already been
     *  initialized by simulator.
     *----------*/
    increase = 0;
    mode1 = M1_TIME;
    mode2 = M2_TIME_G;
    reset_n = 1;      // normal state of active low signal

    /*----------
     *  Test reset.
     *----------*/
    // Perform reset.
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
    // Observe reset results.
    expected = (hours === 0 && mins === 0 && secs === 0);
    if (!expected)
        `perr(("hours, mins, and secs should be 0 at initial state."));
    expected = (hour_carry === 0);
    if (!expected) `perr(("hour_carry should be 0 at initial state."));

    // We change hour value by increasing hours.
    @ (posedge clk);        // synchronized at rising edge
    mode2 = M2_TIME_HOUR;   // hours increase mode
    @ (negedge clk);        // increase at falling edge
    # clock_period  increase = 1;     // Give increase signal
    # clock_period  increase = 0;
    expected = (hours !== 0);
    if (!expected) `perr(("hours must be increased by increase."));

    // We change minute value by increasing mins.
    @ (posedge clk);        // synchronized at rising edge
    mode2 = M2_TIME_MIN;    // mins increase mode
    @ (negedge clk);        // increase at falling edge
    # clock_period  increase = 1;     // Give increase signal
    # clock_period  increase = 0;
    expected = (mins !== 0);
    if (!expected) `perr(("mins must be increased by increase."));

    // We change second value by increasing secs.
    @ (posedge clk);        // synchronized at rising edge
    mode2 = M2_TIME_SEC;    // secs increase mode
    @ (negedge clk);        // increase at falling edge
    # clock_period  increase = 1;     // Give increase signal
    # clock_period  increase = 0;
    expected = (secs !== 0);
    if (!expected) `perr(("secs must be increased by increase."));

    // hours, mins, secs are all non-zero at this time.
    // We reset these values by asynchronous reset.
    $display("Testing asynchrous reset at %0t", $time);
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
    // Observe reset results.
    expected = ((hours === 0) && (mins === 0) && (secs === 0));
    if (!expected) `perr(("hours, mins, and secs should be 0 by reset_n."));
    expected2 = (hour_carry === 0);
    if (!expected2) `perr(("hour_carry should be 0 by reset_n."));
    if (expected && expected2)
        $display("We confirm that reset_n works at %0t.", $time);

    // Let time pass by.
    mode2 = M2_TIME_G;     // TIME general mode

    // Now, testing reset has been finished.
    // Wait for 1st change of time after reset.
    @ (hours or mins or secs);
    $display("1st change of time occurs at %0t", $time);
    expected = (hours === 0) && (mins === 0) && (secs === 1);
    if (!expected)
        `perr(("Time mismatch: hours:mins:secs = %0d:%0d:%0d.",
               hours, mins, secs));

    /*----------
     *  Observe time goes by for 24 hours
     *----------*/
    hour_carry_found = 0;
    # minimum_period;   // for safety guard
    for (i_hour = 0 ; i_hour <= 25 ; i_hour = i_hour+1) begin
        if (i_hour > 23)
            ii_hour = i_hour - 24;
        else
            ii_hour = i_hour;
        $display("Simulating hour is %0d", ii_hour);

        for (i_min = 0 ; i_min <= 59 ; i_min = i_min+1) begin
            if (i_hour == 0 && i_min == 0)
                begin_sec = 2;
            else
                begin_sec = 0;

            for (i_sec = begin_sec ; i_sec <= 59 ; i_sec = i_sec+1) begin
                # time_per_sec;

                expected = (i_sec === secs) && (i_min === mins) &&
                           (ii_hour === hours);
                if (!expected) begin
                    $write("Details on time mismatch below: expected = ");
                    $write("%0d:%0d:%0d,", ii_hour, i_min, i_sec);
                    $display(" signal = %0d:%0d:%0d.", hours, mins, secs);
                end
                if (!expected) `perr(("Time mismatch"));

                if (ii_hour === 23 && i_min === 59 && i_sec === 59) begin
                    if (hour_carry === 1)
                        hour_carry_found = 1;
                end else if (ii_hour === 0 && i_min === 0 && i_sec === 0) begin
                    if (hour_carry === 1) begin
                        expected = ~hour_carry_found;
                        if (!expected) `perr(("hour_carry is too long."));
                        hour_carry_found = 1;
                    end
                end else begin
                    expected = (hour_carry === 0);
                    if (!expected) `perr(("hour_carry asserted at wrong time."));
                end
            end  // seconds loop
        end  // minutes loop
    end  // hours loop
    if (!(hour_carry_found)) `perr(("hour_carry is not generated."));

    # time_per_sec;
    @ (posedge clk);    // synchronized at rising edge
    // hours increase mode
    # clock_period;
    mode2 = M2_TIME_HOUR;
    $display("TIME hours set testing begins at %0t", $time);

    @ (negedge clk);    // increase at falling edge
    for (i_hour = 3 ; i_hour <= 28 ; i_hour = i_hour+1) begin
        if (i_hour > 23)
            ii_hour = i_hour - 24;
        else
            ii_hour = i_hour;

        # clock_period  increase = 1;
        # clock_period  increase = 0;

        expected = (ii_hour === hours);
        if (!expected) `perr(("hours must be increased to %0d, signal = %0d",
                              ii_hour, hours));
        expected = (mins === 0 && secs === 0);
        if (!expected) `perr(("mins and secs should not be affected."));
    end

    /*----------
     *  Now, 04:00:00
     *----------*/
    hour_expected = 4;
    expected = (hours === hour_expected);
    if (!expected) `perr(("hours should be 4."));

    /*----------
     *  mins increase mode
     *----------*/
    @ (posedge clk);       // synchronized at rising edge
    mode2 = M2_TIME_MIN;
    $display("TIME mins set testing begins at %0t", $time);

    @ (negedge clk);       // increase at falling edge
    for (i_min = 1 ; i_min <= 80 ; i_min = i_min+1) begin
        if (i_min > 59)
            ii_min = i_min - 60;
        else
            ii_min = i_min;

        # clock_period  increase = 1;
        # clock_period  increase = 0;

        expected = (ii_min === mins);
        if (!expected) `perr(("mins must be increased to %0d, signal = %0d",
                               ii_min, mins));
        expected = (hours === hour_expected);
        if (!expected) `perr(("hours should be fixed to %0d, signal = %0d",
                               hour_expected, hours));
    end

    /*----------
     *  Now, 04:20:00
     *----------*/
    min_expected = 6'b010100;
    expected = (mins === min_expected);
    if (!expected) `perr(("mins should be 20."));

    /*----------
     *  secs increase mode
     *----------*/
    @ (posedge clk);       // synchronized at rising edge
    mode2 = M2_TIME_SEC;
    $display("TIME secs set testing begins at %0t", $time);

    @ (negedge clk);       // increase at falling edge
    for (i_sec = 1 ; i_sec <= 80 ; i_sec = i_sec+1) begin
        if (i_sec > 59)
            ii_sec = i_sec - 60;
        else
            ii_sec = i_sec;

        # clock_period  increase = 1;
        # clock_period  increase = 0;

        expected = (ii_sec === secs);
        if (!expected) `perr(("secs must be increased to %0d, signal = %0d",
                              ii_sec, secs));
        expected = (mins === min_expected);
        if (!expected) `perr(("mins should be fixed to $0d, signal = %0d",
                              min_expected, mins));
        expected = (hours === hour_expected);
        if (!expected) `perr(("hours should be fixed to %0d, signal = %0d",
                              hour_expected, hours));
    end

    /*----------
     *  Back to general (time-passing) mode.
     *----------*/
    @ (posedge clk);        // synchronized at rising edge
    mode2 = M2_TIME_G;
    # clock_period;

    disable CLOCK_GENERATOR;
    $display("SIMULATION TERMINATED at %0t", $time);
    $stop(2);
end
endmodule

/*--- TIME_test ---*/
