`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module NERP_demo_top(
	input wire clk,			//master clock = 100MHz
	input wire clr,			//right-most pushbutton for reset
	input wire sw,				// first switch
	input wire btnS, 			// middle button, move right
	input wire btnU,			// up button, shoot
	input wire btnL,			// left button, move left
	//output wire [6:0] seg,	//7-segment display LEDs
	//output wire [3:0] an,	//7-segment display anode enable
	//output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// VGA display clock interconnect
wire pix_en;
wire game_clk;

	reg rst;
	reg rst_ff;
 
	always @(posedge clk or posedge clr) begin
		if (clr) begin
			{rst,rst_ff} <= 2'b11;
		end
		else begin
			{rst,rst_ff} <= {rst_ff,1'b0};
		end
	end


// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.rst(rst),
	.pix_en(pix_en),
	.game_clk(game_clk)
	);

// VGA controller
vga640x480 U3(
	.pix_en(pix_en),
	.game_clk(game_clk),
	.clk(clk),
	.rst(rst),
	.btnS(btnS),
	.btnU(btnU),
	.btnL(btnL),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);

endmodule
