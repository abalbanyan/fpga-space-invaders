`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
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
module vga640x480(
	input wire pix_en,		//pixel clock: 25MHz
	input wire game_clk,
	input wire clk,			//100MHz
	input wire rst,			//asynchronous reset
	input wire btnS,
	input wire btnU,
	input wire btnL,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch

// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// Note: Top of screen is 0 + vbp

parameter bottomBarY = -25 + vfp;

integer playerPosX = 320 + hbp;
integer playerPosY = -30 + vfp;
integer bulletPosX = 0;
integer bulletPosY = 0;

integer alienPosX = 320 + hbp;
integer alienPosY = 240 + vbp;

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// flags
reg movingRight;
reg movingLeft;
reg spawnBullet;


// TODO: Is there an elegant way to implement sprites?
// TODO: Need to support multiple aliens.

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge clk)
begin
	if(btnS)
		movingRight <= 1;
	else
		movingRight <= 0;
	
	if(btnL)
		movingLeft <= 1;
	else
		movingLeft <= 0;
	
	if(btnU)
		spawnBullet <= 1;
	else if(bulletPosX > vbp)
		spawnBullet <= 0;
	

	
	// reset condition
	if (rst == 1)
	begin
		hc <= 0;
		vc <= 0;
		movingRight <= 0;
		movingLeft <= 0;
		spawnBullet <= 0;
	end
	else if (pix_en == 1)
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

always @(posedge game_clk or posedge spawnBullet)
begin
	if(spawnBullet)
	begin
		bulletPosX <= playerPosX + 7;
		bulletPosY <= playerPosY - 7;
	end 
   else
	begin
		if(movingLeft)
			playerPosX <= playerPosX - 1;
		if(movingRight)
			playerPosX <= playerPosX + 1;
			
		if(bulletPosY >= 0)
			bulletPosY <= bulletPosY - 1;
			
		// Kill alien once it comes into contact with a bullet.
		if(bulletPosX > alienPosX - 2 && bulletPosX <= alienPosX + 18 &&
			bulletPosY <= alienPosY)
		begin
			alienPosY <= 0;
			bulletPosY <= 0;
		end
	end
			

	
	
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// Draw bullet.
		if (hc >= (bulletPosX) && hc < (bulletPosX + 6)
			&& vc >= (bulletPosY - 6) && vc < (bulletPosY))
		begin
			red = 3'b111;
			green = 2'b11;
			blue = 2'b11;
		end
		// Draw alien(s).
		else if (hc >= (alienPosX) && hc < (alienPosX + 16)
				&& vc >= (alienPosY - 16) && vc < (alienPosY))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		// Draw player sprite.
		else if (hc >= (playerPosX) && hc < (playerPosX + 20)
				&& vc >= (playerPosY - 8) && vc < (playerPosY))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		else if (hc >= (playerPosX + 8) && hc < (playerPosX + 12)
				&& vc >= (playerPosY - 11) && vc < (playerPosY - 8))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule
