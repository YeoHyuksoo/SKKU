/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : dclockshare.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write her/his student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 04, 2018  (version 1.0)
 *  Version    : 1.1
 *  Design     : Definitions shared by all design files and testbench files.
 *
 *  Modification History:
 *      * version 1.1, Oct 30, 2019  by Hyoung Bok Min
 *        - Macro "perr()" is newly introduced.
 *          This macro can be used instead of system task $error().
 *        - parameter STOP_ERRORS and integer err_count are used for the macros.
 *      * version 1.0, July 04, 2018  by Hyoung Bok Min
 *        version 1.0 released.
 *
 * Note:
 *     * This file is intended to be included by almost all design files
 *       and testbench files.
 *
 *-------------------------------------------------------------------------*/

/**
 *  MODE_BITS is the number of bits to encode major (or minor) modes
 *  of digital clock.
 */
localparam MODE_BITS = 2;
localparam NUM_MODES = 2**MODE_BITS;

/**
 *  Definition of mode1 values: 4 major modes.
 */
localparam [MODE_BITS-1:0] M1_TIME  = 2'b00,
                           M1_DATE  = 2'b01,
                           M1_TIMER = 2'b10,
                           M1_ALARM = 2'b11;

/**
 *  Definition of mode2 values: 4 minor modes depending on the major modes.
 */
// When mode1 is M1_TIME,
localparam [MODE_BITS-1:0] M2_TIME_G     = 2'b00,
                           M2_TIME_HOUR  = 2'b01,
                           M2_TIME_MIN   = 2'b11,
                           M2_TIME_SEC   = 2'b10;
// When mode1 is M1_DATE,
localparam [MODE_BITS-1:0] M2_DATE_G     = 2'b00,
                           M2_DATE_MON   = 2'b01,
                           M2_DATE_DAY   = 2'b10;
// When mode1 is M1_TIMER,
localparam [MODE_BITS-1:0] M2_TIMER_G    = 2'b00,
                           M2_TIMER_START= 2'b01,
                           M2_TIMER_STOP = 2'b10;
// When mode1 is M1_ALARM,
localparam [MODE_BITS-1:0] M2_ALARM_G    = 2'b00,
                           M2_ALARM_HOUR = 2'b01,
                           M2_ALARM_MIN  = 2'b10;

// RTL_SYNTHESIS OFF
// pragma synthesis_off
// synthesis translate_off
// pragma translate_off
// synopsys translate_off

/*---------------------------
 * Notes:
 *
 * (1) The above comments are used for synthesis programs to turn off
 *     reading codes located below. Most synthesis programs support
 *     one or more of the 5 lines.
 *
 * (2) The following task is for testbenches only. This task is NOT
 *     synthesizable, and you cannot use this task at your design files.
 *---------------------------*/

//-----------
// Check validity of mode constants (localparam's) in this program file.
//-----------
task check_mode_consts;
    reg [MODE_BITS-1:0] UNDEFINED;
    reg [NUM_MODES-1:0] mode1_exists, mode2_exists;
    reg [MODE_BITS-1:0] mode1_values [NUM_MODES-1:0];
    reg [MODE_BITS-1:0] mode2_values [NUM_MODES-1:0];
    reg [8*8-1:0] mode1_name;
    integer i, k;
begin
    UNDEFINED = 2'bxx;
    i = 0;
    mode1_values[i] = M1_TIME;   i = i + 1;
    mode1_values[i] = M1_DATE;   i = i + 1;
    mode1_values[i] = M1_TIMER;  i = i + 1;
    mode1_values[i] = M1_ALARM;  i = i + 1;
    if (i != NUM_MODES)
        $fatal(1, "Number of modes at MODE1 does not match: %0s=%0d, %0s=%0d",
               "expected", NUM_MODES, "defined", i);
    mode1_exists = 0;
    for (i = 0 ; i < NUM_MODES ; i = i + 1) begin
        k = 0;
        case (i)
            0 : begin
                mode1_name = "TIME";
                mode2_values[k] = M2_TIME_G;      k = k + 1;
                mode2_values[k] = M2_TIME_HOUR;   k = k + 1;
                mode2_values[k] = M2_TIME_MIN;    k = k + 1;
                mode2_values[k] = M2_TIME_SEC;    k = k + 1;
            end 
            1 : begin
                mode1_name = "DATE";
                mode2_values[k] = M2_DATE_G;     k = k + 1;
                mode2_values[k] = M2_DATE_MON;   k = k + 1;
                mode2_values[k] = M2_DATE_DAY;   k = k + 1;
                mode2_values[k] = UNDEFINED;     k = k + 1;
            end
            2 : begin
                mode1_name = "TIMER";
                mode2_values[k] = M2_TIMER_G;       k = k + 1;
                mode2_values[k] = M2_TIMER_START;   k = k + 1;
                mode2_values[k] = M2_TIMER_STOP;    k = k + 1;
                mode2_values[k] = UNDEFINED;        k = k + 1;
            end
            3 : begin
                mode1_name = "ALARM";
                mode2_values[k] = M2_ALARM_G;      k = k + 1;
                mode2_values[k] = M2_ALARM_HOUR;   k = k + 1;
                mode2_values[k] = M2_ALARM_MIN;    k = k + 1;
                mode2_values[k] = UNDEFINED;       k = k + 1;
            end
        endcase
        if (k != NUM_MODES)
            $fatal(1, "Number of modes at MODE2 %0s: %0s=%0d, %0s=%0d",
                   "does not match", "expected", NUM_MODES, "defined", k);

        if (mode1_exists[mode1_values[i]])
            $fatal(1, "Duplicate definitions of constants at MODE1. %s%0s%s",
                   "Check for definition of M1_", mode1_name, ".");
        mode1_exists[mode1_values[i]] = 1'b1;

        mode2_exists = 0;
        for (k = 0 ; k < NUM_MODES ; k = k + 1) begin
            if (mode2_values[k] !== UNDEFINED) begin
                if (mode2_exists[mode2_values[k]])
                    $fatal(1, "Duplicate definitions of M2_%0s... constants.",
                           mode1_name);
                mode2_exists[mode2_values[k]] = 1'b1;
            end
        end
    end
end
endtask

//-----------
// Macros and variables for error messages.
// These macros are used only in testbenches.
//-----------
parameter STOP_ERRORS = 100;    // maximum allowable number of error messages
integer err_count = 0;

// Verilog and SystemVerilog do not support variadic macros, hence
// we emulate variadic macros by using $sformatf().
// The last "#0" is used to allow semi-colon at the end of these macros.
`define perr(format)                                   \
        repeat(1) begin                                \
            $error("%s", $sformatf format);            \
            err_count = err_count + 1;                 \
            if (err_count >= STOP_ERRORS) begin        \
                $write("Simulation stops because error count "); \
                $display("exceeds limit (%0d).", STOP_ERRORS);   \
                $stop;                                 \
            end                                        \
        end   #0

// synopsys translate_on
// pragma translate_on
// synthesis translate_on
// pragma synthesis_on
// RTL_SYNTHESIS ON

// end of dclockshare.v
