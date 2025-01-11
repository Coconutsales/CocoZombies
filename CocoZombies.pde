// Zombie Infection Simulation >> CocoZombies Version 1.4 <<

// Kevan Davis, 16/8/03 < The original dev

// Modified by John Gilbertson 25/09/03 < The work I, Coconutsales, am basing CocoZombies off of
//  just making zombies more dangerous, edited level creation code, increased max zombies, made zombies less likely to group etc...

// Modified by Coconutsales January 2025
//   adding various things, see README or Github >> https://github.com/Coconutsales/CocoZombies <<

// >> vv GLOBAL VARIABLES vv <<
// Gameplay Misc
float versNum = 1.4; // Used for Version number display in splash screen only right now
int popMax = 20000; // Max Pop
int popMin = 1000; // Min Pop
int popCount = 1000 * ceil(((popMax - popMin) / 2) / 1000); // Set population between popMax and popMin. Rounds up to nearest 1000 !!!Full [R]eset Variable!!!
int popZomb = 5; // Starting number of zombies to spawn !!!Full [R]eset Variable!!!
int speed = 1; // Speed of NPCs
int panic = 5; // Speed of panichuman
int clock = 0; // Game starts at 0, count increases with each simulation turn
int amtFPS = 45; // Used to increase or decrease FPS with keypresses. Basically increase or decrease simulation speed. !!!Full [R]eset Variable!!!
int uiHeight = 60; // Used to make sure a portion of the game window is blocked off for UI display
boolean pause; // Used to pause simulation, and prevent movement or being actions while false. Set true at end of setup. Previously 'freeze'
boolean enableDecay = true; // Can zombies die of old age (decay)? !!!Full [R]eset Variable!!!
boolean playerFocused = false; // If the player has not clicked onto the game yet, show them a startup splash screen
boolean inMenu = false; // Determines if the player is currently in a rendered UI menu, pauses simulation until user exits via enterMenu and exitMenu
// COLORS
int zombie = color(0,255,0); // Zombies are Green
int human = color(200,0,200); // Humans are Pink
int panichuman = color(255,120,255); // Panicking Humans are Light Pink
int dead = color(128,30,30); // Dead beings are Burgundy
int wall = color(50,50,60); // Walls are Grey, Blocks Humans, destroyed by Zombies or player (mouse interaction)
int empty = color(0,0,0); // Empty space is Black
int hit = color(100,75,50); // Explosion craters are Brown (Originally 128,128,0 ; olive)
// NPC Type Values
int iszombie = 1; // Definition for counting if being is a zombie
int ishuman = 2; // Definition for counting if being is a human
// int isarmed = 3; // UNUSED, placeholder for units that fight back
int ispanichuman = 4; // Definition for counting if being is panicking
int isdead = 5; // Definition for counting if being is dead

// Unused stuff
// I'm trying to find a way to create map seeds to soft reset a generated map, without using randomSeed() which makes ALL program random numbers deterministic
// int genSeed = (int)random(99999999); // Seed is randomized in program Start or Full Reset


Being[] beings;

// Setup is responsible for: Loading the font used for UI, setting the size of the window, initializing X and Y variables, setting game clock to 0 (in case of [r]esets)
// Spawning obstacles (Empty space bordered Rectangles for paths, and Empty filled Rectangles for large open areas, and walls on the window border)
// Spawning obstacles are precisely used to prevent NPC Beings from being placed anywhere which is not EMPTY space.
// Setup is ALWAYs run first when the program is run. Hotkeys allow setup to be run on command, functionally restarting the program while keeping set Global variables
void setup()
{
    PFont mainfont = loadFont("Univers65-24s.vlw"); // Sets font f to the vlw file named, stored in \data\fontname.vlw
    textFont(mainfont,12); // Sets text to use Font 'f' at size 12
    int x,y; 
    size(1000,600 + 60);  // Size of the simulation window (+ UI height)
    noSmooth(); // Disables anti-aliasing (default at 2xAA) - we render pixels, here... AA just slows the simulation down unnecessarily
    clock = 0;
    
    // PATHWAY GENERATION (uses "empty" strokes)
    background(wall); // sets the whole image to be Wall colored. All shapes are later drawn over this.
    fill(wall); // Sets the fill for upcoming rectangle generation
    stroke(empty); // Sets the outline for upcoming rectangle generation, empty to make pathways
    for (int i = 0; i < 100; i++) // For 100 iterations, create a randomly placed and randomly sized rectangle size constrained to 1/4th the width/height of the screen
        {
        rect((int)random(1,width) - (width / 8),(int)random(height) - (height / 8),(int)random(width / 4),(int)random(height / 4)); // rect(xpos, ypos, xwidth, yheight)
    }
    // EMPTY SPACE GENERATION (Using empty fill)
    fill(empty);
    noStroke();
    for (int i = 0; i < (width / 4); i++) // Adds black empty squares, amount up to 1/4th the screen Width number
        {
        rectMode(CENTER); // Sets Rectangle origin to be at its center (xCENTER, yCENTER, width, height)
        rect((int)random(2, width - 2),(int)random(2, height - 2),(int)random(15, 75),(int)random(15, 75));
        
        x = (int)random(1, width - 1) + 1;
        y = (int)random(1, height - 1) + 1;
        rectMode(CORNER); // Resets the Rectangle origin to top-left corner to not affect the rest of the rectangle code
    }
    // Borderwall Setup (to prevent NPC spawns in unauthorized areas) - With the exception of the bottom wall for UI space, this is purely visual
    // Without the bottom borderwall, NPCs will spawn in the UI and be unable to do anything except move around and glitch in place
    fill(wall);
    noStroke();
    rect(0,0,width,2); // 2px borderwall on the Top, Notes: (X_origin, Y|origin, WIDTH_SIZE, HEIGHT|SIZE)
    rect(0,0,2,height - (2 - 60)); // 2px borderwall on the Left
    rect(0,height - (2 + 60),width,2 + 60); // 2px borderwall on the Bottom, accounting for 60px UI space, VITAL to prevent Spawning in UI
    rect(width - 2,0,2,height); // 2px borderwall on the Right
    
    beings = new Being[popCount]; // NPC SPAWNING
    for (int i = 0; i < popCount; i++) // For each expected population count, create another array entry
        {
        beings[i] = new Being(); // In the beings[] array, create 'i' new entries
        beings[i].spawnBeing(); // Places the new array entry in the world utilizing the spawnBeing method from the Being class, defined around line 291
    }
    
    //Spawns 'i'zombies to start by setting beings 0, 1, 2, 3, etc... as infected. Infect method defined below around line 289
    for (int i = 0; i < popZomb; i++)
        {
        beings[i].infectBeing();
        pause = false; // Sets Pause to False so the simulation may begin in the Draw() loop
    }
}


void draw()
    {
    if (playerFocused == false) // Run this if user has not already focused the window once
    {
        pause = true; // Just in case, as long as the user has not clicked the window, simulation is considered "paused," though this shouldn't affect anything yet
        splashScreen();
    }
    else if (playerFocused == true && inMenu == false) { // Checks that no overlay screen is enabled befor drawing the simulation
        frameRate(amtFPS); // Draws amtFPS frames per second - can't be in Setup otherwise it only runs at setup

        fill(wall); noStroke(); // 2px BORDER WALL around entire game area
        rect(0,0,width,2);
        rect(0,0,2,height - (2 - 60));
        rect(0,height - (2 + 60),width,2 + 60);
        rect(width - 2,0,2,height);

        fill(wall); noStroke(); rect(0,height - 61,width,1);
        fill(empty); // These three lines create the black Empty space that draws underneath the UI and is required so the UI doesn't duplicate over itself.
        rect(0,height - 60,width,60); // Continually draws empty space under the UI bar

        if (pause == false) // If game is paused, do not run the main simulation. The main simulation is handled via the 'move()' Method
        {
            for (int i = 0; i < popCount; i++) // Move each being in the array in iterative sequence
            {beings[i].moveBeing();}
            clock++; // Increases turn counter
        }
        int numZombies = 0; int numDead = 0; // These set numZombies and numDead to zero so it can be recalculated below
        for (int j = 0;j < popCount;j++) // Checks each being
        {
            if (beings[j].type == iszombie) // If being is of type zombie, increase Zombie counter
            {numZombies++;}
            if (beings[j].type == isdead) // If being is of type dead, increase Dead counter
            {numDead++;}
        }
        // POPULATION STATUS TEXT UI
        fill(human); // HUMAN counter
        noStroke();
        textSize(14);
        textAlign(LEFT);
        String s1 = "Humans: " + (popCount - (numDead + numZombies)); // Counts Humans by subtracting Dead and Zombie counts
        text(s1,width - 400,height - 10); // Places text to the left
        fill(dead); // DEAD counter
        String s2 = "Dead: " + numDead;
        text(s2,width - 250,height - 10); // Places text to the center
        fill(zombie); // ZOMBIE counter
        String s3 = "Zombies: " + numZombies;
        text(s3,width - 125,height - 10); // Places text to the right
        fill(zombie); // Current max FPS
        String s4 = "FP[S]: " + amtFPS; if(amtFPS == 144){s4 = "FP[S]: <" + amtFPS;} else if(amtFPS == 10){s4 = "FP[S]: " + amtFPS + " >";}
        text(s4,10,height - 10);
        if (enableDecay == false) // Decay Toggle Indicator
        {
            fill(hit);
            String s8 = "[D]ecay: Off";
            text(s8,10,height - 25);
        }
          else if (enableDecay == true)
        {
            fill(hit);
            String s9 = "[D]ecay: On";
            text(s9,10,height - 25);
        }
        if (pause == true) // Adds UI element that appears only when Paused
        {
            fill(255);
            String s8 = "Paused";
            text(s8,10,height - 40);
        }
        // Debug buttonpress checks
        // if(mouseButton == LEFT){fill(150); String S1 = "LEFT Mouse"; text(S1,width/6,height/2.5); mouseButton = 0;}
        // if(mouseButton == RIGHT){fill(150); String S2 = "RIGHT Mouse"; text(S2,width/6,height/1.5); mouseButton = 0;}
        // if(keyPressed == true){fill(150); String S3 = "KEY PRESS RECOGNIZED"; text(S3,width/6,height/2);}
    } // End of Main Gameplay iteration
}

// CLICK FOR BOMBS
void mousePressed()
    {
    int mx = mouseX;  // X coord of where the mouse was clicked
    int my = mouseY;  // Y coord of where the mouse was clicked
    
    if (mousePressed && (playerFocused == false)) // If a mouse click is detected, make sure playerFocused is true and run setup
        {
        playerFocused = true; setup();
    }
    else if (inMenu == true)
{}
    else if ((inMenu == false) && (mouseButton == LEFT))
        {
        int radius = (int)random(10) + 6; // A circle of random radius, minimum 6 max 16 pixels
        fill(empty); // Fills the area with 'empty' space
        stroke(hit); // Sets thefill color of above 'empty' space (it's olive)
        ellipse(mx,my,radius * 2,radius * 2); // Mouse X coord minus the random radius for drawing origin X, Mouse Y coord minus random radius for drawing origin Y, radius times 2 for width and height
        for (int i = 0;i < popCount;i++) // If being is within radius of the mouse cursor, kill them - checking for each being in the array
            {
            int dx = beings[i].xpos - mx;
            int dy = beings[i].ypos - my;
            int diff = (dx * dx) + (dy * dy);
            if (diff < (radius * radius))
                {
                beings[i].die();
            }
        }
    }
    
    else if ((inMenu == false) && (mouseButton == RIGHT))
        {
        int radius = (int)random(16) + 16; // A circle of random radius, minimum 16 max 32 pixels
        fill(empty); // Fills the area with 'empty' space
        stroke(hit); // Sets the fill color of above 'empty' space (it's olive)
        ellipse(mx,my,radius * 2,radius * 2); // Mouse X coord minus the random radius for drawing origin X, Mouse Y coord minus random radius for drawing origin Y, radius times 2 for width and height
        for (int i = 0;i < popCount;i++)// If being is within radius of the mouse cursor, kill them - checking for each being in the array
            {
            int dx = beings[i].xpos - mx;
            int dy = beings[i].ypos - my;
            int diff = (dx * dx) + (dy * dy);
            if (diff < (radius * radius))
                {
                beings[i].die();
            }
        }
        
    }
    
}

// Global Variable Returns Integer for TYPE of target, used in target interactions - ie zombies eating walls, zombies infecting humans, or humans panicking
// int look() sets the integer values to be usedfor observing x and y coordinate of being[], direction facing, and distance to observed item
int look(int x, int y,int d,int dist)
    {
    for (int i = 0; i < dist; i++)
        {
        if (d == 1) { y--; } // direction 1, move down 1
        if (d == 2) { x++; } // direction 2, move right 1
        if (d == 3) { y++; } // direction 3, move up 1
        if (d == 4) { x--; } // direction 4, move left 1
        
        if (x > width - 1 || x < 1 || y > height - 30 || y < 1)
            { return 3; }
        else if (get(x,y) == wall)
            { return 3; }
        else if (get(x,y) == panichuman)
            { return 4; }
        else if (get(x,y) == human)
            { return 2; }
        else if (get(x,y) == zombie)
            { return 1; }
        else if (get(x,y) == dead)
            { return 0; }
    }
    return 0;
}


// HOTKEYS
void keyPressed()
    { 
    if ((inMenu == false) && (playerFocused == true)) { // Checks if player is in a menu before performing these game keypresses
        if ((key == 'd' || key == 'D') && enableDecay == false) //  Toggles Decay on/off - zombielife will not tick down, nor will Zombies die at 0.
            {enableDecay = true;}
        else if ((key == 'd' || key == 'D') && (enableDecay == true))
            {enableDecay = false;}
        
        if (key == 'R') // Full adjustable settings reset (these values are what I currently have the initialization settings as, sorry if they're different and I forgot to change these)
            {popZomb = 5;
            popCount = 1000 * ceil(((popMax - popMin) / 2) / 1000);
            // genSeed = (int)random(99999999); // Unused currently
            enableDecay = true;
            amtFPS = 45;
            setup();} // Resets variables and restarts
        
        if (key == '+' && popCount < popMax) // If key is +, increase pop up to population MAX
            {popCount += 1000; key = 'r';} // increase pop and sets "last pressed" key to the [r]eset key, which restarts sim
        
        if (key == '-' && popCount > popMin) // If key is -, decrease pop down to population MIN
            {popCount -= 1000; key = 'r';} // decrease pop and restart
        
        if (key == '[' && (popZomb > 1))  // If key is [ and starting zombie pop is greater than 1
            {popZomb -= 1; key = 'r';}  // decrease starting zombie pop by 1 then restart
        
        if (key == ']' && (popZomb < popCount)) // If key is ] and starting zombie pop is less than popCount (current spawn population)
            {popZomb += 1; key = 'r';}  // increase starting zombie pop by 1 and restart
        
        if (key == 's' && amtFPS > 10)
            {amtFPS--;}
        
        if (key == 'S' && amtFPS < 144)
            {amtFPS++;}
        
        if (key == ' ' && pause == false)
            {pause = true;}
        else if (key == ' ' && pause == true)
            {pause = false;}
        
        if (key == 'r') // Ifpressing lowercase r,
            {setup();}
    }
    if ((key == ESC) && (inMenu == false)) // If key is ESCAPE, toggle in and out of the Menu
        {key = 0; enterMenu();}
    else if ((key == ESC) && (inMenu == true))
        {key = 0; exitMenu();}
}

class Being
{
    int xpos, ypos, dir; // Defines position coordinates; dir is used to determine which way a Being is facing // (constrained to 1, 2, 3, or 4)
    int type, active; // type used for defining what the NPC is; active used to influence certain movement actions
    int belief, maxBelief; // belief is used for setting Panic duration
    int zombielife; // zombielife is used for tracking how long a Zombie has been alive, and killing it if Decay is enabled.
    int rest; // rest is used to influence certain movement actions
    
    Being()
        {
        dir = (int)random(1,5); // Random Direction, Forces integer on random result between 1 and 5, because (int) rounds down and random returns a float, 1-5 will result in 1 2 3 or 4
        type = ishuman;
        active = 0;
        belief = 500;
        maxBelief = 500;
        zombielife = 1300;
        rest = 40;
    }
    
    void die()
        { // Kills the Being by assigning them type 5 (dead) which is clarified below
        type = 5;
    }
    
    void spawnBeing()
        {
        for (int ok = 0; ok < 100; ok++)
            {
            xpos = (int)random(width - 1) + 1;
            ypos = (int)random(height - 30) + 1;
            if (get(xpos,ypos) == color(0,0,0)) { ok = 100; }
        }
    }
    
    void infectBeing(int x, int y)
        {
        if (x == xpos && y == ypos)
            {
            type = 1;
        }
    }
    
    void infectBeing()
        { type = 1; set(xpos, ypos, zombie);}
    
    void uninfectBeing()
        { // Unused, sets an NPC to a generic human
        type = ishuman;
        active = 0;
        zombielife = 1000;
        belief = 500;
    }
    
    void moveBeing()
        {
        if (type == 5) // sets the pixel thebeing inhabits to a dead pixel if they are assigned type 5 (dead)
            {
            set(xpos,ypos,dead);
        }
        else
            {
            int r = (int)random(3);
            if ((type == ishuman && active > 0) || r == 1)
                {
                set(xpos, ypos, color(0,0,0));
                
                if (belief <=  0)
                    {
                    active = 0;
                    maxBelief -= 100;
                    belief = 0;
                    rest = 0;
                }
                
                if (look(xpos,ypos,dir,1) ==  0) // if facing pixel is a dead being
                    {
                    if (dir ==  1) { ypos--; } // direction 1, move down 1
                    else if (dir == 2) { xpos++;} // direction 2, move right 1
                    else if (dir == 3) { ypos++;} // direction 3, move up 1
                    else if (dir == 4) { xpos--;} // direction 4, move left 1
                    /*if(belief>0)
                    {
                    belief--;
                }*/
                }
                else
                    {
                    dir = (int)random(1,5); // Returns random direction 1 2 3 or 4
                }
                
                if (type == 1)
                    { set(xpos, ypos, zombie); }
                else if (active > 0)
                    { set(xpos, ypos, panichuman); }
                else
                    { set(xpos, ypos, human); }
                if (active > 0) {active--;}
            }
            
            int target = look(xpos,ypos,dir,10); // Sets target to facing pixel
            
            if (type == 1)  // Moves Zombie NPCs (Type 1)
                {
                if (enableDecay == true) {zombielife--;} // Decreases life by 1 if Decay is enabled
                if (target == 2 || target == 4) { active = 10;} // if facing a human (Type 2) or panichuman (Type 4), sets Actv to 10
                else if (target == 3) // if facing a wall
                    {
                    if ((int)random(8) == 1) // 1/8th chance to destroy facing wall
                        {
                        if (dir == 1) { set(xpos,ypos - 1,empty); } // If facing down, place empty below
                        else if (dir == 2) { set(xpos + 1,ypos,empty); } // If facing right, place empty right
                        else if (dir == 3) { set(xpos,ypos + 1,empty); } // If facing up, place empty above
                        else if (dir == 4) { set(xpos - 1,ypos,empty); } // If facing left, place empty left
                        
                    }
                    if (look(xpos,ypos,dir,2) == iszombie) // if zombie sees zombie within 2 pixels...
                        {
                        dir = dir + 1; // turn counterclockwise 1 step (definitions 40 lines above)
                        if (dir > 4) dir = 1; // if direction is facing left, then face down
                    }
                    
                }
                
                else if (active == 0 && target != 1)
                    { 
                    if ((int)random(6)>4)
                        {
                        if ((int)random(2) == 0)
                            dir = dir + 1;
                        else
                            dir = dir - 1;
                        if (dir == 5)
                            dir = 1;
                        if (dir == 0)
                            dir = 4;
                    }
                    else
                        {
                        dir = dir;
                    }
                    
                }
                
                int victim = look(xpos,ypos,dir,1); // Sets vctm as current Zombie Pos and facing, adjacent (in front, aka 1 pixel)
                if (victim == 2 || victim == 4) // If the vctm is Human (Type 2) or Panicking Human (Type 4)
                    {
                    int ix = xpos; int iy = ypos;
                    if (dir ==  1) { iy--; }
                    if (dir ==  2) { ix++; }
                    if (dir ==  3) { iy++; }
                    if (dir ==  4) { ix--; }
                    for (int i = 0; i < popCount; i++)
                        {
                        beings[i].infectBeing(ix,iy);
                    }
                }
                if ((enableDecay == true) && (zombielife <= 0)) // KILLS THE ZOMBIE if life reaches 0 while Decay is enabled - The enabled check is just a redundancy, just in case
                    {
                    die(); // calls the die method that sets Zombie to a Dead being
                }
                
            } //^ end of Zombie movement
            else if (type == 2) // Moves Human NPCs (Type 2)
                {
                if (target == 1) // 1.1 FIRST - If Human is facing a Zombie, gain 10 Actv and reset 'rest'
                    {
                    maxBelief = 500;
                    belief = 500; // Belief 500 means a Human JUST saw a Zombie
                    active = 10; // Actv means
                    rest = 0;
                }
                if (target == 4) // 1.2 SECOND - If Human is facing a Panicking Human
                    {
                    active = 10; // Gain 10 Actv
                    if (belief > 0) // 2.1 FIRST count down belief if it's higher than 0
                        {
                        belief--;
                    }
                    else if (belief == 0 && maxBelief != 0 && rest >=  40) // 2.2a Otherwise SECOND reset belief and rest if belief is 0 and rest is over 40
                        {
                        belief = maxBelief;
                        rest = 0;
                    }
                    else if (belief == 0 && rest < 40) // 2.2b Otherwise SECOND increase rest if belief is 0 and rest is not yet 40
                        {
                        rest++;
                    }
                }
                else if (target != 1 && target != 4 && active == 0) // 1.3a otherwise THIRD - Increase rest if Human does not see Zombie or Panicking Human
                    {
                    rest++;
                }
                else if (target == 1) // 1.3b otherwise THIRD - If Human is facing a Zombie, turn in the opposite direction
                    {       
                    dir = dir + 2; if (dir > 4) { dir = dir - 4; }
                }
                if ((int)random(2) == 1) { dir = (int)random(1,5); } //v 1.4 FOURTH - 50% chance to turn and face a random direction regardless of previous directions (1 2 3 or 4)
            } //^ ^ end of Human movement
        }
    }
}

void splashScreen()
    {
    pause = true;
    PImage gameart = loadImage("GameArt.png");
    fill(wall); noStroke(); rect(0,0,width,height); // Sets splash screen background
    imageMode(CENTER);
    image(gameart, width / 2, height / 2,(width + height) / 3.5,(width + height) / 3.5);
    imageMode(CORNER);
    fill(255); textAlign(CENTER); // Sets Text properties
    String T1 = "Welcome to CocoZOMBIES v" + versNum;
    String T2 = "[ESC] will show you the controls";
    String T3 = "Please click within the window to continue";
    textSize(30); text(T1,width / 2,80);
    textSize(14); text(T2,width / 2,height - 75);
    textSize(30); text(T3,width / 2,height - 40);
}
void enterMenu()
    { // Pause Menu display (Escape key)
    pause = true;
    inMenu = true;
    loadPixels(); // Stores each rendered pixel into pixels[] (the Processing included array for pixel on the screen)
    fill(wall); noStroke(); rect(0,0,width,height); // Sets landing screen background
    fill(255); textSize(18); textAlign(CENTER); // Sets Text properties
    String menucontrol = "Press ESCAPE to continue";
    text(menucontrol,width / 2,(height / 2) + 100);
    String T1 = "Keybinds:";
    String T2 = "LMB / RMB ||  Place Small / Large bombs";
    String T3 = "s and S        ||  Decrea[s]e and increa[S]e simulation speed";
    String T4 = "Spacebar     ||  Pause";
    String T5 = "- and +         ||  Decrease and increase total population";
    String T6 = "[ and ]         ||  Decrease and increase starting Zombie population";
    String T7 = "d / D           ||  to Toggle if Zombies die eventually (Decay)";
    String T8 = "r / R            ||  [r]eset with current settings, or [R]eset all settings";
    String T9 = "[ESC] to close this menu and return to the Zom-pocalypse";
    PImage gameart = loadImage("GameArt.png");
    imageMode(CENTER);
    image(gameart, width / 2, height * 0.7,(width + height) / 5,(width + height) / 5);
    imageMode(CORNER);
    text(T1,(width/2),25); textAlign(LEFT);
    text(T2,(width/4),50);
    text(T3,(width/4),75);
    text(T4,(width/4),100);
    text(T5,(width/4),125);
    text(T6,(width/4),150);
    text(T7,(width/4),175);
    text(T8,(width/4),200);
    textSize(24); textAlign(CENTER);
    text(T9,(width/2),275);
       
    // for(int i = 0; 1>i<9; i++) // I'm trying to find a way to make iterative text to compress all these lines. I dunno.
    // {
    //   text(Ti,(width / 4),i * 25));
    // }
}
void exitMenu()
    { // When pressing Escape key in the pause menu
    updatePixels(); // Loads each stored pixel from pixels[] onto the screen
    inMenu = false;
    pause = false;
}