/*-------------------------------------------------------------------------
 *
 *  This code and top comment form is written by
 *  referencing time.v
 *  which is copyrighted to Min, Hyoung Bok.
 *  Source : time.v, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *
 *  Copyright (c) 2020 by Hyuk Soo Yeo, All rights reserved.
 *
 *  File name  : time.v
 *  Written by : Yeo, Hyuk Soo
 *               2016312761
 *               School of Software
 *               Sungkyunkwan University
 *  Written on : Nov. 17, 2020
 *  Version    : 1.1
 *  Design     : Homework #3
 *               DATE Generator of Digital Clock.
 *
 *  Modification History:
 *      * version 1.1, Nov. 17, 2020  by Hyuk Soo Yeo
 *        - Change types of output ports from reg's to wire's.
 *      * version 1.0, Nov 11, 2020  by Hyuk Soo Yeo
 *        version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*--------------------------------------------------------------------------------
 *  MODULE : DATE
 *
 *  Description:
 *    DATE generates current date with month, day.
 *    Of course, there is a feature to adjust value of month and day.
 *    DATE_MON, DATE_DAY modes are given by MODE_GEN to adjust date.
 *
 *  Implementation:
 *    We observe the bit hour_carry which is updated in TIME module when
 *    new day became.
 *    If hour_carry set to 1, day bit will be increased.
 *    We count a year with same flow of calendar.
 *    Initial states of the date is January 1st, 01:01:00.
 *
 *  Declaration of this module and comment are reprinted of 
 *  DigitalClock3.pdf which is copyrighted to Min, Hyoung Bok.
 *  Source : DigitalClock3.pdf, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *------------------------------------------------------------------------------*/
module DATE (
    input clk,
    input hour_carry,    // 1 if day increment is required
    input increase,      // 1 if date should be set by button press
    input reset_n,       // asynchronous reset, active low
    input [1:0] mode1,   // major mode from mode generator module
    input [1:0] mode2,   // minor mode from mode generator module

    output [3:0] mon,   // month value of date
    output [5:0] day    // day value of date
);

/*-------------------------------------------------------------------------
 *  I include header file containing definitions of mode1/mode2 values
 *  which is copyrighted to Min, Hyoung Bok.
 *  Source : dclockshare.v, http://class.icc.skku.ac.kr/di/
 *  license: permitted to students for homework purpose only.
 *-------------------------------------------------------------------------*/
`include "dclockshare.v"

//  Outputs of SET_GEN block
reg inc_mon, inc_day, elapse_date;

// Outputs of DATE_GEN block given at design spec.
reg [3:0] reg_mon;
reg [5:0] reg_day;

/*----------------------------------------------------------------
 *   Table of when to increase month and day, by SET switch
 *   and when date must go on (elapse).
 *   Refer to SET_GEN block in design spec.
 *----------------------------------------------------------------*/
always @ (mode1 or mode2 or increase) begin : SET_GEN
    if ((mode1 == M1_DATE) && (increase == 1)) begin
        case (mode2)
            M2_DATE_MON : begin  // increment month
                inc_mon = 1;
                inc_day = 0;
            end
            M2_DATE_DAY : begin  // increment day
                inc_mon = 0;
                inc_day = 1;
            end
            default: begin       // do nothing in general mode, all off.
                inc_mon = 0;
                inc_day = 0;
            end
        endcase
    end else begin  // this is not DATE mode, all off.
        inc_mon = 0;
        inc_day = 0;
    end
    /*
     *  Time passes by when date adjust is not made.
     *  So date should be also updated following time.
     */
    if (mode1 == M1_DATE) begin
        if (mode2 == M2_DATE_G)
            elapse_date = 1;
        else
            elapse_date = 0;
    end else begin
        elapse_date = 1;
    end
end

/*----------------------
 *  Connect outputs of the following always block to ports of this module.
 *---------------------*/
assign mon = reg_mon;
assign day = reg_day;

/*-----------------------------------------------------------------
 *   Table of generating date by SET switch,
 *   or just hour_carry(elapse)
 *   count 28 days in Feb.
 *   count 30 days in Apr, Jun, Sept, Nov.
 *   count 31 days in rest months.
 *----------------------------------------------------------------*/
always @ (posedge clk or negedge reset_n) begin : DATE_GEN
    if (~reset_n) begin  // asynchronous reset
        reg_mon <= 1;
        reg_day <= 1;
    end else begin       // All outputs are updated at rising edge
        /*
         *  date changes by registers which
         *  are updated by SET_GEN block.
         */
        if (inc_mon == 1) begin
            if (reg_mon == 12)
                reg_mon <= 1;
            else
                reg_mon <= reg_mon + 1'b1;
        end else if (inc_day == 1) begin
            if (reg_mon == 2) begin  // if February
                if (reg_day == 28)
                    reg_day <= 1;
                else
                    reg_day <= reg_day + 1'b1;
            end else if (reg_mon == 4 || reg_mon == 6 || reg_mon == 9 || reg_mon == 11) begin
                // if last day of month is 30th
                if (reg_day == 30)
                    reg_day <= 1;
                else
                    reg_day <= reg_day + 1'b1;
            end else begin  // if last day of month is 31st
                if (reg_day == 31)
                    reg_day <= 1;
                else
                    reg_day <= reg_day + 1'b1;
            end
        end else if (elapse_date == 1) begin
            //  a day elapsed as time goes on and hour_carry sets to 1
            if (hour_carry == 1) begin
                if (reg_mon == 2) begin
                    if (reg_day == 28) begin
                        reg_day <= 1;
                        reg_mon <= reg_mon + 1'b1;
                    end else begin
                        reg_day <= reg_day + 1'b1;
                    end
                end else if (reg_mon == 4 || reg_mon == 6 || reg_mon == 9 || reg_mon == 11) begin
                    if (reg_day == 30) begin
                        reg_day <= 1;
                        reg_mon <= reg_mon + 1'b1;
                    end else begin
                        reg_day <= reg_day + 1'b1;
                    end
                end else begin
                    if (reg_day == 31) begin
                        reg_day <= 1;
                        if (reg_mon == 12)  // new year became
                            reg_mon <= 1;
                        else
                            reg_mon <= reg_mon + 1'b1;
                    end else begin
                        reg_day <= reg_day + 1'b1;
                    end
                end
            end
        end
    end
end

endmodule

/*--- DATE ---*/
