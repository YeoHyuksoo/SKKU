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
 *  File name  : timer.v
 *  Written by : Yeo, Hyuk Soo
 *               2016312761
 *               School of Software
 *               Sungkyunkwan University
 *  Written on : Nov. 17, 2020
 *  Version    : 1.1
 *  Design     : Homework #3
 *               TIMER module of Digital Clock.
 *
 *  Modification History:
 *      * version 1.1, Nov. 17, 2020 by Hyuk Soo Yeo
 *        - Change types of output ports from reg's to wire's.
 *      * version 1.0, Nov 11, 2020  by Hyuk Soo Yeo
 *        version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*--------------------------------------------------------------------------------
 *  MODULE : TIMER
 *
 *  Description:
 *    TIMER measures elapsed time with minute, second, and microsecond.
 *    Also there is a function of reset timer bits.
 *    TIMER_G, TIMER_START, TIMER_STOP modes are given
 *    by MODE_GEN to measure time.
 *
 *  Implementation:
 *    We collects 10 rising edges of clk to make 100 microsecond.
 *    We can measure time until 59 minutes, 59 seconds in maximum.
 *    Initial states of the timer are 00:00:00.
 *    counting the number of rising edges to make a microsecond
 *    is parameterized by CLOCK4SEC and MAX_COUNT
 *    which is below module declaration.
 *
 *  Declaration of this module and comment are reprinted of 
 *  DigitalClock3.pdf which is copyrighted to Min, Hyoung Bok.
 *  Source : DigitalClock3.pdf, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *------------------------------------------------------------------------------*/
module TIMER (
    input clk,
    input reset_n,       // asynchronous reset, active low
    input [1:0] mode1,   // major mode from mode generator module
    input [1:0] mode2,   // minor mode from mode generator module

    output [5:0] min_sw,   // minutes of timer
    output [5:0] sec_sw,   // seconds of timer
    output [5:0] secc_sw  // microseconds of timer
);

/*
 *  Given a positive integer,
 *  Returns the number of bits which fits the integer as binary number.
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
 *  The following constant CLOCKS4SEC should be 10,
 *  which means that we have to count 10 clocks to measure 100 microsecond.
 *  But, it may take too much time for simulation with this value, so
 *  we parameterized these values.
 *-------------------------------------------------------------------*/
parameter  CLOCKS4SEC = 10;
localparam MAX_COUNT = CLOCKS4SEC-1;
localparam NUM_BITS = bits_required(CLOCKS4SEC-1);

/*-------------------------------------------------------------------------
 *  I include header file containing definitions of mode1/mode2 values
 *  which is copyrighted to Min, Hyoung Bok.
 *  Source : dclockshare.v, http://class.icc.skku.ac.kr/di/
 *  license: permitted to students for homework purpose only.
 *-------------------------------------------------------------------------*/
`include "dclockshare.v"

// Outputs of TIMER block given at design spec.
reg [5:0] reg_min_sw;
reg [5:0] reg_sec_sw;
reg [5:0] reg_secc_sw;

// Following is the counter to measure 100 microsecond.
reg [NUM_BITS-1:0] count10;

/*----------------------
 *  Connect outputs of the following always block to ports of this module.
 *---------------------*/
assign min_sw = reg_min_sw;
assign sec_sw = reg_sec_sw;
assign secc_sw = reg_secc_sw;

/*-----------------------------------------------------------------
 *  Table of measuring elapsed time in TIMER_START mode
 *  Count MAX_COUNT+1 clocks to make 100 microseconds,
 *  count 1000 microseconds to make a second,
 *  count 60 seconds to make a minute.
 *----------------------------------------------------------------*/
always @ (posedge clk or negedge reset_n) begin : TIMER_GEN
    if (~reset_n) begin     // asynch reset, active low
        reg_min_sw <= 0;
        reg_sec_sw  <= 0;
        reg_secc_sw  <= 0;
        count10 <= 0;
    end else begin          // All outputs are synched at rising edge
        if (mode1 == M1_TIMER) begin
            if (mode2 == M2_TIMER_START) begin
                if (count10 == MAX_COUNT) begin  // 100 microseconds elapsed
                    count10 <= 0;
                    if (reg_secc_sw == 9) begin  // 1 second elapsed
                        reg_secc_sw <= 0;
                        if (reg_sec_sw == 59) begin  // 1 minute elapsed
                            reg_sec_sw <= 0;
                            if (reg_min_sw == 59) begin  // 1 hour elapsed
                                reg_min_sw <= 0;
                            end else begin
                                reg_min_sw <= reg_min_sw + 1'b1;
                            end
                        end else begin
                            reg_sec_sw <= reg_sec_sw + 1'b1;
                        end
                    end else begin
                        reg_secc_sw <= reg_secc_sw + 1'b1;
                    end
                end else begin  // make 100 microseconds
                    count10 <= count10 + 1'b1;
                end
            end else if (mode2 == M2_TIMER_G) begin  // reset switch
                reg_min_sw <= 0;
                reg_sec_sw <= 0;
                reg_secc_sw <= 0;
                count10 <= 0;
            end
        end else begin  // this is not TIMER mode, reset.
            reg_min_sw <= 0;
            reg_sec_sw <= 0;
            reg_secc_sw <= 0;
            count10 <= 0;
        end
    end
end

endmodule

/*--- TIMER ---*/