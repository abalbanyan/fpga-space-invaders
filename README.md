# fpga-space-invaders
This was developed as a final project for my logic design lab, CSM152A. It was developed over the course of three weeks and designed to be played on the Nexys3 FPGA.
Since this was designed for an FPGA - it is implemented entirely using hardware. Due to the limitations of the Nexys3, I was limited in how much carry-ahead logic I was able to stuff into the board. As such, only up to 5 aliens are able to fit on the screen at once. 

### Gameplay
This game is styled after the classic arcade game Space Invaders. It is a simplified version - it uses less aliens, and the aliens do not shoot at the player. In addition, the player only has one life.
Players can use the left and right buttons on the FPGA to move the spaceship, and the up button to shoot bullets at the aliens.
The aliens move left to right across the screen, and move downwards towards the player whenever they reach an edge. When the aliens reach the player, the game ends. If the player is able to destroy all the aliens, they advance towards the next stage, where aliens become faster and more difficult to destroy.


If you're interested in seeing what the game looks like, please check out this video!
https://www.youtube.com/watch?v=uwngvUDSyJM
