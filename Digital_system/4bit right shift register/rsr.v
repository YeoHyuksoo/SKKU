/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2020 by Hyuk Soo Yeo, All rights reserved.
 *
 *  File name  : adder2.v
 *  Written by : Yeo, Hyuk Soo
 *               2016312761
 *               School of Software
 *               Sungkyunkwan University
 *  Written on : October 10, 2020
 *  Version    : 1.0
 *  Design     : Four bit right shift register:
 *               do right shifting for 4 bits, and
 *               produce shifted 4 bits and 
		 left most significant bit output.
 *
 *  Modification History:
 *      * October 10, 2020  by Hyuk Soo Yeo
 *        v1.0 released.
 *
 *  This program works by rising edge of clock.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ns

/*------------------------------------------------------------
 *  Module: rsr
 *
 *  Description:
 *    This is an implementation of right shift register.
 *    I use combinational logic circuit for assigning output
 *    and updated 4 bits.
 *------------------------------------------------------------*/

module rsr(si, clk, so);
input si;
input clk;
output so;

parameter NBITS = 4;
//  We need bits storage working like queue.
reg [NBITS-1:0] Q;

assign so = Q[0];
always @ (posedge clk) begin
    Q <= {si, Q[NBITS-1:1]};
end

endmodule