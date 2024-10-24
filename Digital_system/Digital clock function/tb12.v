/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : tb12.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write his/her student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 11, 2018  (version 1.0)
 *  Version    : 1.1
 *  Design     : Homework #3
 *               Testbench of MODE_GEN + TIME + DATE + TIMER
 *
 *  Modification History:
 *      * version 1.1, Oct 30, 2019  by Hyoung Bok Min
 *        - macro perr()'s are used instead of $error()'s.
 *      * version 1.0, July 11, 2018  by Hyoung Bok Min
 *        v1.0 released
 *
 *  NOTE: This testbench assumes the followings.
 *
 *  (1) All switches are pressed and released at falling of system clock.
 *  (2) mode1 and mode2 will be changed at rising edge of clock.
 *  (3) Initial state is TIME GENERAL state.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*---------------------------
 *  MODULE: BLOCK12_test
 *
 *  Testbench for a block which is a combination of MODE_GEN, TIME, DATE, and
 *  TIMER modules.
 *---------------------------*/

module BLOCK12_test;

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

/*------------------------------------------------------------------
 *  NOTE 1:
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
 *  'time.v' and in another testbench file 'time_tb.v'. The simulation
 *  run time in 'time.do' and 'tb12.do' should also be modified.
 *
 *  NOTE 2:
 *  Although we count 10 clocks to measure a second in this testbench,
 *  we assume that we use system clock of 100 Hz for TIMER as given at the
 *  design specification. In other words, you have to count 10 clocks
 *  to measure 0.1 second (secc_sw), and you have to count 100 clocks
 *  to measure 1 second (sec_sw) when you design your TIMER.
 *------------------------------------------------------------------*/
// CLOCKS4SEC : number of clocks in order to measure a second
parameter  CLOCKS4SEC = 100;
localparam time_per_sec = CLOCKS4SEC * clock_period;
/*------------------------------------------------------------------*/

/*------------------------------------------------------------------
 *  Maximum number of error messages printed if they are of same type.
 *------------------------------------------------------------------*/
parameter  MAX_ERRORS = 20;
/*------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  SWITCH_FORM
 *       Choice of waveform of switch (sw1, sw2, set) press.
 *       You have to choose a natural number of range 0 thru 6 as follows.
 *
 *               -------+          +----------+
 *          clk         +----------+          +-------
 *
 *                      +------------------+
 *            0  -------+                  +----------
 *
 *                      +---------------------+
 *            1  -------+                     +-------
 *
 *                         +---------------+
 *            2  ----------+               +----------
 *
 *                         +------------------+
 *            3  ----------+                  +-------
 *
 *                   +---------------------+
 *            4  ----+                     +----------
 *
 *                   +------------------------+
 *            5  ----+                        +-------
 *
 *                      +-------------+   +---+
 *            6  -------+             +---+   +-------
 *
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
parameter SWITCH_FORM = 0,    // switch waveform: 0 ~ 6
          RESET_FORM  = 0;    // reset waveform: 0 ~ 3
parameter RESET_PERIOD = 1;   // shall be non-negative

// Definitions of mode1/mode2 values
`include "dclockshare.v"


// signals on which logic values will be assigned
reg clk, sw1, sw2, set, reset_n;

// internal signals
wire [1:0] mode1, mode2;
wire increase, hour_carry;

// output signals at this homework
wire [4:0] hours;
wire [5:0] mins, secs;
wire [3:0] mon;
wire [4:0] day;
wire [5:0] min_sw, sec_sw;
wire [3:0] secc_sw;


/*----------
 *  Press button (one of sw1, sw2, set)
 *----------*/
task press (
    input [1:0] switch     // 1 for sw1, 2 for sw2, 0 for set
);
begin
    // delay before button press
    if (switch == 1 | switch == 2) begin
        @ (posedge clk);
        case (SWITCH_FORM)
            0, 1 :
                @ (negedge clk);
            2, 3 : begin
                @ (negedge clk);
                # minimum_period;
            end
            4, 5 :
                # (half_clock_period - minimum_period);
            default :
                @ (negedge clk);
        endcase
    end

    // press button
    if (switch == 1)
        sw1 = 1'b1;
    else if (switch == 2)
        sw2 = 1'b1;
    else
        set = 1'b1;

    // duration of button press
    case (SWITCH_FORM)
        0, 3 :  # (clock_period - minimum_period);
        1, 4 :  # clock_period;
        2    :  # (clock_period - 2*minimum_period);
        5    :  # (clock_period + minimum_period);
        default : begin
            # (half_clock_period + minimum_period);
            if (switch == 1)
                sw1 = 1'b0;
            else if (switch == 2)
                sw2 = 1'b0;
            else
                set = 1'b0;
            # (2*minimum_period);
            if (switch == 1)
                sw1 = 1'b1;
            else if (switch == 2)
                sw2 = 1'b1;
            else
                set = 1'b1;
            # (2*minimum_period);
        end
    endcase

    // release button
    if (switch == 1)
        sw1 = 1'b0;
    else if (switch == 2)
        sw2 = 1'b0;
    else
        set = 1'b0;

    // delay after button release
    case (SWITCH_FORM)
        0, 2, 4 :  # minimum_period;
        default :  ;
    endcase
end
endtask

/*----------
 *  Check whether the new time is larger than old time by 1.
 *  Return true if new = old+1,
 *         false otherwise.
 *  new time : i_min, i_sec, and i_secc
 *  old time : o_min, o_sec, and o_secc
 *----------*/
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

/**
 *  Given a time of a day in hour, minumtes, and seconds (3 integers),
 *  wait until the time hours:minutes:seconds.
 *
 *  Time glitch may occurs due to difference of delays between the
 *  3 integers, and we check the time again after a clock period.
 *
 *  Since we use 1 clock for checking the time glitch, this clock must use
 *  more than 1 clock to measure a second.
 */
task wait_time_until (
    input integer to_hours, to_mins, to_secs,
    input integer from_hours, from_mins, from_secs
);
reg equal;
reg [31:0] elapse_secs;
begin
    // seconds which we shall wait to reach to_hours:to_mins:to_secs.
    elapse_secs = (to_hours - from_hours)*60*60;
    elapse_secs = elapse_secs + (to_mins - from_mins)*60;
    elapse_secs = elapse_secs + (to_secs - from_secs);
    elapse_secs = elapse_secs * time_per_sec;
    elapse_secs = elapse_secs + clock_period;  // 1 clock guard

    fork
        begin : WAIT_UNTIL_THE_TIME
            equal = 1'b0;
            while (!equal) begin
                // The following wait may expire even when time glitches.
                wait (hours === to_hours && mins === to_mins &&
                      secs === to_secs);

                // We check time after a clock to decide whether this is the
                // correct time or a glitch. If it is not a glitch, exit loop.
                // If it is a glitch, wait until target time again.
                @ (posedge clk);
                equal = hours === to_hours && mins === to_mins &&
                        secs === to_secs;
            end
        end
        begin : TIME_EXPIRED
            # (elapse_secs);
            equal = hours === to_hours && mins === to_mins && secs === to_secs;
            if (!equal) begin
                // Time has not been reached, and timeout has occured
                disable WAIT_UNTIL_THE_TIME;
                `perr(("Time %0d:%0d:%0d %s %0d: %s (now is %0d:%0d:%0d).",
                        to_hours, to_mins, to_secs,
                        "has not been reached after time unit", elapse_secs,
                        "timeout has occurred", hours, mins, secs));
            end
        end
    join
end
endtask

// Function to return maximum days of given month
function [4:0] max_days_of_month (
    input [3:0] month
);
begin
    case (month)
        1, 3, 5, 7, 8, 10, 12 : max_days_of_month = 31;
        4, 6, 9, 11 :           max_days_of_month = 30;
        2 :                     max_days_of_month = 28;
        default :               max_days_of_month = 0;
    endcase
end
endfunction


/*----------
 *  Instantiation of the design
 *  The following statement connects signals defined above to
 *  ports of design.
 *----------*/
MODE_GEN U1 (.clk(clk),
        .sw1(sw1), .sw2(sw2), .set(set), .reset_n(reset_n),  // inputs
        .mode1(mode1), .mode2(mode2), .increase(increase));  // outputs
TIME #(.CLOCKS4SEC(CLOCKS4SEC)) U2 (.clk(clk),
        .increase(increase), .reset_n(reset_n),           // inputs
        .mode1(mode1), .mode2(mode2),                     // inputs
        .hours(hours), .mins(mins), .secs(secs),          // outputs
        .hour_carry(hour_carry));                         // outputs
DATE  U3 (.clk(clk),
        .hour_carry(hour_carry), .increase(increase),     // inputs
        .reset_n(reset_n), .mode1(mode1), .mode2(mode2),  // inputs
        .mon(mon), .day(day));                            // outputs
TIMER U4 (.clk(clk),
        .reset_n(reset_n), .mode1(mode1), .mode2(mode2),       // inputs
        .min_sw(min_sw), .sec_sw(sec_sw), .secc_sw(secc_sw));  // outputs

// Clock signal generation.
initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # half_clock_period clk = ~clk;
end


// Variables used in test process.
integer i_hour, i_min, i_sec;
integer ii_hour, ii_min, ii_sec, begin_sec;
reg [4:0] hour_expected;
reg [5:0] min_expected;
reg hour_carry_found;

integer i_mon, i_day, ii_mon, ii_day;
integer day_begin, day_end, max_day;
reg [3:0] mon_expected;

reg ok;
integer count, i_secc;
integer o_min, o_sec, o_secc;

// The following variables are used to count error messages.
reg expec, expec2, be_quiet, expected;
integer num_errors;

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif

/*----------
 *  Now, test begins.
 *----------*/
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
     *  initialized by simulator. Perform master reset, too.
     *----------*/
    sw1 = 0;
    sw2 = 0;
    set = 0;
    reset_n = 1;    // normal state of active low signal

    # minimum_period;
    reset_n = 0;    // activate asynchronous reset which is active low.
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
    reset_n = 1;    // back to normal state.

    /*--------------------------------------------------------
     *  [1] TIME test.
     *--------------------------------------------------------*/

    // Wait for 1st change of time.
    @(hours or mins or secs);
    $display("1st change of time occurs at %0t", $time);
    expected = (hours === 0 && mins === 0 && secs === 1);
    if (!expected)
        `perr(("Time mismatch: hours:mins:secs = %0d:%0d:%0d.",
               hours, mins, secs));
    $display("Start testing to see whether time passes by");

    // Observe time goes by for 24 hours.
    num_errors = 0;
    be_quiet = 0;           // false
    hour_carry_found = 0;   // false
    # minimum_period;       // for safety guard
    for (i_hour = 0 ; i_hour <= 25 ; i_hour = i_hour+1) begin
        if (i_hour > 23)
            ii_hour = i_hour - 24;
        else
            ii_hour = i_hour;
        $display("Simulating hour %0d", ii_hour);

        for (i_min = 0 ; i_min <= 59 ; i_min = i_min+1) begin
            if (i_hour == 0 && i_min == 0)
                begin_sec = 2;
            else
                begin_sec = 0;

            for (i_sec = begin_sec ; i_sec <= 59 ; i_sec = i_sec+1) begin
                # time_per_sec;
                expec = (i_sec === secs && i_min === mins && ii_hour === hours);
                if (!be_quiet) begin
                    if (!expec) begin
                        $write("Details on time mismatch below: expected = ");
                        $write("%0d:%0d:%0d,", ii_hour, i_min, i_sec);
                        $display(" signal = %0d:%0d:%0d.", hours, mins, secs);
                    end
                    if (!expec) `perr(("Time mismatch"));
                end
                if (!expec) begin
                    num_errors = num_errors + 1;
                    if (num_errors >= MAX_ERRORS)
                        be_quiet = 1;
                end

                if (ii_hour === 23 && i_min === 59 && i_sec === 59) begin
                    if (hour_carry == 1)
                        hour_carry_found = 1;
                end else if (ii_hour === 0 && i_min === 0 && i_sec === 0) begin
                    if (hour_carry == 1) begin
                        expected = (!hour_carry_found);
                        if (!expected) `perr(("hour_carry is too long."));
                        hour_carry_found = 1;
                    end
                end else begin
                    expected = (hour_carry === 0);
                    if (!expected) `perr(("hour_carry asserted at wrong time."));
                end
            end   // seconds loop
        end  // minutes loop
    end   // hours loop
    expected = (!be_quiet);
    if (!expected) `perr(("Mismatch:: %0d TIME output mismatches are found.",
                          num_errors));
    expected = hour_carry_found;
    if (!expected) `perr(("hour_carry is not generated."));

    # time_per_sec;
    expected = (hours === 2);
    if (!expected) `perr(("hours should be 2."));
    $display("END of Time general mode testing");

    @(negedge clk);    // switch synched at falling edge
    // Go to hours increase mode.
    press(2);
    expected = (hours === 2);
    if (!expected) `perr(("hours should be 2."));

    @(negedge clk);    // increase at falling edge
    expected = (mode2 === M2_TIME_HOUR);
    if (!expected) `perr(("Should go to hours set mode."));
    $display("Time at hours set mode testing is %0t", $time);
    for (i_hour = 3 ; i_hour <= 47 ; i_hour = i_hour+1) begin
        if (i_hour > 23)
            ii_hour = i_hour - 24;
        else
            ii_hour = i_hour;

        press(0);         // set button
        # clock_period;   // due to 1 clock delay of increase

        expected = (ii_hour === hours);
        if (!expected) `perr(("hours must be increased to %0d, signal = %0d",
                              ii_hour, hours));
        expected = (mins === 0 && secs === 0);
        if (!expected) `perr(("mins & secs should not be affected."));
    end

    // Now, 23:00:00
    hour_expected = 23;
    expected = (hours === hour_expected);
    if (!expected) `perr(("hours should be 00100."));
    $display("END of hours set mode testing");

    // Test mins increase mode
    @(negedge clk);    // switch synched at falling edge
    press(2);
    if (!(mode2 == M2_TIME_MIN)) `perr(("Should be in mins_INC mode."));
    $display("Time at mins set mode testing is %0t", $time);
    expected = (hours === hour_expected);
    if (!expected) `perr(("hours should be %0d.", hour_expected));

    @(negedge clk);    // increase at falling edge
    for (i_min = 1 ; i_min <= 80 ; i_min = i_min+1) begin
        if (i_min > 59)
            ii_min = i_min - 60;
        else
            ii_min = i_min;

        press(0);
        # clock_period;   // due to 1 clock delay of increase

        expected = (ii_min === mins);
        if (!expected) `perr(("mins must be increased to %0d, signal = %0d",
                              ii_min, mins));
        expected = (hours === hour_expected);
        if (!expected) `perr(("hours should be fixed to %0d, signal = %0d",
                              hour_expected, hours));
    end
    $display("END of mins set mode testing");

    // Now, 23:20:00
    hour_expected = 23;
    expected = (hours === hour_expected);
    if (!expected) `perr(("hours should be 00100 at the end of mins set."));
    min_expected = 20;
    expected = (mins === min_expected);
    if (!expected) `perr(("mins should be 010100 at the end of mins set."));
    $display("END of mins set mode testing");

    // Test secs increase mode
    press(2);    // switch synched at falling edge
    expected = (mode2 === M2_TIME_SEC);
    if (!expected) `perr(("Should be in secs_INC mode."));

    $display("Time at secs set mode testing is ");
    expected = (hours === hour_expected);
    if (!expected) `perr(("hours should be 4 at the beginning of secs_INC."));
    expected = (mins === min_expected);
    if (!expected) `perr(("mins should be 20 at the beginning of secs_INC."));

    @(negedge clk);    // increase at falling edge
    for (i_sec = 1 ; i_sec <= 80 ; i_sec = i_sec+1) begin
        if (i_sec > 59)
            ii_sec = i_sec - 60;
        else
            ii_sec = i_sec;

        press(0);
        # clock_period;   // due to 1 clock delay of increase

        expected = (ii_sec === secs);
        if (!expected) `perr(("secs must be increased to %0d, signal = %0d",
                              ii_sec, secs));
        expected = (mins === min_expected);
        if (!expected) `perr(("mins should be fixed to %0d, signal = %0d",
                              min_expected, mins));
        expected = (hours === hour_expected);
        if (!expected) `perr(("hours should be fixed to %0d, signal = %0d",
                              hour_expected, hours));
    end
    $display("END of secs set mode testing");

    // Get back to general mode.
    press(2);
    if (!(mode2 == M2_TIME_G)) `perr(("Should be TIME_G mode."));


    /*-------------------------------
     *  [2] DATE testing.
     *-------------------------------*/

    // Go to DATE mode.
    press(1);    // switch synched at falling edge

    // Check initial state - hour_carry has generated, so January 2nd.
    expected = (mon === 1);
    if (!expected) `perr(("Init value of mon should be 1."));
    // note that hour_carry had generated for the following expected value.
    expected = (day === 2);
    if (!expected) `perr(("Init value day should be 2."));

    // Test mon increase mode.
    press(2);

    $display("Time at mon set mode testing is %0t", $time);
    @(negedge clk);    // increase at falling edge
    for (i_mon = 2 ; i_mon <= 13 ; i_mon = i_mon+1) begin
        ii_mon = (i_mon - 1) % 12 + 1;   // change to range of 1~12

        press(0);
        # clock_period;    // due to 1 clock delay of increase

        expected = (ii_mon === mon);
        if (!expected) `perr(("mon must be increased to %0d", ii_mon));
        expected = (day === 2);
        if (!expected) `perr(("day should not be affected."));
    end

    // Now, January 2nd
    expected = (mon === 1);
    if (!expected) `perr(("mon should be 1."));
    expected = (day === 2);
    if (!expected) `perr(("day should be 2."));
    $display("END of mon set mode testing");

    // Test day increase mode.
    num_errors = 0;
    be_quiet = 0;     // false
    day_begin = 3;
    for (i_mon = 1 ; i_mon <= 12 ; i_mon = i_mon+1) begin
        press(2);
        $display("Testing day set mode at month %0d", i_mon);

        @(negedge clk);   // increase at falling edge
        max_day = max_days_of_month(i_mon);
        mon_expected = i_mon;
        day_end = max_day + day_begin - 1;
        if (i_mon == 12)
            day_end = day_end + 29;
        ii_day = day_begin - 1;

        for (i_day = day_begin ; i_day <= day_end ; i_day = i_day+1) begin
            ii_day = ii_day + 1;
            if (ii_day > max_day) begin
                ii_day = ii_day - max_day;
            end

            press(0);
            # clock_period;    // due to 1 clock delay of increase

            expec = (ii_day === day);
            expec2 = (mon === mon_expected);
            if (!be_quiet) begin
                if (!expec) `perr(("day must be increased to %0d, signal = %0d",
                                   ii_day, day));
                if (!expec2) `perr(("mon should be fixed to %0d, signal = %0d",
                                    mon_expected, mon));
            end
            if (!expec | !expec2) begin
                num_errors = num_errors + 1;
                if (num_errors >= MAX_ERRORS)
                    be_quiet = 1;
            end
        end

        // day set -> GENERAL -> month set
        press(2);
        press(2);

        if (!(mode2 == M2_DATE_MON)) `perr(("Should be mon set mode."));
        // to next month
        if (i_mon != 12) begin
            press(0);
            # clock_period;   // due to 1 clock delay of increase
        end
    end
    expected = (!be_quiet);
    if (!expected) `perr(("Mismatch:: %0d DATE output mismatches are found.",
                          num_errors));

    // Now in mon set mode, go to TIME general mode.
    press(1);
    expected = (mode1 === M1_TIMER && mode2 === M2_TIMER_G);
    if (!expected) `perr(("Should be TIMER general mode."));
    press(1);
    expected = (mode1 === M1_ALARM && mode2 === M2_ALARM_G);
    if (!expected) `perr(("Should be ALARM general mode."));
    press(1);
    expected = (mode1 === M1_TIME && mode2 === M2_TIME_G);
    if (!expected) `perr(("Should be in TIME general mode."));

    expected = (mon === 12 && day === 31);
    if (!expected) `perr(("Should be December 31st."));

    // Now, wait until 23:59:59 so that DATE increases at at the time.
    $write("Now, it's %0d:%0d:%0d on December 31. ", hours, mins, secs);
    $display("We'll see date becomes January 1st after time passes by.");
    wait_time_until(23, 59, 59, hours, mins, secs);
    # time_per_sec;
    # time_per_sec;  // for safeguard
    # time_per_sec;  // for safeguard
    if (mon == 1 && day == 1) begin
        $display("Yes, now it's January 1st.");
    end else begin
        `perr(("Should be January 1st after December 31, signal = %0d/$0d",
               mon, day));
    end


    /*----------------------------------------------------
     *  [3] TIMER Test.
     *----------------------------------------------------*/
    @(negedge clk);   // falling edge
    // Assume that we're in TIME general mode.
    expected = (mode1 === M1_TIME && mode2 === M2_TIME_G);
    if (!expected) `perr(("Should be in TIME general mode."));

    // At TIME mode, goto DATE mode.
    press(1);
    // At DATE mode, goto TIMER
    press(1);
    expected = (mode1 === M1_TIMER && mode2 === M2_TIMER_G);
    if (!expected) `perr(("Should be in TIMER general mode."));

    // Go to TIMER start.
    press(2);
    expected = (mode1 === M1_TIMER && mode2 === M2_TIMER_START);
    if (!expected) `perr(("Should be in TIMER START mode."));
    $display("Time at TIMER starts : %0t", $time);

    // Wait for the 1st event.
    @(min_sw or sec_sw or secc_sw);
    expected = (min_sw === 0 && sec_sw === 0 && secc_sw === 1);
    if (!expected) `perr(("%s:%0d:%0d:%0d, expected=0:0:1.",
                          "The 1st count of timer is wrong: timer_values=",
                          min_sw, sec_sw, secc_sw));

    o_min = 0;
    o_sec = 0;
    o_secc = 1;
    num_errors = 0;
    be_quiet = 0;      // false
    # minimum_period;  // guard to make sure that this testbench works
    for (count = 2 ; count <= 10000 ; count = count+1) begin
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

    // TIMER stops
    press(2);
    expected = (mode1 === M1_TIMER && mode2 === M2_TIMER_STOP);
    if (!expected) `perr(("Should be in TIMER STOP mode."));

    @(posedge clk);   // simulation synched at rising edge

    $display("We'll see whether timer values hold for 1000 clocks.");
    // check whether timer values hold after a few clocks
    # (1000*clock_period);
    i_min = min_sw;
    i_sec = sec_sw;
    i_secc = secc_sw;
    expected = (i_min === o_min && i_sec === o_sec && i_secc === o_secc);
    if (!expected) `perr(("TIMER value should hold after STOP."));

    // Reset timer.
    $display("Reset timer and see whether timer values become 0.");
    press(2);
    # clock_period;    // need because it is synchronous reset.

    expected = (mode1 === M1_TIMER && mode2 === M2_TIMER_G);    // check modes
    if (!expected) `perr(("It should be TIMER general mode."));
    if (!expected) $display("   mode1 = %2b, mode2 = %2b.", mode1, mode2);
    expected = (min_sw === 0 && sec_sw === 0 && secc_sw === 0);  // check reset
    if (!expected) `perr(("TIMER value should be reset at GENERAL mode."));
    if (!expected) $display("   TIMER signal = %0d:%0d:%0d",
                            min_sw, sec_sw, secc_sw);
    # clock_period;

    disable CLOCK_GENERATOR;
    $display("SIMULATION TERMINATED at %0t", $time);
    $stop(2);
end
endmodule

/*--- BLOCK12_test ---*/
