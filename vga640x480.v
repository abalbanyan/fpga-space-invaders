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
	input wire btnR,
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

parameter numAliens = 5;
parameter winningScore = numAliens * 10;
parameter topBarPos = 200 + vbp;
parameter leftBarPos = hbp + 200;
parameter rightBarPos = hfp - 200;

integer playerPosY = -70 + vfp;
integer playerPosX = 320 + hbp;
integer bulletPosX = 0;
integer bulletPosY = 0;

integer score = 0;

reg [10:0] alienPosXArray[0:numAliens-1];
reg [10:0] alienPosYArray[0:numAliens-1];
//parameter initialAlienX[0:numAliens-1];
//parameter initialAlienY[0:numAliens-1];

// For alien movement.
reg[7:0] alienTranslationCnt = 0;
reg[12:0] translation = 0;
reg[3:0] deadAliens = 2;
reg alienRight = 1;
reg[3:0] alienSpeed = 'b0110; // logical right shift to double speed


////// DEBOUNCING ////////
//reg [3:0] btnS_buff;
//reg game_clk_debounce;
//reg btnS_vld;
//////////////////////////

initial
begin
	alienPosXArray[0] = 200 + hbp;
	alienPosXArray[1] = 240 + hbp;
	alienPosXArray[2] = 280 + hbp;
	alienPosXArray[3] = 200 + hbp;
	alienPosXArray[4] = 280 + hbp;

	alienPosYArray[0] = 220 + vbp;
	alienPosYArray[1] = 220 + vbp;
	alienPosYArray[2] = 220 + vbp;
	alienPosYArray[3] = 600;//250 + vbp;
	alienPosYArray[4] = 600;//250 + vbp;
	
	//btnS_buff[0] = 0;
	//btnS_buff[1] = 0;
	//btnS_buff[2] = 0;
end



// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// flags
reg spawnBullet;
reg gameover = 0;
//reg pauseFlag;

// iterators
reg[6:0] i;
reg[6:0] j;
reg[6:0] k;
// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge clk)
begin
	if(btnU 	&& deadAliens < numAliens)
		if(bulletPosY <= topBarPos)
			spawnBullet <= 1;
	else if (bulletPosY > vbp)
		spawnBullet <= 0;
	
	// If aliens touch player then he dies.
	if(alienPosYArray[0] > playerPosY - 8 && alienPosYArray[0] < vfp ||
		alienPosYArray[1] > playerPosY - 8 && alienPosYArray[1] < vfp ||
	   alienPosYArray[2] > playerPosY - 8 && alienPosYArray[2] < vfp || 
	   alienPosYArray[3] > playerPosY - 8 && alienPosYArray[3] < vfp ||
	   alienPosYArray[4] > playerPosY - 8 && alienPosYArray[4] < vfp)
		gameover <= 1;
	
	// reset condition
	if (rst == 1)
	begin
		hc <= 0;
		vc <= 0;
		spawnBullet <= 0;
		//btnS_vld <= 0;
		//game_clk_debounce = 0;
		//pauseFlag <= 0;
	end
	else if (pix_en == 1)
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
	end
	
	//if(btnS_vld)
	//	pauseFlag <= ~pauseFlag;
	
	/////// DEBOUNCING ////////
	//game_clk_debounce = game_clk;
	//btnS_vld <= ~btnS_buff[0] & btnS_buff[1]; //& game_clk_debounce;
	///////////////////////////
end

always @(posedge game_clk or posedge spawnBullet)
begin

	if(spawnBullet)
	begin
		bulletPosX <= playerPosX + 9;
		bulletPosY <= playerPosY - 7;
	end 
   else //if (!pauseFlag)
	begin
		alienTranslationCnt <= alienTranslationCnt + 1;
		if(alienTranslationCnt == alienSpeed) //1)
		begin
			if(translation < 150)
				translation <= translation + 1;
			alienTranslationCnt <= 0;
			for(k = 0; k < numAliens; k = k + 1)
			begin
				if(translation < 144)
				begin	
					 // Putting this line here makes the synthesis take forever for some reason.
					if(alienRight)
						alienPosXArray[k] <= alienPosXArray[k] + 1;
					else
						alienPosXArray[k] <= alienPosXArray[k] - 1;
				end
				else // Move aliens down.
				begin
					translation <= 0;
					alienRight <= ~alienRight;
					alienPosYArray[k] <= alienPosYArray[k] + 10;
				end
			end
		end
				
		if(btnL && playerPosX != leftBarPos) // Move left.
			playerPosX <= playerPosX - 1;
		if(btnR && playerPosX != rightBarPos - 18) // Move right.
			playerPosX <= playerPosX + 1;
			
		// When player wins, travel upwards.
		if(deadAliens >= numAliens)
			playerPosY <= playerPosY - 1;
			
		// Advance to next level once the player reaches the top.
		if(playerPosY < vbp)
		begin
			alienPosXArray[0] <= 200 + hbp;
			alienPosXArray[1] <= 240 + hbp;
			alienPosXArray[2] <= 280 + hbp;
			alienPosXArray[3] <= 200 + hbp;
			alienPosXArray[4] <= 280 + hbp;

			alienPosYArray[0] <= 220 + vbp;
			alienPosYArray[1] <= 220 + vbp;
			alienPosYArray[2] <= 220 + vbp;
			alienPosYArray[3] <= 250 + vbp;
			alienPosYArray[4] <= 250 + vbp;
			
			playerPosY <= -70 + vfp;
			
			deadAliens <= 0;
			translation <= 0;
			alienRight <= 1;
			alienSpeed <= alienSpeed >> 1;
		end
			
		if(bulletPosY >= 0)
			bulletPosY <= bulletPosY - 1;
			
		// Kill alien once it comes into contact with a bullet.
		for(j = 0; j < numAliens; j = j + 1)
		begin
			if(bulletPosX > alienPosXArray[j] - 4 && bulletPosX <= alienPosXArray[j] + 14 &&
					bulletPosY - 8 <= alienPosYArray[j] && bulletPosY >= alienPosYArray[j])
			begin
				alienPosYArray[j] <= 600;
				bulletPosY <= 0;
				bulletPosX <= 0;
				score <= score + 10;
				deadAliens <= deadAliens + 1;
			end
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
	//////////// Debouncing ////////
	//btnS_buff <= {btnS,btnS_buff[2:1]};
	////////////////////////////////
	
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		if(gameover)
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b00;
		end
		// Draw bars at the sides of the screen.
		else if(hc >= rightBarPos || hc <= leftBarPos)
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b11;
		end
		// Draw bullet.
		else if (hc >= (bulletPosX) && hc < (bulletPosX + 2)
			&& vc >= (bulletPosY - 10) && vc < (bulletPosY))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b000;
		end
		// Draw player sprite.
		else if (hc >= (playerPosX) && hc < (playerPosX + 18)
				&& vc >= (playerPosY - 7) && vc < (playerPosY))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		else if (hc >= (playerPosX + 7) && hc < (playerPosX + 11)
				&& vc >= (playerPosY - 10) && vc < (playerPosY - 7))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		else
		// Draw black.
		begin
			red = 3'b000;
			green = 3'b000;
			blue = 2'b00;
		end
		
		// Score.
		if((hc >= hbp + 100 && hc < hbp + 150 &&
			vc <= topBarPos + 5 && vc > topBarPos + 5 - (score/50 * 4))
		||(hc >= hbp + 100 && hc < hbp + 100 + score % 50 &&
    		vc <= topBarPos + 5 && vc > topBarPos + 1 - (score/50 * 4)))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		
		// Draw S
		if( ((vc == topBarPos + 15 || vc == topBarPos + 16 || 
			  vc == topBarPos + 19 || vc == topBarPos + 20 ||
			  vc == topBarPos + 23 || vc == topBarPos + 24) &&
			  (hc > hbp + 100 && hc < hbp + 109)) ||
			  ((vc == topBarPos + 17 || vc == topBarPos + 18) &&
			  (hc == hbp + 101 || hc == hbp + 102)) || 
			  ((vc == topBarPos + 21 || vc == topBarPos + 22) &&
			  (hc == hbp + 107 || hc == hbp + 108)))
			begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
		// Draw C.
		if(((hc > hbp + 110 && hc < hbp + 119) &&
		(vc == topBarPos + 15 || vc == topBarPos + 16 ||
		vc == topBarPos + 23 || vc == topBarPos + 24)) ||
		((vc > topBarPos + 14 && vc < topBarPos + 25) &&
		(hc == hbp + 111 || hc == hbp + 112)))
		begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
		// Draw O.
		if(((vc == topBarPos + 15 || vc == topBarPos + 16 ||
		vc == topBarPos + 23 || vc == topBarPos + 24)
		&& (hc > hbp + 120 && hc < hbp + 129)) ||
		((vc > topBarPos + 14 && vc < topBarPos + 25)
		&& (hc == hbp + 121 || hc == hbp + 122 ||
		hc == hbp + 127 || hc == hbp + 128)))
			begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
		// Draw R.
		if(((hc > hbp + 130 && hc < hbp + 133) &&
		(vc >= topBarPos + 15 && vc <= topBarPos + 24)) ||
		((hc >= hbp + 135 && hc < hbp + 137) &&
		(vc >= topBarPos + 15 && vc <= topBarPos + 20)) ||
		((hc >= hbp + 137 && hc < hbp + 139) &&
		(vc >= topBarPos + 20 && vc <= topBarPos + 24))||
		((vc == topBarPos + 15 || vc == topBarPos + 16) &&
		(hc > hbp + 130 && hc < hbp + 137)) ||
		((vc == topBarPos + 19 || vc == topBarPos + 20) &&
		(hc > hbp + 130 && hc < hbp + 139)))
		begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
		// Draw E.
		if(((vc == topBarPos + 15 || vc == topBarPos + 16
		|| vc == topBarPos + 19 || vc == topBarPos + 20
		|| vc == topBarPos + 23 || vc == topBarPos + 24)
		&& (hc > hbp + 140 && hc < hbp + 149)) ||
		((vc > topBarPos + 14 && vc < topBarPos + 25)
		&& (hc == hbp + 141 || hc == hbp + 142)))
			begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
		
		for(i = 0; i < numAliens; i = i + 1)
		begin
				if((hc > alienPosXArray[i] + 1 &&  hc <  alienPosXArray[i] + 9   &&
				  vc <  alienPosYArray[i] - 1  &&  vc >  alienPosYArray[i] - 6   &&
				!(vc == alienPosYArray[i] - 4  && (hc == alienPosXArray[i] + 3  ||  hc == alienPosXArray[i] + 7 ))) ||
				((hc == alienPosXArray[i]      ||  hc == alienPosXArray[i] + 10)&& (vc <  alienPosYArray[i] && vc > alienPosYArray[i] - 4)) ||
				((hc == alienPosXArray[i] + 1  ||  hc == alienPosXArray[i] + 9) && (vc == alienPosYArray[i] - 3 || vc == alienPosYArray[i] - 4)) ||
				 (hc >  alienPosXArray[i] + 2  &&  hc <  alienPosXArray[i] + 8  &&  hc != alienPosXArray[i] + 5  && vc == alienPosYArray[i]) ||
				 ((hc == alienPosXArray[i] + 2  || hc == alienPosXArray[i] + 8)  &&  vc == alienPosYArray[i] - 1) ||
				 ((hc == alienPosXArray[i] + 3  || hc == alienPosXArray[i] + 7) && vc == alienPosYArray[i] - 6 ))
				
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
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
