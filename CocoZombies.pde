// Zombie Infection Simulation
// Kevan Davis, 16/8/03
// Modified by John Gilbertson 25/09/03
// Modified by Coconutsales January 2025
// just making zombies more dangerous, edited level creation code, increased max zombies, made zombies less likely to group etc...

int freeze; // Used for ???
// int num=4000; // Starting population
int popMax=20000; // Maximum Population
int popMin=1000; // Minimum Population
int popCount=1000*ceil(((popMax-popMin)/2)/1000); // Currently set population to simulate between popMax and popMin. Rounds up to nearest 1000 to prevent odd population counts
//int popCount=((popMax-popMin)/2); // OLD population calculation, had issues ending up higher than max or lower than min
int popZomb=5; // Starting number of zombies to spawn
int speed=1; // Speed of humans / zombies
int panic=5; // Speed of panichuman
int human; // Main NPC
int panichuman; // Panicked NPC
int zombie; // Undead
int dead; // Re-dead or dead human if ya bomb em
int wall; // impassable by human, edible by zombie
int empty; // the black background
int clock=0; // Game starts at 0 time
int hit; // Used for ??? Just the stroke color of bomb craters?
int ishuman=2; // Definition for counting if being is a human
int ispanichuman=4; // Definition for counting if being is panicking
int iszombie=1; // Definition for counting if being is a zombie
int isdead=5; // Definition for counting if being is dead
boolean enableDecay=false; // Can zombies die of old age (decay)?

Being[] beings;

void setup() 
{ 
  PFont f=loadFont("Univers65.vlw"); // Sets font f to the vlw file named, stored in \data\fontname.vlw
  frameRate(45); // Draws 45 frames per second
  textFont(f,19); // Sets the font (named f) to size 19
  
// COLOR DEFINITIONS
  int x,y; 
  size(1000,1000);  // Size of the simulation window
  human=color(200,0,200); // Humans are pink
  panichuman=color(255,120,255); // Panicking Humans are light pink
  zombie=color(0,255,0); // Zombies are green
  wall=color(50,50,60); // Walls are grey
  empty=color(0,0,0); // empty space is black
  dead=color(128,30,30); // Dead beings are burgundy
  hit=color(128,128,0); // Explosion craters are olive
  clock=0;
//  noBackground(); This is useless and does nothing - noBackground isn't even a real function

// PATHWAY GENERATION (uses "empty" strokes)
  background(wall); // As far as I can tell, the two lines below can be summarized with this one line -cc
//  fill(wall);
//  rect(0,0,width,height); 
  fill(wall); // Sets the fill for upcoming rectangle generation
  stroke(empty); // Sets the outline for upcoming rectangle generation, empty to make pathways
  for (int i=0; i<100; i++) // For 100 iterations, do the following:
  {
      rect((int)random(width)-(width/8), (int)random(height)-(height/8),(int)random(width/4), (int)random(height/4)); 
  }
// EMPTY SPACE GENERATION (Using empty stroke and fill)
  fill(empty);
  stroke(empty);
  for (int i=0; i<(width/4); i++) // Adds black empty squares, up to 1/4th the sketch Width
  {
    rect((int)random(width-1)+1, (int)random(height-1)+1, (int)random(40)+10,(int)random(40)+10); 

    x=(int)random(width-1)+1;
    y=(int)random(height-1)+1;
  }

/*  fill(wall);
  stroke(wall);
  rect(190,0,20,200);
  rect(0,90,400,20);*/


// NPC SPAWNING
  fill(wall);
  noStroke();
  rect(0,height-30,width,height);
  fill(empty);
  stroke(wall);
  rect(0,height-30,width-2,height-2);
  beings = new Being[popCount];        
  for(int i=0; i<popCount; i++) // For each expected population count, create another array entry
  { beings[i] = new Being(); beings[i].position(); }

  // Spawns 'i' zombies to start by setting beings 0, 1, 2, 3, etc... as infected. Infect method defined below around ln236
  for(int i=0; i<popZomb; i++) 
  {
  beings[i].infect();
  freeze=0;
  }
} 
 

void draw() 
{ 
  if (freeze==0)
  {
//    background(empty); // no clue what this does, it's commented out already
    fill(wall);
    noStroke();
    rect(0,height-30,width,height);
    fill(empty);
    stroke(wall);
    rect(0,height-30,width-2,height-2);  
    
    for(int i=0; i<popCount; i++) // Move each being in the array in iterative sequence
    { 
      beings[i].move(); 
    } 
/*    if (speed==2) { delay(20); }
    else if (speed==3) { delay(50); }
    else if (speed==4) { delay(100); }*/
    clock++;
    int numZombies=0;
    int numDead=0;
        
    for(int j=0;j<popCount;j++)
    {
      if(beings[j].type==iszombie) // If being is made a zombie, increase zombie counter ???
      {
        numZombies++;
      }
      if(beings[j].type==isdead) // If being is made dead, increase dead counter ???
      {
        numDead++;
      }
    }
// POPULATION STATUS TEXT UI
    fill(human);
    noStroke();
    String s="Humans:" + (popCount-(numDead+numZombies));
    text(s,width/10,height-10); // Places text to the left
    
    fill(dead);
    String s3="Dead: " + numDead;
    text(s3,width/2.5,height-10); // Places text to the center
    
    fill(zombie);
    String s2="Zombies: " + numZombies;
    text(s2,width/1.5,height-10); // Places text to the right
    

  }
}

// CLICK FOR BOMBS
void mousePressed()
{
  int mx=mouseX;  // X coord of where the mouse was clicked
  int my=mouseY;  // Y coord of where the mouse was clicked
  int radius=(int)random(10)+6; // A circle of random radius, minimum 6 max 16 pixels
  fill(empty); // Fills the area with 'empty' space
  stroke(hit); // Sets the fill color of above 'empty' space (it's olive)
  ellipse(mx,my,radius*2,radius*2); // Mouse X coord minus the random radius for drawing origin X, Mouse Y coord minus random radius for drawing origin Y, radius times 2 for width and height
  for(int i=0;i<popCount;i++) // If being is within radius of the mouse cursor, kill them - checking for each being in the array
  {
    int dx=beings[i].xpos-mx;
    int dy=beings[i].ypos-my;
    int diff=(dx*dx)+(dy*dy);
    if(diff<(radius*radius))
    {
      beings[i].die();
    }
  }
}

// Integer for TYPE of target, used in target interactions - ie zombies eating walls, zombies infecting humans, or humans panicking
int look(int x, int y,int d,int dist)
{
  for(int i=0; i<dist; i++)
  {
    if (d==1) { y--; }
    if (d==2) { x++; }
    if (d==3) { y++; }
    if (d==4) { x--; }

    if (x>width-1 || x<1 || y>height-30 || y<1)
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
  if(key == ' ') // If last pressed key is blank. . .
  {
    key='r'; // set last pressed key to R
  } 

  if(key == '+' && popCount < popMax)  // If key is +, increase pop up to population MAX
  { 
    popCount += 1000; key='r'; // increase pop then sets "last pressed" key to the [r]eset key, which restarts sim
  }

  if(key == '-' && popCount > popMin) // If key is -, decrease pop down to population MIN
  { 
    popCount -= 1000; key='r'; // decrease pop then sets "last pressed" key to the [r]eset key, which restarts sim
  }

  if(key == '[' && (popZomb > 1) ) // If key is [ and starting zombie pop is greater than 1
  { 
    popZomb -= 1; key='r'; // decrease starting zombie pop by 1 then sets "last pressed" key to the reset key, which [r]estarts sim
  }

  if(key == ']' && (popZomb < popCount) ) // If key is ] and starting zombie pop is less than popCount (current spawn population)
  { 
    popZomb += 1; key='r'; // increase starting zombie pop by 1 then sets "last pressed" key to the reset key, which [r]estarts sim
  }

  if((key == 'd' || key =='D') && enableDecay==false) 
  { 
    enableDecay=true; 
  } 
    else 
    {
      enableDecay=false;
    }
  

  if(key == 'r' || key == 'R') // If pressing uppercase or lowercase R,
  {
    freeze=1; // Pause the simulation and restart
    setup(); 
  }
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
    dir = (int)random(4)+1;
    type = ishuman;
    active = 0;
    belief=500;
    maxBelief=500;
    zombielife=1300;
    rest=40;
  }

  void die() 
  { // Kills the Being by assigning them type 5 (dead) which is clarified below
    type=5;
  }

  void position()
  {
    for (int ok=0; ok<100; ok++)
    {
      xpos = (int)random(width-1)+1; 
      ypos = (int)random(height-30)+1;
      if (get(xpos,ypos)==color(0,0,0)) { ok = 100; }
    }
  }

  void infect(int x, int y)
  {
    if (x==xpos && y==ypos)
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
    zombielife=1000;
    belief=500;
  }

  void move()
  {
    if(type==5) // sets the pixel the being inhabits to a dead pixel if they are assigned type 5 (dead)
    {
      set(xpos,ypos,dead);
    }
    else
    {
      int r = (int)random(3);
      if ((type==ishuman && active>0) || r==1)
      {
        set(xpos, ypos, color(0,0,0));
        
        if(belief<=0)
        {
          active=0;
          maxBelief-=100;
          belief=0;
          rest=0;
        }
            
        if (look(xpos,ypos,dir,1)==0)
        {
          if (dir==1) { ypos--; }
          else if (dir==2) { xpos++; }
          else if (dir==3) { ypos++; }
          else if (dir==4) { xpos--; }
/*          if(belief>0)
          {
            belief--;
          }*/
        }
        else
        {
          dir = (int)random(4)+1; 
        }

        if (type == 1)
        { set(xpos, ypos, zombie); }
        else if (active > 0)
        { set(xpos, ypos, panichuman); }
        else
        { set(xpos, ypos, human); }
        if (active>0) {active--;}
      }

      int target = look(xpos,ypos,dir,10); // Sets target to facing pixel

      if (type==1)  // IF a ZOMBIE (type 1)
      {
        zombielife--; // Decreases zombielife by 1
        if (target==2 || target==4) { active = 10;} // if facing a 
        else if (target==3)
        {
          if((int)random(8)==1)
          {
            if (dir==1) { set(xpos,ypos-1,empty); } // If facing down, place empty below
            else if (dir==2) { set(xpos+1,ypos,empty); } // If facing right, place empty right
            else if (dir==3) { set(xpos,ypos+1,empty); } // If facing up, place empty above
            else if (dir==4) { set(xpos-1,ypos,empty); } // If facing left, place empty left

          }
          if(look(xpos,ypos,dir,2)==iszombie)
          {
            dir=dir+1;
            if(dir>4) dir=1;
          }
        
        }

        else if (active==0 && target!=1) 
        { 
          if((int)random(6)>4)
          {
            if((int)random(2)==0)
              dir = dir+1;
            else
              dir = dir-1;
            if(dir==5)
              dir=1;
            if(dir==0)
              dir=4;
          }
          else
          {
            dir=dir;
          }
       
        }
 
        int victim = look(xpos,ypos,dir,1);
        if (victim == 2 || victim==4)
        {
          int ix = xpos; int iy = ypos;
          if (dir==1) { iy--; }
          if (dir==2) { ix++; }
          if (dir==3) { iy++; }
          if (dir==4) { ix--; }
          for(int i=0; i<popCount; i++)
          { 
            beings[i].infect(ix,iy); 
          }
        }  
        if((enableDecay==true) && (zombielife<=0)) // KILLS THE ZOMBIE if zombielife reaches 0 granted Decay is on
        {
          die(); // calls the die method that sets 
        }

      }
      else if (type==2)
      {
        if (target==1)
        {
          maxBelief=500;
          belief=500;
          active=10;
          rest=0;
        }
        if(target==4)
        { 
          active=10;
          if(belief>0)
          {
            belief--;
          }
          else if(belief==0 && maxBelief!=0 && rest>=40)
          {
            belief=maxBelief;
            rest=0;
          }
          else if(belief==0 && rest<40)
          {
            rest++;
          }
        }
        else if(target!=1 && target!=4 && active==0)
        {
          rest++;
        }
        else if (target==1)
        {       
          dir = dir + 2; if (dir>4) { dir = dir - 4; } 
        }
        if ((int)random(2)==1) { dir = (int)random(4)+1; }
      }
    }
  }
}
