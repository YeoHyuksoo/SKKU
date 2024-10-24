/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : alarm_tb.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write her/his student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 12, 2018  (version 1.0)
 *  Version    : 1.1
 *  Design     : Homework #4
 *               Test bench of ALARM_SET (in file 'selector.v')
 *
 *  Modification History:
 *      * version 1.1, Oct 30, 2019  by Hyoung Bok Min
 *        - macro perr()'s are used instead of $error()'s.
 *      * version 1.0, July 12, 2018  by Hyoung Bok Min
 *        v1.0 released.
 *
 *  NOTE :
 *      (1) If you want to test alarm module separately from selector,
 *          you can use this testbench.
 *      (2) This testbench works only if you design an entity ALARM_SET for
 *          alarm generator inside the selector module. In other words,
 *          if you design alarm generator as a process, you cannot use this
 *          testbench.
 *      (3) The name of entity for the alarm module should be 'ALARM_SET', and
 *          ports of the entity 'ALARM_SET' should match the declaration of
 *          component 'ALARM_SET' in this testbench.
 *  
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*---------------------------
 *  MODULE: ALARM_test
 *
 * Testbench for module ALARM_SET in selector.v
 *---------------------------*/

module ALARM_test;

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
parameter RESET_FORM = 0;     // reset waveform: 0 ~ 3
parameter RESET_PERIOD = 1;   // shall be non-negative

// Definitions of mode1/mode2 values
`include "dclockshare.v"


// signals on which logic values will be assigned
reg clk, increase, set, reset_n;
reg [1:0] mode1, mode2;
reg [4:0] hours;
reg [5:0] mins;

// signals which will be observed
wire [4:0] alarm_h;
wire [5:0] alarm_m;
wire alarm;

/*----------
 *  Instantiation of the design
 *  The following statement connects signals defined above to ports of design
 *----------*/
ALARM_SET U1 (
    .clk(clk),             // input: system clock
    .increase(increase),   // input: 1 when setting alarm-hour and alarm-min
    .set(set),             // input: snooze button
    .reset_n(reset_n),     // input: asynchronous reset, active-low
    .mode1(mode1),         // input: major modes (one of TIME/DATE/TIMER/ALARM)
    .mode2(mode2),         // input: minor modes accodring to the major mode
    .hours(hours),         // input: current hour
    .mins(mins),           // input: current minues
    .alarm_h(alarm_h),     // output: alarm hour setting
    .alarm_m(alarm_m),     // output: alarm minutes setting
    .alarm(alarm)          // output: 1 if alarm rings
);

// Clock signal generation
initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # half_clock_period clk = ~clk;
end


/**
 *  Record last event time of alarm.
 *  Note that alarm is stable during last_event which is
 *  "$time-alarm_stable_since".
 */
time one_clock_period = clock_period;
time last_event = 0;
time alarm_stable_since = 0;

always @ (posedge alarm or negedge alarm)
begin : STABLE_ALARM
    alarm_stable_since = $time;
end

// Variables for test process.
integer i_mode, i_hour, i_min, i_sec, i_secc;
integer ii_hour, ii_min;
reg [4:0] saved_hours;
reg [5:0] saved_mins;
reg [4:0] hour_exp;
reg expected;

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif

/*---------------------
 *  Now, test begins
 *---------------------*/
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
     *  Set initial values although they had already been initialized
     *  by simulator. Also, perform master reset.
     *----------*/
    increase = 0;
    set = 0;
    mode1 = M1_ALARM;   // ALARM mode
    mode2 = M2_ALARM_G;
    hours = 0;
    mins = 0;
    reset_n = 1;        // normal state of active low signal

    // Activate asynchronous reset.
    # minimum_period;
    reset_n = 0;        // activate reset of active low
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
    reset_n = 1;        // back to normal state

    @ (posedge clk);   // simulation begins at rising edge

    // Check initial state.
    // alarm_h, alarm_m are outputs of ALARM module at ALARM mode.
    expected = (alarm_h === 0 && alarm_m === 0);
    if (!expected) `perr(("Init value of alarm_h and alarm_m should be 0."));
    expected = (alarm === 0);
    if (!expected) `perr(("Init value of ALARM should be 0."));


    /*-------------------------------------------------------------------
     *  [1] Now, begin ALARM mode testing.
     *-------------------------------------------------------------------*/
    $display("Begin testing ALARM Mode at %0t", $time);
    mode1 = M1_ALARM;     // ALARM mode
    mode2 = M2_ALARM_G;
    hours = 5'b11111;     // to avoid ALARM during ALARM HOUR setting test

    // HOUR increase mode
    # clock_period;
    mode2 = M2_ALARM_HOUR;  // ALARM time has ever been set.
    $display("ALARM HOUR set testing begins at %0t", $time);

    @ (negedge clk);        // increase at falling edge
    for (i_hour = 1 ; i_hour <= 26 ; i_hour = i_hour+1) begin
        if (i_hour > 23)
            ii_hour = i_hour - 24;
        else
            ii_hour = i_hour;

        # clock_period  increase = 1;
        # clock_period  increase = 0;

        expected = (ii_hour === alarm_h);
        if (!expected) `perr(("ALARM hours must be increased to %0d", ii_hour));
        expected = (alarm_m === 0);
        if (!expected) `perr(("ALARM minutes should not be affected."));
    end
    hours = 0;   // -- back to normal hour

    // Now, 02:00
    expected = (alarm_h === 2);
    if (!expected) `perr(("ALARM hours should be 2."));
    expected = (alarm_m === 0);
    if (!expected) `perr(("ALARM minutes should be 0."));

    // MINUTE increase mode
    @ (posedge clk);   // simulation synched at rising edge
    mode2 = M2_ALARM_MIN;
    $display("ALARM MIN set testing begins at %0t", $time);

    @ (negedge clk);   // increase at falling edge
    i_hour = 2;
    hour_exp = i_hour;
    for (i_min = 1 ; i_min <= 70 ; i_min = i_min+1) begin
        if (i_min > 59)
            ii_min = i_min - 60;
        else
            ii_min = i_min;

        # clock_period  increase = 1;
        # clock_period  increase = 0;

        expected = (ii_min === alarm_m);
        if (!expected) `perr(("%s%0d%s%0d",
                             "ALARM minutes must be increased to ", ii_min,
                             ", signal = ", alarm_m));
        expected = (alarm_h === hour_exp);
        if (!expected) `perr(("%s%0d%s%0d",
                             "ALARM hours should be fixed to ", hour_exp,
                             ", signal = ", alarm_h));
    end

    /*-------------------------------------------------------------------
     *  [2] ALARM testing.
     *-------------------------------------------------------------------*/
    $display("%s", {"ALARM is set to 02:10. ",
             "We'll see whether ALARM is generated."});
    @ (posedge clk);
    mode1 = M1_ALARM;     // ALARM mode
    mode2 = M2_ALARM_G;   // mode to display alarm hours/minutes
    # clock_period;
    saved_hours = alarm_h;  // save current setting of alarm hours
    saved_mins = alarm_m;   // save current setting of alarm minutes
    expected = (saved_hours === 2 && saved_mins === 10);
    if (!expected) `perr(("ALARM time setting is not 2:10, signal = %0d:%0d",
                         saved_hours, saved_mins));

    mode1 = M1_TIME;
    mode2 = M2_TIME_G;
    # clock_period;
    expected = (alarm === 0);
    if (!expected) `perr(("No ALARM is expected at this time."));

    /*----------
     *  Set hour/min for alarm.
     *----------*/
    hours = saved_hours;
    mins  = saved_mins;
    # (10*clock_period);
    $display("Current time is %2d:%2d", hours, mins);
    expected = (alarm === 1);
    if (!expected) `perr(("ALARM is expected."));
    if (expected) $display("Yes, we got ALARM.");

    /*----------
     *  Turn off alarm.
     *----------*/
    @ (negedge clk);
    $display("%s", {"We'll turn off the ALARM.",
             " Let's see it really turned off."});
    $display("Current time is %0d:%0d", hours, mins);
    # (10*clock_period);
    set = 1;
    # (10*clock_period);
    set = 0;
    # (10*clock_period);
    expected = (alarm === 0);
    if (!expected) `perr(("ALARM should be turned off."));
    if (expected) $display("Yes, ALARM turned off.");

    /*----------
     *  Set hour/min for alarm again.
     *----------*/
    $display("%s", {"We'll test ALARM again, and ",
             "we'll see whether ALARM is generated."});
    @ (posedge clk);
    // change time to activate alarm.
    hours = 0;
    mins  = 0;
    # (10*clock_period);

    // set current time to alarm time.
    hours = saved_hours;
    for (i_min = 0 ; i_min <= 5 ; i_min = i_min+1) begin
        mins = saved_mins + i_min;
        # (10*clock_period);
        $write("Current time is %0d:%0d: ", hours, mins);

        expected = (alarm === 1);
        if (!expected) begin
            $display("No, alarm is not detected.");
            `perr(("ALARM is expected."));
        end else begin
            $display("Yes, we got ALARM.");
        end
    end

    last_event = $time - alarm_stable_since;
    expected = (last_event >= 50*one_clock_period);
    if (!expected) `perr(("ALARM should last until turned off."));

    /*----------
     *  Turn off alarm.
     *----------*/
    @ (negedge clk);
    $display("%s", {"We'll turn off the ALARM.",
             " Let's see it really turned off."});
    # (10*clock_period);
    set = 1;
    # (10*clock_period);
    set = 0;
    # (10*clock_period);

    expected = (alarm === 0);
    if (!expected) `perr(("ALARM should be turned off."));
    if (expected) $display("Yes, ALARM turned off.");

    for (i_min = 11 ; i_min <= 15 ; i_min = i_min+1) begin
        mins = saved_mins + i_min;
        # (10*clock_period);
    end
    last_event = $time - alarm_stable_since;
    expected = (last_event >= 50*one_clock_period);
    if (!expected) `perr(("%s", {"ALARM should be off until newly set or ",
                         "until it becomes the time again."}));

    /*-------------------------------------------------------------------
     *  [3] reset_n (Asynchronous reset) testing.
     *-------------------------------------------------------------------*/
    $display("Testing asynchronous reset begins at %0t", $time);
    // Go to ALARM mode
    @ (posedge clk);
    mode1 = M1_TIME;     // reset_n should work at any mode
    mode2 = M2_TIME_G;   // ALARM has not been set since this is "00".
    # clock_period;

    // Activate asynchronous reset.
    # (2*minimum_period);
    reset_n = 0;       // activate reset of active low
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
    reset_n = 1;       // back to normal state

    @ (posedge clk);   // at rising edge

    // Check reset state.
    // alarm_h and alarm_m are outputs of ALARM module at ALARM mode.
    expected = (alarm_h === 0 && alarm_m === 0);
    if (!expected) `perr(("ALARM H/M should be 0 by reset_n."));
    expected = (alarm === 0);
    if (!expected) `perr(("ALARM should be 0 by reset_n."));
    if (alarm_h === 0 && alarm_m === 0) begin
        if (alarm === 0)
            $display("We confirm that reset_n works at %0t", $time);
    end

    // Terminates simulation.
    # clock_period;
    disable CLOCK_GENERATOR;
    $display("SIMULATION TERMINATED at %0t", $time);
    $stop(2);
end
endmodule

/*--- ALARM_test ---*/
