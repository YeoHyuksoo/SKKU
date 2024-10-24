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
 *  File name  : divider.v
 *  Written by : Yeo, Hyuk Soo
 *               2016312761
 *               School of Software
 *               Sungkyunkwan University
 *  Written on : Nov. 27, 2020
 *  Version    : 1.0
 *  Design     : Homework #4
 *               Binary number divider of Digital Clock.
 *
 *  Modification History:
 *      * version 1.0, Nov 27, 2020  by Hyuk Soo Yeo
 *        - version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*--------------------------------------------------------------------------------
 *  MODULE : DIVIDER
 *
 *  Description:
 *    DIVIDER transform time values which will be showed in digital clock
 *    to 2 decimal numbers.
 *
 *  Declaration of this module and comment are reprinted of 
 *  DigitalClock4.pdf which is copyrighted to Min, Hyoung Bok.
 *  Source : DigitalClock4.pdf, http://class.icc.skku.ac.kr/di/
 *  license : permitted to students for homework purpose only.
 *------------------------------------------------------------------------------*/
module DIVIDER (
    input [5:0] binary,
    output [3:0] bcd_h,
    output [3:0] bcd_l
);

// temporary space to contain one's digit of time value
reg [5:0] reg_ones_digit;

// Outputs of DIVIDER_GEN block.
reg [3:0] reg_bcd_h;
reg [3:0] reg_bcd_l;

// Connect outputs of DIVIDER_GEN block to ports of this module.
assign bcd_h = reg_bcd_h;
assign bcd_l = reg_bcd_l;

/*-----------------------------------------------------------------
 *  Table of dividing time value to 2 decimal number,
 *  ten's digit and one's digit.
 *  Get ten's digit with seeking range of number.
 *  After getting ten's digit, getting one's digit by subtraction.
 *----------------------------------------------------------------*/
always @ (binary) begin : DIVIDER_GEN
    if (binary >= 6'b110010) begin  // value bigger than 50
        reg_bcd_h = 4'b0101;  // ten's digit is 5
        reg_ones_digit = binary - 6'b110010;  // one's digit: value - 50
        reg_bcd_l = reg_ones_digit[3:0];
    end else if (binary >= 6'b101000) begin
        reg_bcd_h = 4'b0100;
        reg_ones_digit = binary - 6'b101000;
        reg_bcd_l = reg_ones_digit[3:0];
    end else if (binary >= 6'b011110) begin
        reg_bcd_h = 4'b0011;
        reg_ones_digit = binary - 6'b011110;
        reg_bcd_l = reg_ones_digit[3:0];
    end else if (binary >= 6'b010100) begin
        reg_bcd_h = 4'b0010;
        reg_ones_digit = binary - 6'b010100;
        reg_bcd_l = reg_ones_digit[3:0];
    end else if (binary >= 6'b001010) begin
        reg_bcd_h = 4'b0001;
        reg_ones_digit = binary - 6'b001010;
        reg_bcd_l = reg_ones_digit[3:0];
    end else begin
        reg_bcd_h = 4'b0000;
        reg_ones_digit = binary;
        reg_bcd_l = reg_ones_digit[3:0];
    end
end

endmodule
