/*-------------------------------------------------------------------------
 *
 *  Top comment form and other module related comment form are
 *  written by referencing time.v
 *  which is copyrighted to Min, Hyoung Bok.
 *  Source : time.v, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *
 *  Copyright (c) 2020 by Hyuk Soo Yeo, All rights reserved.
 *
 *  File name  : selector.v
 *  Written by : Yeo, Hyuk Soo
 *               2016312761
 *               School of Software
 *               Sungkyunkwan University
 *  Written on : Nov. 27, 2020
 *  Version    : 1.0
 *  Design     : Homework #4
 *               ALARM Generator and Selector of Digital Clock.
 *
 *  Modification History:
 *      * version 1.0, Nov 27, 2020  by Hyuk Soo Yeo
 *        - version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*-------------------------------------------------------------------------------
 *  MODULE : ALARM_SET
 *
 *  Description:
 *    ALARM_SET generates alarm signal when the alarm time came.
 *    Of course, there is a feature to change alarm time.
 *    ALARM_HOUR, ALARM_MIN modes are given by MODE_GEN module
 *    to adjust alarm time.
 *
 *  Implementation:
 *    We observe present time bits and compare with alarm time.
 *    If present time is same with alarm time, generate alarm signal.
 *    Stop the alarm giving 1 to set input.
 *
 *  Declaration of this module are reprinted of 
 *  DigitalClock4.pdf which is copyrighted to Min, Hyoung Bok.
 *  Source : DigitalClock4.pdf, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *-----------------------------------------------------------------------------*/
module ALARM_SET (
    input clk,
    input increase,  // signal of increment alarm time value
    input set,  // signal of stopping alarm
    input reset_n,  // asynchronous reset, active low
    input [1:0] mode1,  // major mode from mode generator module
    input [1:0] mode2,  // minor mode from mode generator module
    input [4:0] hours,
    input [5:0] mins,
    output [4:0] alarm_h,
    output [5:0] alarm_m,
    output alarm
);

/*-------------------------------------------------------------------------
 *  I include header file containing definitions of mode1/mode2 values
 *  which is copyrighted to Min, Hyoung Bok.
 *  Source : dclockshare.v, http://class.icc.skku.ac.kr/di/
 *  license: permitted to students for homework purpose only.
 *-------------------------------------------------------------------------*/
`include "dclockshare.v"

// Outputs of SET_GEN block
reg inc_hours, inc_mins;


// Table of generating increment of hour and minute in alarm time.
always @ (mode1 or mode2 or increase) begin : SET_GEN
    if ((mode1 == M1_ALARM) && (increase == 1)) begin
        case (mode2)
            M2_ALARM_HOUR : begin  // increment hours
                inc_hours = 1;
                inc_mins  = 0;
            end
            M2_ALARM_MIN : begin  // increment minutes
                inc_hours = 0;
                inc_mins  = 1;
            end
            default: begin  // do nothing in general mode, all off.
                inc_hours = 0;
                inc_mins  = 0;
            end
        endcase
    end else begin  // If not in ALARM mode, all off.
        inc_hours = 0;
        inc_mins  = 0;
    end
end

// Outputs of ALARM_GEN block
reg [4:0] alarm_snooze_h;
reg [5:0] alarm_snooze_m;
reg [4:0] reg_alarm_h;
reg [5:0] reg_alarm_m;
reg alarm_on;
reg reg_alarm;

// Connect outputs of ALARM_GEN block to ports of this module.
assign alarm_h = reg_alarm_h;
assign alarm_m = reg_alarm_m;
assign alarm = reg_alarm;

/*-----------------------------------------------------------------
 *  Table of generating alarm by comparing present time and
 *  alarm time. 
 *  only considering hour and minute value in alarm.
 *  If alarm becomes active and immediately turned off by snooze
 *  button, there should not be more alarm again.
 *----------------------------------------------------------------*/
always @ (posedge clk or negedge reset_n) begin : ALARM_GEN
    if (~reset_n) begin     // asynch reset, active low
        alarm_on <= 0;
        reg_alarm <= 0;
        reg_alarm_h <= 0;
        reg_alarm_m <= 0;
    end else begin
        if (mode1 == M1_ALARM && (mode2 == M2_ALARM_HOUR || mode2 == M2_ALARM_MIN)) begin
            alarm_on <= 1'b1;
        end
        if (hours == alarm_h && mins == alarm_m && alarm_on == 1'b1) begin  // alarm should ring
            // repeat-alarm in same time although we already snooze alarm
            if (alarm_snooze_h == alarm_h && alarm_snooze_m == alarm_m)
                reg_alarm <= 1'b0;  // protecting from repeat-alarm
            else
                reg_alarm <= 1'b1;
        end
        if (set == 1'b1) begin  // snooze the alarm
            reg_alarm <= 1'b0;
            alarm_snooze_h <= alarm_h;
            alarm_snooze_m <= alarm_m;
        end
        if (inc_hours == 1'b1) begin
            if (reg_alarm_h == 23)
                reg_alarm_h <= 0;
            else
                reg_alarm_h <= reg_alarm_h + 1'b1;
        end else if (inc_mins == 1'b1) begin
            if (reg_alarm_m == 59)
                reg_alarm_m <= 0;
            else
                reg_alarm_m <= reg_alarm_m + 1'b1;
        end
        /*------------------------------------------------------------------------
         *  If time passed at least 1 min since snoozing alarm, stop protecting
         *  repeat-alarm by assigning impossible time value to snoozed time.
         *-----------------------------------------------------------------------*/
        if ((alarm_snooze_h != hours && alarm_snooze_h != 25) || (alarm_snooze_m != mins && alarm_snooze_m != 60)) begin
            alarm_snooze_h <= 25;
            alarm_snooze_m <= 60;
        end
    end
end
        
endmodule

/*-----------------------------------------------------------------------------
 *  MODULE : SELECTOR
 *
 *  Description:
 *    DATE chooses the mode to show in LED driver
 *    and updates values directly.
 *
 *  Declaration of this module are reprinted of 
 *  DigitalClock4.pdf which is copyrighted to Min, Hyoung Bok.
 *  Source : DigitalClock4.pdf, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *----------------------------------------------------------------------------*/
module SELECTOR (
    input clk,
    input increase,
    input set,
    input reset_n,
    input [1:0] mode1, mode2,
    input [4:0] hours,
    input [5:0] mins, secs,
    input [3:0] mon,
    input [4:0] day,
    input [5:0] min_sw, sec_sw,
    input [3:0] secc_sw,
    output [5:0] out_h, out_m, out_s,
    output alarm
);

/*-------------------------------------------------------------------------
 *  I include header file containing definitions of mode1/mode2 values
 *  which is copyrighted to Min, Hyoung Bok.
 *  Source : dclockshare.v, http://class.icc.skku.ac.kr/di/
 *  license: permitted to students for homework purpose only.
 *------------------------------------------------------------------------*/
`include "dclockshare.v"

// connecting with outputs of ALARM_SET module.
wire [4:0] alarm_h;
wire [5:0] alarm_m;

ALARM_SET alarm_set(.clk(clk), .increase(increase), .set(set), .reset_n(reset_n),
                    .mode1(mode1), .mode2(mode2), .hours(hours), .mins(mins),
                    .alarm_h(alarm_h), .alarm_m(alarm_m), .alarm(alarm));

// Outputs of SELECTOR_GEN block
reg [5:0] reg_out_h;
reg [5:0] reg_out_m;
reg [5:0] reg_out_s;

// Connect outputs of SELECTOR_GEN block to ports of this module.
assign out_h = reg_out_h;
assign out_m = reg_out_m;
assign out_s = reg_out_s;

/*-----------------------------------------------------------------
 *  Table of generating values which are showed to LED driver
 *  of digital clock.
 *  works when mode or time related values change.
 *----------------------------------------------------------------*/
always @ (mode1 or mode2 or hours or mins or secs or mon or day or min_sw or sec_sw or secc_sw or alarm_h or alarm_m) begin : SELECTOR_GEN
    if (mode1 == M1_TIME) begin  // show present time
        reg_out_h[4:0] = hours;
        reg_out_h[5] = 1'b0;
        reg_out_m = mins;
        reg_out_s = secs;
    end else if (mode1 == M1_DATE) begin  // show month, day
        reg_out_h[3:0] = mon;
        reg_out_h[5:4] = 2'b0;
        reg_out_m[4:0] = day;
        reg_out_m[5] = 1'b0;
        reg_out_s = 5'b0;
    end else if (mode1 == M1_TIMER) begin  // show timer
        reg_out_h = min_sw;
        reg_out_m = sec_sw;
        reg_out_s[3:0] = secc_sw;
        reg_out_s[5:4] = 2'b0;
    end else begin  // show alarm time
        reg_out_h[4:0] = alarm_h;
        reg_out_h[5] = 1'b0;
        reg_out_m = alarm_m;
        reg_out_s = 5'b0;
    end
end

endmodule
