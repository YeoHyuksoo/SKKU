/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : sel_tb.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write her/his student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 12, 2018  (version 1.0)
 *  Version    : 1.1
 *  Design     : Homework #4
 *               Test bench of SELECTOR
 *
 *  Modification History:
 *      * version 1.1, Oct 30, 2019  by Hyoung Bok Min
 *        - macro perr()'s are used instead of $error()'s.
 *      * version 1.0, July 12, 2018  by Hyoung Bok Min
 *        version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*---------------------------
 *  MODULE: SELECTOR_test
 *
 *  Testbench for module SELECTOR in selector.v
 *---------------------------*/

module SELECTOR_test;

/*------------------------------------------------------------
 *  Time costants
 *  WARNING: Please do not assume that clock period is a specific value.
 *           These time parameters may be changed when grading, and
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
 *  Maximum number of error messages of the same type to be printed.
 *------------------------------------------------------------*/
parameter  MAX_ERRORS = 20;
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
reg [5:0] mins, secs;
reg [3:0] mon;
reg [4:0] day;
reg [5:0] min_sw, sec_sw;
reg [3:0] secc_sw;

// signals which will be observed
wire [5:0] out_h, out_m, out_s;
wire alarm;

/*----------
 *  Instantiation of the design:
 *  The following statement connects signals defined above to ports of design.
 *----------*/
SELECTOR U1 (
    .clk(clk),            // input: system clock
    .increase(increase),  // input: increase alarm hours/minutes if this is 1
    .set(set),            // input: snooze button
    .reset_n(reset_n),    // input: asynchronous reset, active low
    .mode1(mode1),        // input: major modes
    .mode2(mode2),        // input: minor modes
    .hours(hours),        // input: current hours
    .mins(mins),          // input: current minutes 
    .secs(secs),          // input: current seconds
    .mon(mon),            // input: month of this day
    .day(day),            // input: day of this day
    .min_sw(min_sw),      // input: timer minutes
    .sec_sw(sec_sw),      // input: timer seconds
    .secc_sw(secc_sw),    // input: timer 1/10 seconds
    .out_h(out_h),        // output: 4-to-1 mux output for hours/mon/alarm_h
    .out_m(out_m),        // output: 4-to-1 mux output for mins/day/alarm_m
    .out_s(out_s),        // output: 4-to-1 mux output for secs/0/0
    .alarm(alarm)         // output: 1 if alarm rings
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


// Variables for test program
integer i_mode, i_hour, i_min, i_sec, i_secc;
integer ii_hour, ii_min;
reg [5:0] v_hour, v_min;
reg [5:0] v_day, v_mon, v_secc_sw;
reg [5:0] hour_exp;
reg assertion, be_quiet, expected;
integer num_errors;

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif

/*-------------------------------------------------------------------
 *  Now, test begins
 *-------------------------------------------------------------------*/
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
    mode1 = M1_ALARM;    // ALARM mode
    mode2 = M2_ALARM_G;
    hours = 0;
    mins = 0;
    secs = 0;
    mon = 1;
    day = 1;
    min_sw = 0;
    sec_sw = 0;
    secc_sw = 0;
    reset_n = 1;         // normal state of active low signal

    // Activate asynchronous reset.
    # minimum_period;
    reset_n = 0;      // activate reset of active low
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
    reset_n = 1;      // back to normal state

    @ (posedge clk);  // simulation begins at rising edge

    // Check initial state.
    // out_h, out_m, out_s are outputs of ALARM module at ALARM mode.
    expected = (out_h === 0 && out_m === 0 && out_s === 0);
    if (!expected) `perr(("Init value of OUT's should be 0."));
    expected = (alarm === 0);
    if (!expected) `perr(("Init value of ALARM should be 0."));


    /*-------------------------------------------------------------------
     *  [1] Now, Test out_h, out_m, out_s.
     *-------------------------------------------------------------------*/
    $display("Begin testing of SELECTOR part at %0t", $time);
    $display("Time Mode at %0t", $time);
    mode1 = M1_TIME;    // time mode
    # clock_period;
    for (i_mode = 0 ; i_mode <= 3 ; i_mode = i_mode+1) begin
        case (i_mode)
            0 : begin
                    mode2 = M2_TIME_G;
                    $display("    Time General Mode at %0t", $time);
                end
            1 : begin
                    mode2 = M2_TIME_HOUR;
                    $display("    Time Hour Mode at %0t", $time);
                end
            2 : begin
                    mode2 = M2_TIME_MIN;
                    $display("    Time Minute Mode at %0t", $time);
                end
            3 : begin
                    mode2 = M2_TIME_SEC;
                    $display("    Time Second Mode at %0t", $time);
                end
        endcase

        num_errors = 0;
        be_quiet = 0;   // false
        for (i_hour = 0 ; i_hour <= 24 ; i_hour = i_hour+1) begin
            for (i_min = 0 ; i_min <= 59 ; i_min = i_min+1) begin
                for (i_sec = 0 ; i_sec <= 59 ; i_sec = i_sec+1) begin
                    assertion = (out_h === {1'b0, hours} && out_m === mins &&
                                 out_s === secs);
                    if (!be_quiet) begin
                        if (!assertion) `perr(("Selector output mismatch."));
                    end
                    if (!assertion) begin
                        num_errors = num_errors + 1;
                        if (num_errors >= MAX_ERRORS)
                            be_quiet = 1;   // true
                    end

                    secs = secs + 1;
                    # clock_period;
                end   // seconds

                mins = mins + 1;
                # clock_period;
            end   // minutes

            v_hour = {1'b0, (hours+1)};
            hours = v_hour[4:0];
            # clock_period;
        end   // hour

        expected = (!be_quiet);
        if (!expected) `perr(("%s%0d%s", "Mismatch:: ", num_errors,
                              " Selector output mismatches are found."));
    end   // mode

    $display("Date Mode at %0t", $time);
    mode1 = M1_DATE;    // date mode
    # clock_period;
    for (i_mode = 0 ; i_mode <= 3 ; i_mode = i_mode+1) begin
        mode2 = i_mode;
        num_errors = 0;
        be_quiet = 0;    // false
        for (i_hour = 0 ; i_hour <= 12 ; i_hour = i_hour+1) begin
            for (i_min = 0 ; i_min <= 31 ; i_min = i_min+1) begin
                assertion = (out_h === {2'b00, mon} && out_m === {1'b0, day}
                             && out_s === 6'b000000);
                if (!be_quiet) begin
                    if (!assertion) `perr(("Selector output mismatch."));
                end
                if (!assertion) begin
                    num_errors = num_errors + 1;
                    if (num_errors >= MAX_ERRORS)
                        be_quiet = 1;   // true
                end

                v_day = {1'b0, (day+1)};
                day = v_day[4:0];
                # clock_period;
            end   // day

            v_mon = {2'b00, (mon+1)};
            mon = v_mon[3:0];
            # clock_period;
        end   // mon

        expected = (!be_quiet);
        if (!expected) `perr(("%s%0d%s", "Mismatch:: ", num_errors,
                              " Selector output mismatches are found."));
    end   // mode

    $display("Timer Mode at %0t", $time);
    mode1 = M1_TIMER;    // timer mode
    # clock_period;
    for (i_mode = 0 ; i_mode <= 3 ; i_mode = i_mode+1) begin
        mode2 = i_mode;
        num_errors = 0;
        be_quiet = 0;    // false
        for (i_min = 0 ; i_min <= 59 ; i_min = i_min+1) begin
            for (i_sec = 0 ; i_sec <= 59 ; i_sec = i_sec+1) begin
                for (i_secc = 0 ; i_secc <= 9 ; i_secc = i_secc+1) begin
                    assertion = (out_h === min_sw && out_m === sec_sw
                                 && out_s === {2'b00, secc_sw});
                    if (!be_quiet) begin
                        if (!assertion) `perr(("Selector output mismatch."));
                    end
                    if (!assertion) begin
                        num_errors = num_errors + 1;
                        if (num_errors >= MAX_ERRORS)
                            be_quiet = 1;   // true
                    end

                    v_secc_sw = {2'b00, (secc_sw+1)};
                    secc_sw <= v_secc_sw[3:0];
                    # clock_period;
                end   // secc

                sec_sw = sec_sw + 1;
                # clock_period;
            end   // seconds

            min_sw = min_sw + 1;
            # clock_period;
        end   // minutes

        expected = (!be_quiet);
        if (!expected) `perr(("%s%0d%s", "Mismatch:: ", num_errors,
                              " Selector output mismatches are found."));
    end   // mode

    /*-------------------------------------------------------------------
     *  [2] Now, begin ALARM mode testing.
     *-------------------------------------------------------------------*/
    $display("Begin testing ALARM Mode at %0t", $time);
    mode1 = M1_ALARM;    // alarm mode
    mode2 = M2_ALARM_G;
    hours = 5'b11111;    // to avoid alarm during ALARM hour setting test

    // HOUR increase mode
    # clock_period;
    mode2 = M2_ALARM_HOUR;
    $display("ALARM HOUR set testing begins at %0t", $time);

    @ (negedge clk);   // increase at falling edge
    for (i_hour = 1 ; i_hour <= 26 ; i_hour = i_hour+1) begin
        if (i_hour > 23)
            ii_hour = i_hour - 24;
        else
            ii_hour = i_hour;

        # clock_period  increase = 1;
        # clock_period  increase = 0;

        expected = (ii_hour === out_h);
        if (!expected) `perr(("hours must be increased to %0d but %0d", ii_hour, out_h));
        expected = (out_m === 0);
        if (!expected) `perr(("MINUTE should not be affected."));
    end
    hours = 0;   // back to normal hour

    // Now, 02:00
    if (!(out_h === 2)) `perr(("hours should be 2."));
    if (!(out_m === 0)) `perr(("MINUTE should be 0."));

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

        expected = (ii_min === out_m);
        if (!expected) `perr(("%s%0d%s%0d", "mins must be increased to ",
                              ii_min, ", signal = ", out_m));
        expected = (out_h === hour_exp);
        if (!expected) `perr(("%s%0d%s%0d", "hours should be fixed to ",
                              hour_exp, ", signal = ", out_h));
    end

    /*-------------------------------------------------------------------
     *  [3] ALARM testing.
     *-------------------------------------------------------------------*/
    $display("%s%s", "ALARM is set to 02:10. ",
             "We'll see whether ALARM is generated.");
    @ (posedge clk);
    mode1 = M1_ALARM;
    mode2 = M2_ALARM_G;
    # clock_period;
    v_hour = out_h;
    v_min = out_m;

    mode1 = M1_TIME;
    mode2 = M2_TIME_G;
    # clock_period;
    expected = (alarm === 0);
    if (!expected) `perr(("No ALARM is expected at this time."));

    /*----------
     *  Set hour/min for alarm.
     *----------*/
    hours = v_hour[4:0];
    mins  = v_min;
    # (10*clock_period);
    $display("Current time is %0d:%0d", hours, mins);
    expected = (alarm === 1);
    if (!expected) `perr(("ALARM is expected."));
    if (expected) $display("Yes, we got ALARM.");

    /*----------
     *  Turn off alarm.
     *----------*/
    @ (negedge clk);
    $display("%s%s", "We'll turn off the ALARM.",
             " Let's see it really turned off.");
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
    $display("%s%s", "We'll test ALARM again, and ",
             "we'll see whether ALARM is generated.");
    @ (posedge clk);
    // change time to activate alarm.
    hours = 0;
    mins  = 0;
    # (10*clock_period);

    // set current time to alarm time.
    hours = v_hour[4:0];
    for (i_min = 0 ; i_min <= 5 ; i_min = i_min+1) begin
        mins = v_min + i_min;
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
    $display("%s%s", "We'll turn off the ALARM.",
             " Let's see it really turned off.");
    # (10*clock_period);
    set = 1;
    # (10*clock_period);
    set = 0;
    # (10*clock_period);
    expected = (alarm === 0);
    if (!expected) `perr(("ALARM should be turned off."));
    if (expected) $display("Yes, ALARM turned off.");
    for (i_min = 11 ; i_min <= 15 ; i_min = i_min+1) begin
        mins = v_min + i_min;
        # (10*clock_period);
    end

    last_event = $time - alarm_stable_since;
    expected = (last_event >= 50*one_clock_period);
    if (!expected) `perr(("%s%s", "ALARM should be off until newly set or ",
                          "until it becomes the time again."));

    /*-------------------------------------------------------------------
     *  [4] reset_n (Asynchronous reset) testing.
     *-------------------------------------------------------------------*/
    $display("Testing asynchronous reset begins at %0t", $time);
    // Go to ALARM mode
    @ (posedge clk);
    mode1 = M1_TIME;    // reset_n should work at any mode.
    mode2 = M2_TIME_G;  // ALARM has not been set since this is "00".
    # clock_period;

    // Activate asynchronous reset.
    # (2*minimum_period);
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

    mode1 = M1_ALARM;   // Set MUX to ALARM mode to read the ALARM time, etc.
    @ (posedge clk);    // at rising edge

    // Check reset state.
    // out_h, out_m, out_s are outputs of ALARM module at ALARM mode.
    expected = (out_h === 0 && out_m === 0 && out_s === 0);
    if (!expected) `perr(("ALARM H/M/S should be 0 by reset_n."));
    expected = (alarm === 0);
    if (!expected) `perr(("ALARM should be 0 by reset_n."));
    if (out_h === 0 && out_m === 0 && out_s === 0) begin
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

/*--- SELECTOR_test ---*/
