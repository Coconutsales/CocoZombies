// Zombie Infection Simulation >> CocoZombies Version 1.3 <<

// Kevan Davis, 16/8/03 < The original dev

// Modified by John Gilbertson 25/09/03 < The work I, Coconutsales, am basing CocoZombies off of
//  just making zombies more dangerous, edited level creation code, increased max zombies, made zombies less likely to group etc...

// Modified by Coconutsales January 2025
//   adding various things, see README or Github >> https://github.com/Coconutsales/CocoZombies <<


boolean pause; // Used to pause simulation, and prevent movement or being actions while false. Set true at end of setup. Previously 'freeze'
int popMax = 20000; // Maximum Population
int popMin = 1000; // Minimum Population
int popCount = 1000 * ceil(((popMax - popMin) / 2) / 1000); // Set population between popMax and popMin. Rounds up to nearest 1000 !!!Full [R]eset Variable!!!
int popZomb = 5; // Starting number of zombies to spawn !!!Full [R]eset Variable!!!
int speed = 1; // Speed of humans / zombies
int panic = 5; // Speed of panichuman

// COLORS
int zombie = color(0,255,0); // Zombies are Green
int human = color(200,0,200); // Humans are Pink
int panichuman = color(255,120,255); // Panicking Humans are Light Pink
int dead = color(128,30,30); // Dead beings are Burgundy
int wall = color(50,50,60); // Walls are Grey, Blocks Humans, destroyed by Zombies or player (mouse interaction)
int empty = color(0,0,0); // Empty space is Black
int hit = color(100,75,50); // Explosion craters are Brown (Originally 128,128,0 ; olive)

int clock = 0; // Game starts at 0, count increases with each simulation turn
int iszombie = 1; // Definition for counting if being is a zombie
int ishuman = 2; // Definition for counting if being is a human
int ispanichuman = 4; // Definition for counting if being is panicking
int isdead = 5; // Definition for counting if being is dead
int amtFPS = 45; // Used to increase or decrease FPS with keypresses. Basically increase or decrease simulation speed. !!!Full [R]eset Variable!!!
boolean enableDecay = true; //Can zombies die of old age (decay)? !!!Full [R]eset Variable!!!

Being[] beings;

void setup() 
{ 
    PFont f = loadFont("Univers65.vlw"); // Sets font f to the vlw file named, stored in \data\fontname.vlw
    textFont(f,12); // Sets text to use Font 'f' at size 12
    int x,y; 
    size(600,600);  // Size of the simulation window
    clock = 0;
    
    // PATHWAY GENERATION (uses "empty" strokes)
    background(wall); // sets the whole image to be Wall colored. All shapes are later drawn over this.
    fill(wall); // Sets the fill for upcoming rectangle generation
    stroke(empty); // Sets the outline for upcoming rectangle generation, empty to make pathways
    for (int i = 0; i < 100; i++) // For 100 iterations, create a randomly placed and randomly sized rectangle size constrained to 1/4th the width/height of the screen
        {
        rect((int)random(width) - (width / 8),(int)random(height) - (height / 8),(int)random(width / 4),(int)random(height / 4)); // rect(xpos, ypos, xwidth, yheight)
    }
    // EMPTY SPACE GENERATION (Using empty stroke and fill)
    fill(empty);
    stroke(empty);
    for (int i = 0; i < (width / 4); i++) // Adds black empty squares, up to 1/4th the sketch Width
        {
        rect((int)random(width - 1) + 1,(int)random(height - 1) + 1,(int)random(40) + 10,(int)random(40) + 10); 
        
        x = (int)random(width - 1) + 1;
        y = (int)random(height - 1) + 1;
    }
    
    fill(wall);
    noStroke();
    rect(0,height - 30,width,height);
    fill(empty);
    stroke(wall);
    rect(0,height - 30,width - 2,height - 2);
    
    beings = new Being[popCount]; // NPC SPAWNING 
    for (int i = 0; i < popCount; i++) // For each expected population count, create another array entry
        {
        beings[i] = new Being();
        beings[i].position(); 
    }
    
    //Spawns 'i'zombies to start by setting beings 0, 1, 2, 3, etc... as infected. Infect method defined below around line 289
    for (int i = 0; i < popZomb; i++) 
        {
        beings[i].infect();
        pause = false;
    }
} 


void draw() 
    { 
    
    fill(wall);
    noStroke();
    rect(0,height - 30,width,height);
    fill(empty);
    stroke(wall);
    rect(0,height - 30,width - 2,height - 2);  
    if (pause == false)
        {
        for (int i = 0; i < popCount; i++) // Move each being in the array in iterative sequence
            {beings[i].move();}
        frameRate(amtFPS); // Draws amtFPS frames per second
        clock++;
    }
    int numZombies = 0;
    int numDead = 0;
    
    for (int j = 0;j < popCount;j++)
        {
        if (beings[j].type == iszombie) // If being is of type zombie, increase Zombie counter
            {numZombies++;}
        if (beings[j].type == isdead) // If being is of type dead, increase Dead counter
            {numDead++;}
    }
    // POPULATION STATUS TEXT UI
    fill(human);
    noStroke();
    String s1 = "Humans: " + (popCount - (numDead + numZombies));
    text(s1,width - 400,height - 10); // Places text to the left
    
    fill(dead);
    String s2 = "Dead: " + numDead;
    text(s2,width - 250,height - 10); // Places text to the center
    
    fill(zombie);
    String s3 = "Zombies: " + numZombies;
    text(s3,width - 125,height - 10); // Places text to the right
    
    if (enableDecay == false)
        {
        fill(hit);
        String s4 = "Decay: Off";
        text(s4,10,width - 10);
    }
    else if (enableDecay == true)
        {
        fill(hit);
        String s5 = "Decay: On";
        text(s5,10,width - 10);
    }
    
}

// CLICK FOR BOMBS
void mousePressed()
    {
    int mx = mouseX;  // X coord of where the mouse was clicked
    int my = mouseY;  // Y coord of where the mouse was clicked
    
    if (mouseButton == LEFT) 
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
    
    if (mouseButton == RIGHT) 
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

// Integer for TYPE of target, used in target interactions - ie zombies eating walls, zombies infecting humans, or humans panicking
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
    if ((key == 'd' || key == 'D') && enableDecay == false) //  Toggles Decay on/off - zombielife will not tick down, nor will Zombies die at 0.
        {     enableDecay = true;   } 
    else if ((key == 'd' || key == 'D') && enableDecay == true)
        {     enableDecay = false;    }
    
    if (key == 'R') // Full adjustable settings reset (these values are what I currently have the initialization settings as, sorry if they're different and I forgot to change these)
        {    popZomb = 5; popCount = 1000 * ceil(((popMax - popMin) / 2) / 1000); enableDecay = true; amtFPS = 45; setup();} // Resets variables and restarts
    
    if (key == '+' && popCount < popMax) // If key is +, increase pop up to population MAX
        {     popCount += 1000; key = 'r';  } // increase pop and sets "last pressed" key to the [r]eset key, which restarts sim
    
    if (key == '-' && popCount > popMin) // If key is -, decrease pop down to population MIN
        {     popCount -= 1000; key = 'r';  } // decrease pop and restart
    
    if (key == '[' && (popZomb > 1))  // If key is [ and starting zombie pop is greater than 1
        {     popZomb -= 1; key = 'r';   }  // decrease starting zombie pop by 1 then restart
    
    if (key == ']' && (popZomb < popCount)) // If key is ] and starting zombie pop is less than popCount (current spawn population)
        {     popZomb += 1; key = 'r';   }  // increase starting zombie pop by 1 and restart
    
    if (key == 's' && amtFPS > 1)
        {     amtFPS--; }
    
    if (key == 'S' && amtFPS < 144)
        {     amtFPS++; }
    
    if (key == ' ' && pause == false) 
        {     pause = true;     }
    else if (key == ' ' && pause == true) 
        {     pause = false;     }
    
    if (key == 'r') // If pressing lowercase r,
        {   setup();   }
}

class Being
{ 
    int xpos, ypos, dir;
    int type, active;
    int belief, maxBelief;
    int zombielife;
    int rest;
    
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
    
    void position()
        {
        for (int ok = 0; ok < 100; ok++)
            {
            xpos = (int)random(width - 1) + 1; 
            ypos = (int)random(height - 30) + 1;
            if (get(xpos,ypos) == color(0,0,0)) { ok = 100; }
        }
    }
    
    void infect(int x, int y)
        {
        if (x == xpos && y == ypos)
            { 
            type = 1; 
        }
    }
    
    void infect()
        { type = 1; set(xpos, ypos, zombie); }
    
    void uninfect()
        { 
        type = ishuman; 
        active = 0;    
        zombielife = 1000;
        belief = 500;
    }
    
    void move()
        {
        if (type == 5) // sets the pixel the being inhabits to a dead pixel if they are assigned type 5 (dead)
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
                    else if (dir == 2) { xpos++; } // direction 2, move right 1
                    else if (dir == 3) { ypos++; } // direction 3, move up 1
                    else if (dir == 4) { xpos--; } // direction 4, move left 1
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
            
            if (type == 1)  // IF a ZOMBIE (type 1)
                {
                if (enableDecay == true) {zombielife--;} // Decreases life by 1 if Decay is enabled
                if (target == 2 || target == 4) { active = 10;} // if facing a human (2) or panichuman (4)
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
                
                int victim = look(xpos,ypos,dir,1);
                if (victim == 2 || victim == 4)
                    {
                    int ix = xpos; int iy = ypos;
                    if (dir ==  1) { iy--; }
                    if (dir ==  2) { ix++; }
                    if (dir ==  3) { iy++; }
                    if (dir ==  4) { ix--; }
                    for (int i = 0; i < popCount; i++)
                        { 
                        beings[i].infect(ix,iy); 
                    }
                }  
                if ((enableDecay == true) && (zombielife <= 0)) // KILLS THE ZOMBIE if life reaches 0 while Decay is enabled - The enabled check is just a redundancy, just in case
                    {
                    die(); // calls the die method that sets Zombie to a Dead being
                }
                
            }
            else if (type == 2)
                {
                if (target == 1)
                    {
                    maxBelief = 500;
                    belief = 500;
                    active = 10;
                    rest = 0;
                }
                if (target == 4)
                    { 
                    active = 10;
                    if (belief > 0)
                        {
                        belief--;
                    }
                    else if (belief == 0 && maxBelief != 0 && rest >=  40)
                        {
                        belief = maxBelief;
                        rest = 0;
                    }
                    else if (belief == 0 && rest < 40)
                        {
                        rest++;
                    }
                }
                else if (target != 1 && target != 4 && active == 0)
                    {
                    rest++;
                }
                else if (target == 1)
                    {       
                    dir = dir + 2; if (dir > 4) { dir = dir - 4; } 
                }
                if ((int)random(2) == 1) { dir = (int)random(1,5); } // Returns random direction 1 2 3 or 4
            }
        }
    }
}
