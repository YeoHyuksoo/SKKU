/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : mode_gen_tb.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write her/his student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : Jul. 10, 2018  (version 1.0)
 *  Version    : 1.2
 *  Design     : Homework #2
 *               Testbench for MODE_GEN (mode_gen.v)
 *
 *  Modification History:
 *      * v1.2, Oct 30, 2019  by Hyoung Bok Min
 *        - macro perr()'s in dclockshare.v are used instead of $error()'s.
 *      * v1.1, Nov 12, 2018  by Hyoung Bok Min
 *        - States should hold when both sw1 and sw2 are pressed. This feature
 *          has not been tested, and is newly tested in v1.1.
 *        - task test_both_buttons() is newly added for this feature.
 *      * v1.0, July 10, 2018  by Hyoung Bok Min
 *        - version 1.0 released.
 *
 *  NOTE: This testbench assumes the followings.
 *
 *  (1) Any switch (sw1, sw2, and set) is '1' at only one single rising
 *      edge of system clock when users press the switch.
 *  (2) The switches are ON when their logic values are '1' (active high).
 *  (3) 'mode1' and 'mode2' will be changed at rising edge of clock.
 *  (4) 'increase' would be generated for about one clock period so that it can
 *      be detected at rising edge of clock, and change its logic state
 *      on or around falling edges of the clock.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/**
 *  MODULE: MODE_GEN_test
 *
 *  Testbench to test module MODE_GEN in mode_gen.v
 */

module MODE_GEN_test;

/*-------------------------------------------------------------------
 *  Time constants
 *
 *  WARNING: Please do not assume that clock period is a specific value.
 *           These time constants may be changed when grading, and
 *           may be any value from 10 ps to 100 ms.
 *           CLOCK_PS should be a multiple of 10, and we assume that
 *           time resolution at `timescale is 1ps.
 *
 *  CLOCK_PS : This is simulation clock period in pico seconds.
 *           You can change simulation clock frequency by using this one.
 *           This natural number should be a multiple of 10.
 *-------------------------------------------------------------------*/
parameter  CLOCK_PS          = 10000;      //  should be a multiple of 10
localparam clock_period      = CLOCK_PS/1000.0;
localparam half_clock_period = clock_period / 2;
localparam minimum_period    = clock_period / 10;
localparam point3_period     = clock_period * 3 / 10;          //  30%
localparam point7_period     = clock_period - point3_period;   //  70%

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
parameter RESET_PERIOD = 1;   // should be non-negative

// Definitions of logic values at mode1/mode2 ports.
`include "dclockshare.v"

// Signals on which logic values will be assigned.
// These signals are connected to input ports of MODE_GEN.
reg clk, sw1, sw2, set, reset_n;

// Signals which will be observed.
// These signals are connected to output ports of MODE_GEN.
wire [1:0] mode1, mode2;
wire increase;

// Counter to count clocks when 'increase' is 1.
reg clr_count_n = 1;       // asynchronous reset input to counter, active-low 
reg [7:0] inc_count = 0;   // counter output

// Variables for error messages.
reg expected;              // expected condition (assertion)
reg [256*8:1] str_m;       // string for current mode of digital clock
reg mode1_is_okay, mode2_is_okay;
reg [48*8:1] errmsg1, errmsg2;

// Variables to receive outputs from task 'wait_increase'.
reg inc_count_error, inc_timeout_error;


/**
 *  Reset the counter.
 *  The counter is used to count clocks when 'increase' is 1.
 */
task reset_counter;
begin
    clr_count_n = 1'b0;    // activte reset, active-low
    # half_clock_period;
    clr_count_n = 1'b1;    // back to normal state
    # half_clock_period;
end
endtask

/**
 *  Wait for 'increase' signal to be 1'b0.
 *  The wait expires after clock periods of 'timeout_cycles'.
 *
 *  Two error indicators may be flagged as outputs of this task:
 *      count_error:   1 if 'increase' signal becomes 1'b0 as expected,
 *                          but it lasts for more than 1 clock.
 *      timeout_error: 1 if 'increase' signal lasts for more than
 *                          'timeout_cycles' clock periods.
 */
task wait_increase (
    input integer timeout_cycles,       // timeout after this clock cycles
    output count_error, timeout_error   // error flags
);
begin
    count_error = 1'b0;
    timeout_error = 1'b0;
    fork
        // wait for 'increase' to be 1'b0.
        begin : WAIT_INCREASE
            wait(increase === 1'b0);
            if (!(inc_count === 1))
                count_error = 1'b1;    // set error flag
            disable TIMEOUT_INCREASE;
        end
        // timeout after 'timeout_cycles' clock periods.
        begin : TIMEOUT_INCREASE
            # (timeout_cycles*clock_period);
            if (increase !== 1'b0) begin
                timeout_error = 1'b1;  // set error flag
                disable WAIT_INCREASE;
            end
        end
    join
    reset_counter;
end
endtask

/**
 *  Press one of the 3 buttons; sw1, sw2, or set.
 *  The button is '1' at only one rising edge of the clock.
 *  Please refer to the documentation on parameter 'SWITCH_FORM' which is
 *  described at above section of this file.
 *
 *  Note: The 1st "@ (posedge clk)" is written to make sure that
 *         button press begins at next clock cycle.
 */
task press (
    input [1:0] switch      // 1 for sw1, 2 for sw2, 0 for set
);
begin
    // delay before button press
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

/**
 *  Note that FSM at MODE_GEN should hold its state when both sw1 and sw2
 *  are pressed simutaneously.
 *  Press buttons, both sw1 and sw2, and see if values of 'mode1' and 'mode2'
 *  holds without change before and after pressing the buttons.
 * 
 *  Outputs:
 *    mode1_is_okay is true if mode1 value holds,
 *                     false if mode2 value change.
 *    mode2_is_okay is true if mode1 value holds,
 *                     false if mode2 value change.
 */
task test_both_buttons (
    output reg mode1_is_okay, mode2_is_okay
);
reg [1:0] save_mode1, save_mode2;
begin
    // Save old values of mode1 and mode2 before clock tick.
    save_mode1 = mode1;
    save_mode2 = mode2;

    // press 2 buttons for a clock period
    @ (posedge clk);
    @ (negedge clk);
    sw1 = 1'b1;
    sw2 = 1'b1;
    # clock_period;
    sw1 = 1'b0;
    sw2 = 1'b0;

    // compare new value after clock tick with the values before clock tick.
    if (mode1 === save_mode1)
        mode1_is_okay = 1'b1;   // true
    else
        mode1_is_okay = 1'b0;
    if (mode2 === save_mode2)
        mode2_is_okay = 1'b1;   // true
    else
        mode2_is_okay = 1'b0;
end
endtask

/**
 *  Instantiation of the design:
 *  This statement connects signals of testbench to ports of the design.
 */
MODE_GEN U1 (
    .clk(clk),           // input: system clock and time base
    .sw1(sw1),           // input: cycle thru TIME/DATE/TIMER/ALARM
    .sw2(sw2),           // input: minor mode depending on the above
    .set(set),           // input: switch to increase values of time, date, etc
    .reset_n(reset_n),   // input: master reset, active low
    .mode1(mode1),       // output: the mode chosen by sw1
    .mode2(mode2),       // output: the mode chosen by sw2
    .increase(increase)  // output: 1 if increase by set switch is needed
);

/**
 *  Clock signal generation.
 *  Clock is assumed to be initialized to 1'b0 at time 0.
 */
initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # half_clock_period clk = ~clk;
end

/**
 *  This counter is used to count the number of clk's when 'increase' is 1,
 *  in other words, we measure how long 'increase' is 1.
 */
always @ (posedge clk or negedge clr_count_n)
begin : INCREASE_COUNTER
    if (clr_count_n === 1'b0) begin
        inc_count <= 0;
    end else begin
         if (increase === 1'b1) begin
             inc_count <= inc_count + 1;
         end
    end
end

/**
 *  Record last event time of 'increase' to variable 'increase_stable_since'
 *  by using the always block shown below.
 *  Note that 'increase' is stable during the time period 'last_event'
 *  which is "$time - increase_stable_since".
 * 
 *                                            $time (current simulation time)
 *                                              |
 *                                              V
 *  increase:                  +-------------------------
 *           ------------------+
 *                                 last_event
 *                             |<-------------->|
 *                       increase_stable_since
 *                       (the last time when event occurs at 'increase')
 */
time one_clock_period = clock_period;
time last_event;      // how long 'increase' is stable w.r.t current sim. time
time increase_stable_since = 0;

always @ (increase)
begin : STABLE_INCREASE
    increase_stable_since = $time;
end

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif

/**
 *  Now, a main test program follows.
 */
initial
begin : TEST_PROGRAM
    // parameters for $timeformat() is:
    //    1st: unit (-9 means ns),
    //    2nd: digits after dot at $time,
    //    3rd: string appended after $time value,
    //    4th: minimum string length
    $timeformat(-9, 0, " ns", 5);

    // Students may think that the following 3 lines do not exist.
    `ifdef PCODE2
    `include "pcode2.v"
    `endif

    // Check validity of mode constants (localparam's) defined in the file
    // "dclockshare.v". The mode constants are shared by almost all the design
    // files of digital clock which we design.
    // We use definitions at the localparams in the file for this testbench,
    // and the following task is also in the file "dclockshare.v".
    check_mode_consts;

    // Initial values of switches are reset to 1'b0.
    sw1 = 1'b0;
    sw2 = 1'b0;
    set = 1'b0;
    reset_n = 1'b1;   // normal state of active low signal.

    /*--------------------------------------------------------
     * Test Asynchronous reset (reset_n).
     *--------------------------------------------------------
     * Reset MODE_GEN to avoid initial values (x or z) at flipflop outputs.
     */
    $display("Time at the 1st reset test is %0t", $time);
    # minimum_period;
    reset_n = 1'b0;   // activate reset of active low.
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
    reset_n = 1'b1;   // release the reset to normal state.
    # minimum_period;

    // Initial state should be TIME_G (TIME general) mode, and
    // 'increase' signal should be low.
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));
    if (!(increase === 1'b0))
        `perr(("increase should be 0. increase=%b", increase));
    if ((mode1 === M1_TIME) && (mode2 === M2_TIME_G) && (increase === 1'b0))
        $display("We confirm that reset_n works at time %0t", $time);

    // Synchronize to clock.
    // Simulation begins at rising edge.
    // This is required to get timing for buttons.
    @ (posedge clk);

    // Go to the other state by pressing sw1 and sw2.
    // Any other states are also okay if the states are not initial state.
    press(1);   // press sw1
    press(2);   // press sw2

    // Reset MODE_GEN again by using reset_n.
    // We'll check whether this action drives MODE_GEN to initial state.
    $display("Time at the 2nd reset test is %0t", $time);
    # (2*minimum_period);
    reset_n = 1'b0;    // activate reset of active low.
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
    reset_n = 1'b1;    // release the reset
    # minimum_period;

    // Initial state should be TIME_G (TIME general) mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));
    if (!(increase === 1'b0))
        `perr(("increase should be 0. increase=%b", increase));
    if ((mode1 === M1_TIME) && (mode2 === M2_TIME_G) && (increase === 1'b0))
        $display("We confirm that reset_n works at time %0t", $time);

    // Synchronize to falling edge of the clock
    @ (negedge clk);


    /*--------------------------------------------------------
     *  [1] Test state transitions, cycle through four major modes
     *      Assume that we're now in TIME mode
     *--------------------------------------------------------*/
    errmsg1 = "mode1 should hold when both buttons are pressed.";
    errmsg2 = "mode2 should hold when both buttons are pressed.";

    $display("State transitions of 4 general states begins at %0t", $time);
    // go to DATE_G (DATE general) mode from TIME_G (TIME general) mode
    press(1);

    // Now, in DATE_G (DATE general) mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    press(1);

    // Now, in TIMER_G mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_G))
        `perr(("TIMER_G(%b) mode expected. mode2=%b", M2_TIMER_G, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    press(1);

    // Now, in ALARM_G mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_G))
        `perr(("ALARM_G(%b) mode expected. mode2=%b", M2_ALARM_G, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    press(1);

    // Now, back to TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));


    /*-------------------------------------------------------
     *  [2] State transition test, next two minor states of each major mode
     *  [2.1] Next three minor states of TIME mode
     *-------------------------------------------------------*/
    $display("State transitions of 4 TIME states begins at %0t", $time);
    // go to TIME_HOUR mode
    press(2);

    // Now, in TIME_HOUR mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_HOUR))
        `perr(("TIME_HOUR(%b) mode expected. mode2=%b", M2_TIME_HOUR, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to DATE_G mode
    press(1);

    // Now, in DATE_G mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));

    // go back to TIME_G mode
    press(1);
    press(1);
    press(1);

    // Now, in TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));

    // go to TIME_MIN mode
    press(2);
    press(2);

    // Now, in TIME_MIN mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_MIN))
        `perr(("TIME_MIN(%b) mode expected. mode2=%b", M2_TIME_MIN, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to DATE_G mode
    press(1);

    // Now, in DATE_G mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));

    // go back to TIME_G mode
    press(1);
    press(1);
    press(1);

    // Now, in TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));

    // go to TIME_SEC mode
    press(2);
    press(2);
    press(2);

    // Now, in TIME_SEC mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_SEC))
        `perr(("TIME_MIN(%b) mode expected. mode2=%b", M2_TIME_MIN, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to DATE_G mode
    press(1);

    // Now, in DATE_G mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));

    /*-------------------------------------------------------
     *  [2.2] Next two minor states of DATE mode
     *-------------------------------------------------------*/
    $display("State transitions of 3 DATE states begins at %0t", $time);
    // go to DATE_MON mode
    press(2);

    // Now, in DATE_MON mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_MON))
        `perr(("DATE_MON(%b) mode expected. mode2=%b", M2_DATE_MON, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to TIMER_G mode
    press(1);

    // Now, in TIMER_G mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_G))
        `perr(("TIMER_G(%b) mode expected. mode2=%b", M2_TIMER_G, mode2));

    // go back to DATE_G mode
    press(1);
    press(1);
    press(1);

    // Now, in DATE_G mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));

    // go to DATE_DAY mode
    press(2);
    press(2);

    // Now, in DATE_DAY mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_DAY))
        `perr(("DATE_DAY(%b) mode expected. mode2=%b", M2_DATE_DAY, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to TIMER_G mode
    press(1);

    // Now, in TIMER_G mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_G))
        `perr(("TIMER_G(%b) mode expected. mode2=%b", M2_TIMER_G, mode2));

    /*-------------------------------------------------------
     *  [2.3] Next two minor states of TIMER mode
     *-------------------------------------------------------*/
    $display("State transitions of 3 TIMER states begins at %0t", $time);
    // go to TIMER_START mode
    press(2);

    // Now, in TIMER_START mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_START))
        `perr(("TIMER_START(%b) expected. mode2=%b", M2_TIMER_START, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to ALARM_G mode
    press(1);

    // Now, in ALARM_G mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_G))
        `perr(("ALARM_G(%b) mode expected. mode2=%b", M2_ALARM_G, mode2));

    // go back to TIMER_G mode
    press(1);
    press(1);
    press(1);

    // Now, in TIMER_G mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_G))
        `perr(("TIMER_G(%b) mode expected. mode2=%b", M2_TIMER_G, mode2));

    // go to TIMER_STOP mode
    press(2);
    press(2);

    // Now, in TIMER_STOP mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_STOP))
        `perr(("TIMER_STOP(%b) mode expected. mode2=%b", M2_TIMER_STOP, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to ALARM_G mode
    press(1);

    // Now, in ALARM_G mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_G))
        `perr(("ALARM_G(%b) mode expected. mode2=%b", M2_ALARM_G, mode2));

    /*-------------------------------------------------------
     *  [2.4] Next two minor states of ALARM mode
     *-------------------------------------------------------*/
    $display("State transitions of 3 ALARM states begins at %0t", $time);
    // go to ALARM_HOUR mode
    press(2);

    // Now, in ALARM_HOUR mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_HOUR))
        `perr(("ALARM_HOUR(%b) mode expected. mode2=%b", M2_ALARM_HOUR, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to TIME_G mode
    press(1);

    // Now, in TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));

    // go back to ALARM_G mode
    press(1);
    press(1);
    press(1);

    // Now, in ALARM_G mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_G))
        `perr(("ALARM_G(%b) mode expected. mode2=%b", M2_ALARM_G, mode2));

    // go to ALARM_MIN mode
    press(2);
    press(2);

    // Now, in ALARM_MIN mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_MIN))
        `perr(("ALARM_MIN(%b) mode expected. mode2=%b", M2_ALARM_MIN, mode2));

    // State should hold when both sw1 and sw2 are pressed.
    test_both_buttons(mode1_is_okay, mode2_is_okay);
    if (!mode1_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg1, mode1, mode2));
    if (!mode2_is_okay)
        `perr(("%0s mode1=%b, mode2=%b", errmsg2, mode1, mode2));

    // go to TIME_G mode
    press(1);

    // Now, in TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));


    /*---------------------------------------------------------
     *  [3] Check increase signal
     *---------------------------------------------------------*/
    if (!(increase === 1'b0))
        `perr(("increase should be 0 before increase test. increase=%b",
              increase));

    /*-------------------------------------------------
     * [3.1] At TIME_HOUR, TIME_MIN, and TIME_SEC
     *-------------------------------------------------*/
    $display("Time of increase test at TIME mode is %0t", $time);
    reset_counter;
    @ (negedge clk);
    // go to TIME_HOUR mode
    press(2);
    str_m = "at TIME_HOUR mode.";

    // Now, in TIME_HOUR mode, increase should be 0
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_HOUR))
        `perr(("TIME_HOUR(%b) mode expected. mode2=%b", M2_TIME_HOUR, mode2));
    if (!(increase === 1'b0))
        `perr(("increase should be 0. increase=%b", increase));
    // increase should be stable for 2*clock_period
    last_event = $time - increase_stable_since;
    expected = (last_event >= 2*one_clock_period);
    if (!expected)
        `perr(("increase should be 0 during sw2 %0s stable=%0t,last_event=%0t",
              str_m, increase_stable_since, last_event));

    @ (negedge clk);
    set = 1'b1;    // press set button
    # point7_period;
    if (!(increase === 1'b0))
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    if (!(increase === 1'b1))
        `perr(("increase should be generated %0s, increase=%b",
              str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));

    // Now, go to TIME_MIN mode
    str_m = "at TIME_MIN mode.";
    press(2);
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should return to 0 %0s increase=%b", str_m, increase));
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_MIN))
        `perr(("TIME_MIN(%b) mode expected. mode2=%b", M2_TIME_MIN, mode2));

    // Now, in TIME_MIN mode
    # clock_period;
    set = 1'b1;    // press set button
    # point7_period;
    if (!(increase === 1'b0))
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    if (!(increase === 1'b1))
        `perr(("increase should be generated %0s increase=%b",
               str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));

    // Now, go to TIME_SEC mode
    str_m = "at TIME_SEC mode.";
    press(2);
    if (!(increase === 1'b0))
        `perr(("increase should return to 0 %0s increase=%b", str_m, increase));
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_SEC))
        `perr(("TIME_SEC(%b) mode expected. mode2=%b", M2_TIME_SEC, mode2));

    // Now, in TIME_SEC mode
    # clock_period;
    set = 1'b1;    // press set button
    # point7_period;
    if (!(increase === 1'b0))
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    expected = (increase === 1'b1);
    if (!expected)
        `perr(("increase should be generated %0s increase=%b",
               str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));
    reset_counter;

    // go back to TIME_G mode
    str_m = "at TIME_G mode.";
    press(2);
    if (!(increase === 1'b0))
        `perr(("increase should return to 0 %0s increase=%b", str_m, increase));

    // Now, in TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));

    // press set button, should not generate increase
    press(0);
    # clock_period;
    if (!(inc_count === 0))
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    /*-------------------------------------------------
     *  [3.2] At DATE_MON and DATE_DAY
     *-------------------------------------------------*/
    $display("Time of increase test at DATE mode is %0t", $time);
    reset_counter;
    @ (negedge clk);
    // go to DATE mode
    press(1);

    // Now, int DATE_G mode
    str_m = "at DATE_G mode.";
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));
    if (!(increase === 1'b0))
        `perr(("increase should be 0 %0s", str_m));
    // increase should be stable for 2*clock_period
    last_event = $time - increase_stable_since;
    expected = (last_event >= 2*one_clock_period);
    if (!expected)
        `perr(("increase should not be generated %0s stable=%0t,last_event=%0t",
              str_m, increase_stable_since, last_event));

    press(2);

    // Now, in DATE_MON mode
    str_m = "at DATE_MON mode.";
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_MON))
        `perr(("DATE_MON(%b) mode expected. mode2=%b", M2_DATE_MON, mode2));

    @ (negedge clk);
    set = 1'b1;    // press set button
    # point7_period;
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    expected = (increase === 1'b1);
    if (!expected)
        `perr(("increase should be generated %0s increase=%b",
               str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));

    // go to DATE_DAY mode
    press(2);

    // Now, in DATE_DAY mode
    str_m = "at DATE_DAY mode.";
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_DAY))
        `perr(("DATE_DAY(%b) mode expected. mode2=%b", M2_DATE_DAY, mode2));

    @(negedge clk);
    set = 1'b1;    // press set button
    # point7_period;
    if (!(increase === 1'b0))
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    expected = (increase === 1'b1);
    if (!expected)
        `perr(("increase should be generated %0s increase=%b",
               str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));
    reset_counter;

    // go back to DATE_G mode
    press(2);

    // Now, in DATE_G mode
    if (!(mode1 === M1_DATE))
        `perr(("DATE(%b) mode expected. mode1=%b", M1_DATE, mode1));
    if (!(mode2 === M2_DATE_G))
        `perr(("DATE_G(%b) mode expected. mode2=%b", M2_DATE_G, mode2));

    // press set button, should not generate increase
    press(0);
    # clock_period;
    if (!(inc_count === 0))
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    /*-------------------------------------------------
     *  [3.3] At TIMER_START and TIMER_STOP
     *-------------------------------------------------*/
    $display("Time of increase test at TIMER mode is %0t", $time);
    reset_counter;
    @ (negedge clk);
    // go to TIMER_G mode
    press(1);

    // Now, in TIMGER_G mode, go TIMER_START->TIMER_STOP->TIMER_G
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_G))
        `perr(("TIMER_G(%b) mode expected. mode2=%b", M2_TIMER_G, mode2));

    // go to TIMER_START mode
    press(2);

    // Now, in TIMER_START mode
    str_m = "at TIMER mode.";
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_START))
        `perr(("TIMER_START(%b) expected. mode2=%b", M2_TIMER_START, mode2));

    // press set button - should not generate increase
    press(0);
    # clock_period;
    if (!(inc_count === 0))
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    // check for 10 clocks : should not generate increase
    repeat (10) begin
        # clock_period;
    end
    // increase should be stable for 12*clock_period
    last_event = $time - increase_stable_since;
    expected = (last_event >= 12*one_clock_period);
    if (!expected)
        `perr(("increase should be 0 and stable %0s stable=%0t,last_event=%0t",
              str_m, increase_stable_since, last_event));

    // go to TIMER_STOP mode
    press(2);

    // Now, in TIMER_STOP mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_STOP))
        `perr(("TIMER_STOP(%b) mode expected. mode2=%b", M2_TIMER_STOP, mode2));

    // press set button - should not generate increase
    press(0);
    # clock_period;
    if (!(inc_count === 0))
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    // go back to TIMTER_G mode
    press(2);

    // Now, in TIMER_G mode
    if (!(mode1 === M1_TIMER))
        `perr(("TIMER(%b) mode expected. mode1=%b", M1_TIMER, mode1));
    if (!(mode2 === M2_TIMER_G))
        `perr(("TIMER_G(%b) mode expected. mode2=%b", M2_TIMER_G, mode2));

    // press set button, should not generate increase
    press(0);
    # clock_period;
    if (!(inc_count === 0))
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    // increase should be stable for 8*clock_period
    last_event = $time - increase_stable_since;
    expected = (last_event >= 8*one_clock_period);
    if (!expected)
        `perr(("increase should be 0 and stable %0s stable=%0t,last_event=%0t",
              str_m, increase_stable_since, last_event));
    expected = (inc_count === 0);
    if (!expected)
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    /*-------------------------------------------------
     *  [3.4] At ALARM_HOUR and ALARM_MIN
     *-------------------------------------------------*/
    $display("Time of increase test at ALARM mode is %0t", $time);
    reset_counter;
    @ (negedge clk);
    // go to ALARM_G mode
    press(1);

    str_m = "at ALARM_G mode.";
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_G))
        `perr(("ALARM_G(%b) mode expected. mode2=%b", M2_ALARM_G, mode2));
    if (!(increase === 1'b0))
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    // increase should be stable for 2*clock_period
    last_event = $time - increase_stable_since;
    expected = (last_event >= 2*one_clock_period);
    if (!expected)
        `perr(("increase should be 0 during sw2 %0s stable=%0t,last_event=%0t",
              str_m, increase_stable_since, last_event));

    // Now, in ALARM_G mode, cycle ALARM_HOUR->ALARM_MIN->ALARM_G
    press(2);

    // Now, in ALARM_HOUR mode
    str_m = "at ALARM_HOUR mode.";
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_HOUR))
        `perr(("ALARM_HOUR(%b) mode expected. mode2=%b", M2_ALARM_HOUR, mode2));
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should be 0 before set %0s increase=%b",
              str_m, increase));

    @ (negedge clk);
    set = 1'b1;    // press set button
    # point7_period;
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    expected = (increase === 1'b1);
    if (!expected)
        `perr(("increase should be generated %0s increase=%b",
               str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));

    // go to ALARM_MIN mode
    str_m = "at ALARM_MIN mode.";
    press(2);
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should be 0 before set %0s increase=%b",
              str_m, increase));

    // Now, in ALARM_MIN mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_MIN))
        `perr(("ALARM_MIN(%b) mode expected. mode2=%b", M2_ALARM_MIN, mode2));

    # clock_period;
    set = 1'b1;    // press set button
    # point7_period;
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should be 0 %0s increase=%b", str_m, increase));
    # point3_period;
    set = 1'b0;    // release set button
    # point3_period;
    expected = (increase === 1'b1);
    if (!expected)
        `perr(("increase should be generated %0s increase=%b",
               str_m, increase));

    // wait until increase becomes 1'b0
    wait_increase(3, inc_count_error, inc_timeout_error);
    if (inc_count_error)
        `perr(("increase should last for a clock period %0s inc_count=$0d",
              str_m, inc_count));
    if (inc_timeout_error)
        `perr(("increase is too long %0s", str_m));
    reset_counter;

    // go back to ALARM_G mode
    str_m = "at ALARM_G mode.";
    press(2);
    expected = (increase === 1'b0);
    if (!expected)
        `perr(("increase should return to 0 %0s increase=%b", str_m, increase));

    // Now, in ALARM_G mode
    if (!(mode1 === M1_ALARM))
        `perr(("ALARM(%b) mode expected. mode1=%b", M1_ALARM, mode1));
    if (!(mode2 === M2_ALARM_G))
        `perr(("ALARM_G(%b) mode expected. mode2=%b", M2_ALARM_G, mode2));

    // press set button, should not generate increase
    press(0);
    # clock_period;
    if (!(inc_count === 0))
        `perr(("increase should not be generated %0s inc_count=%0d",
              str_m, inc_count));

    // go back to TIME_G mode
    press(1);
    # (2*clock_period);

    // Now, in TIME_G mode
    if (!(mode1 === M1_TIME))
        `perr(("TIME(%b) mode expected. mode1=%b", M1_TIME, mode1));
    if (!(mode2 === M2_TIME_G))
        `perr(("TIME_G(%b) mode expected. mode2=%b", M2_TIME_G, mode2));
    # clock_period;

    disable CLOCK_GENERATOR;
    $display("SIMULATION TERMINATED at %0t", $time);
    $stop(2);
end
endmodule

// MODE_GEN_test
