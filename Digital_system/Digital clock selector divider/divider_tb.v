/*-------------------------------------------------------------------------
 *
 *  Copyright (c) 2004-2018 by Hyoung Bok Min, All rights reserved.
 *  For license information, please refer to
 *      http://class.icc.skku.ac.kr/~min/ds/license.html
 *
 *  File name  : divider_tb.v
 *  Written by : Min, Hyoung Bok
 *               Professor (Students write her/his student-id number)
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : July 11, 2018  (version 1.0)
 *  Version    : 1.0
 *  Design     : Homework #4
 *               Test bench of DIVIDER
 *
 *  Modification History:
 *      * version 1.0, July 11, 2018  by Hyoung Bok Min
 *        version 1.0 released.
 *
 *-------------------------------------------------------------------------*/

`timescale 1ns/1ps

/*---------------------------
 *  MODULE: DIVIDER_test
 *
 *  Testbench for module DIVIDER in divider.v
 *---------------------------*/

module DIVIDER_test;

/*--------------------------------------------------------------
 *  Interval between simulation vectors are applied
 *--------------------------------------------------------------*/
localparam vector_interval = 10;

/*--------------------------------------------------------------
 *  Delay between input application and output observation
 *--------------------------------------------------------------*/
localparam io_delay = 10;


// signals on which logic values will be assigned
reg [5:0] binary;

// signals which will be observed
wire [3:0] bcd_h, bcd_l;

/*-------------
 *  Get two digits of an integer.
 *-------------*/
task get_bcd;
    input [6:0] i_bin;
    output [3:0] i_bcdh, i_bcdl;
    reg [3:0] tmp;
    begin
        tmp = i_bin / 10;
        i_bcdh = tmp;
        i_bcdl = i_bin - tmp * 10;
    end
endtask


// Variables for test process.
reg [6:0] i_bin;
reg [3:0] i_bcdh, i_bcdl;
reg expected;

// instantiation of the design
// The following statement connects signals defined above to ports of design
DIVIDER U1 (
    .binary(binary),   // input: binary input
    .bcd_h(bcd_h),     // output: higher BCD digit
    .bcd_l(bcd_l)      // output: lower BCD digit 
);

// Students may think that the following 3 lines do not exist.
`ifdef PCODE1
`include "pcode1.v"
`endif


/*--------------------------
 *  Now, test begins
 *--------------------------*/
initial
begin : TEST_PROGRAM
    // parameters for timeformat is:  unit (-9 means ns), digits after dot,
    // string after $time, minimum string length
    $timeformat(-9, 0, " ns", 5);

    // Students may think that the following 3 lines do not exist.
    `ifdef PCODE2
    `include "pcode2.v"
    `endif

    $display("Simulation begins.");
    for (i_bin = 0 ; i_bin <= 59 ; i_bin = i_bin+1) begin
        if (!((i_bin+1) % 10))
            $display("Testing %0d of [0:59] at %0t", i_bin, $time);
        binary = i_bin;
        # io_delay;

        get_bcd(i_bin, i_bcdh , i_bcdl);
        expected = (bcd_h === i_bcdh);
        if (!expected) $error("Mismatch of bcd_h, expected=%4b, signal=%4b,",
                              i_bcdh, bcd_h);
        expected = (bcd_l === i_bcdl);
        if (!expected) $error("Mismatch of bcd_l, expected=%4b, signal=%4b, num=%0d",
                              i_bcdl, bcd_l, i_bin);
        # vector_interval;
    end

    $display("SIMULATION TERMINATED at %0t", $time);
    $stop(2);
end
endmodule

/*--- DIVIDER_test ---*/
