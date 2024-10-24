/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2018-2020 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : time.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write his/her student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : Nov. 12, 2020
 *  Version    : 1.1
 *  Design     : Homework #3
 *               TIME Generator of Digital Clock.
 *
 *  Modification History:
 *      * version 1.1, Nov. 12, 2020  by Hyoung Bok Min
 *        - Change types of output ports from reg's to wire's.
 *      * version 1.0, July 10, 2018  by Hyoung Bok Min
 *        - version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*----------------------
 * MODULE : TIME
 *
 * Description:
 *   TIME generates current time of day at hours, mins, secs, whose meanings
 *   are self-explanatory by counting system clocks.
 *   TIME also generates a carry signal (hour_carry) when time changes from
 *   23:59:59 to 00:00:00 to indicate a day has been passed.
 *   Of course, there is a feature to adjust the HOUR, MIN, and SEC
 *   at TIME_HOUR, TIME_MIN, and TIME_SEC modes given by MODE_GEN.
 *
 * Implementation:
 *   TIME is a collection of counters. TIME counts system clocks to make
 *   a second. TIME also counts 60 seconds, 60 minutes, and 24 hours to make
 *   a minute, an hour, and hour_carry, respectively.
 *   Initial states of the time counters are 00:00:00.
 *
 * Notes:
 *   (1) Initial state of 00:00:00 is guaranteed by an active low asynchronous
 *       reset input.
 *   (2) The number of counted system clocks to make a second is paramerized.
 *       Please see a Note on CLOCKS4SEC and MAX_COUNT below for details.
 *--------------------*/

module TIME (
    input clk,           // system clock
    input increase,      // 1 if time should be set by button presses
    input reset_n,       // asynchronous reset, active low
    input [1:0] mode1,   // major mode from mode generator module
    input [1:0] mode2,   // minor mode from mode generator module

    output [4:0] hours,  // hours of this time of today
    output [5:0] mins,   // minutes of this time of today
    output [5:0] secs,   // seconds of this time of today
    output hour_carry    // 1 if date should be changed at 23:59:59
);

/**
 *  Given a positive integer,
 *  Returns the number of bits which fits the integer as unsigned.
 *  In other words, returns ceiling(log2(N+1)).
 *
 *  Note: This is equivalent to system function $clog2(), which was added at
 *        Verilog-2005 (IEEE Std. 1364-2005). If your simulator and synthesis
 *        supports $clog2(), you may use the system function.
 */
function integer bits_required (
    input integer val
);
integer result, remainder;
begin
    result = 0;
    remainder = val;
    while (remainder > 0) begin   // Iteration for each bit
        result = result + 1;
        remainder = remainder / 2;
    end
    bits_required = result;
end
endfunction

/*------------------------------------------------------------------
 * NOTE: The following contant CLOCKS4SEC should be 100, which means that
 *       we have to count CLOCKS4SEC clocks to measure a second. This value
 *       matches 100 Hz system clock given at design specification.
 *       But, it may take too much time for simulation with this value, and
 *       we can reduce this number to a number less than 100 to reduce
 *       simulation time. If we use 10 for CLOCKS4SEC for example, we count
 *       10 clocks to measure a second.
 *       If you modify the following constant, you also have to modify
 *       'time_per_sec' at testbenches in file 'time_tb.v' and 'tb12.v'.
 *       You also have to modify simulation run times at 'time.do' and
 *       'tb12.do'.
 *-------------------------------------------------------------------*/
parameter  CLOCKS4SEC = 100;
localparam MAX_COUNT = CLOCKS4SEC-1;
localparam NUM_BITS = bits_required(CLOCKS4SEC-1);

// Definitions of mode1/mode2 values
`include "dclockshare.v"

/*----------------------
 *   Internal signals
 *---------------------*/
// Outputs of SET_GEN block given at design spec.
reg inc_hours, inc_mins, inc_secs, elapse_time;

// Outputs of TIME_GEN block given at design spec.
reg [4:0] reg_hours;
reg [5:0] reg_mins;
reg [5:0] reg_secs;
reg reg_hour_carry;

// Design spec. says that we have to count 100 clocks to measure a second.
// But, we may actually count less than 100 clocks. (Or may count more than
// 100 clocks if you need.) For details, refer to the above NOTE.
// The following is the counter to measure a second.
reg [NUM_BITS-1:0] count100;


/*----------------------
 *   Table of when to increase hours, minutes, by SET switch and
 *         when time must go on (elapse).
 *   Refer to SET_GEN block in design spec.
 *---------------------*/
always @ (mode1 or mode2 or increase)
begin : SET_GEN
    /*
     *  Time adjust modes act according to 'sw2' and 'set' switches.
     */
    if ((mode1 == M1_TIME) && (increase == 1)) begin
        case (mode2)
            M2_TIME_HOUR : begin   // increment hours
                inc_hours = 1;     // only the 'inc_hours' is active.
                inc_mins  = 0;
                inc_secs  = 0;
            end
            M2_TIME_MIN : begin    // increment minutes
                inc_hours = 0;
                inc_mins  = 1;     // only the 'inc_mins' is active.
                inc_secs  = 0;
            end
            M2_TIME_SEC : begin    // increment seconds
                inc_hours = 0;
                inc_mins  = 0;
                inc_secs  = 1;     // only the 'inc_secs' is active.
            end
            default: begin         // do nothing in general mode, all off.
                inc_hours = 0;
                inc_mins  = 0;
                inc_secs  = 0;
            end
        endcase
    end else begin      // this is not TIME mode, all off.
        inc_hours = 0;
        inc_mins  = 0;
        inc_secs  = 0;
    end

    /*
     *  Time passes by when time adjust is not made.
     */
    if (mode1 == M1_TIME) begin
        if (mode2 == M2_TIME_G)
            elapse_time = 1;
        else
            elapse_time = 0;
    end else begin
        elapse_time = 1;
    end
end

/*----------------------
 *  Connect outputs of the following always block to ports of this module.
 *---------------------*/
assign hours = reg_hours;
assign mins = reg_mins;
assign secs = reg_secs;
assign hour_carry = reg_hour_carry;

/*----------------------
 *  Generates time as follows:
 *  Count MAX_COUNT+1 clocks to make a second,
 *  count 60 seconds to make a minute,
 *  count 60 minutes to make an hour, and
 *  count 24 hours to make a day.
 * 
 *  Refer to TIME_GEN block in design spec.
 *---------------------*/
always @ (posedge clk or negedge reset_n)
begin : TIME_GEN
    if (~reset_n) begin     // asynch reset, active low
        reg_hour_carry <= 0;
        reg_secs  <= 0;
        reg_mins  <= 0;
        reg_hours <= 0;
        count100 <= 0;
    end else begin          // All outputs are synched at rising edge
        /*
         *   reg_hour_carry defaults to off unless time passes to next day.
         */
        reg_hour_carry <= 0;

        /**
         *   time update by using SET switch.
         */
        if (inc_hours == 1) begin
            if (reg_hours == 23)
                reg_hours <= 0;
            else
                reg_hours <= reg_hours + 1'b1;
        end else if (inc_mins == 1) begin
            if (reg_mins == 59)
                reg_mins <= 0;
            else
                reg_mins <= reg_mins + 1'b1;
        end else if (inc_secs == 1) begin
            if (reg_secs == 59)
                reg_secs <= 0;
            else
                reg_secs <= reg_secs + 1'b1;

        /**
         *   time update as time goes on (as time elapse).
         */
        end else if (elapse_time == 1) begin
            if (count100 == MAX_COUNT) begin    // become a second
                count100 <= 0;
                if (reg_secs == 59) begin
                    reg_secs <= 0;
                    if (reg_mins == 59) begin
                        reg_mins <= 0;
                        if (reg_hours == 23) begin
                            reg_hours <= 0;
                            reg_hour_carry <= 1;         // A day has passed.
                        end else begin
                            reg_hours <= reg_hours + 1'b1;
                        end
                    end else begin   // reg_mins < 59
                        reg_mins <= reg_mins + 1'b1;
                    end
                end else begin   // reg_secs < 59
                    reg_secs <= reg_secs + 1'b1;
                end
            end else begin   // count100 < MAX_COUNT
                count100 <= count100 + 1'b1;
            end
        end   // elapse_time == 1
    end   // posedge clk
end
endmodule

/*--- TIME ---*/
