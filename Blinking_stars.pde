/*
    Copyright (C) 2023 - All Rights Reserved

    Content written by:
    - Discord: Voidrunner#3600
    - E-Mail: Voidrunner42@gmail.com


    Unauthorized copying of this file using any medium is strictly prohibited.
    The content of this file is strictly proprietary and confidential.

    Distribution of this file or it's content will therefore be an unlawful act,
    and legal actions may be taken as a result.
*/

/*
        // UML DIAGRAM //

      +--------------------------------------------------------------------------------+
      |     setup()                                                                    |
      +--------------------------------------------------------------------------------+
      | - stars: ArrayList<BlinkingStar>                                               |
      | - shootingStars: ArrayList<ShootingStar>                                       |
      | - numStars: int                                                                |
      | - angle: float                                                                 |
      +--------------------------------------------------------------------------------+
      | + draw()                                                                       |
      | + setGradient(int x, int y, float w, float h, color c1, color c2, String axis) |
      | + mouseClicked()                                                               |
      +--------------------------------------------------------------------------------+

             |
             |
             V

     +--------------------------------+              +----------------------+
     |  BlinkingStar                  |              |  ShootingStar        |
     +--------------------------------+              +----------------------+
     | - loc: PVector                 |              | - loc: PVector       |
     | - size: PVector                |              | - size: PVector      |
     | - lifespan: float              |              | - lifespan: float    |
     | - lifespanChange:float         |              | - rotation: float    |
     | - rotation: float              |              | - rotationSpeed:float|
     | - rotationSpeed:float          |              +----------------------+
     +--------------------------------+
     | + BlinkingStar()               |
     | + BlinkingStar(PVector tempLoc)|
     | + update()                     |
     | + render()                     |
     | + isDead()                     |
     +--------------------------------+


*/

ArrayList<BlinkingStar> stars; // array list of stars
ArrayList<ShootingStar> shootingStars; // array list of shooting stars
int numStars = 50; // number of stars
float angle = 0; // rotation angle of the stars

void setup() {
  size(600, 400); // set the size of the window
  background(0); // first time setup black background
  stars = new ArrayList<BlinkingStar>(); // initialize the array list
  for (int i = 0; i < numStars; i++) {
    stars.add(new BlinkingStar(new PVector(random(width), random(height)))); // add stars to the array list
  }
  shootingStars = new ArrayList<ShootingStar>(); // initialize the array list for shooting stars
}

void draw() { 
  setGradient(0, 0, width, height, color(0, 0, 30), color(0, 0, 10), "Y_AXIS"); // draw the background gradient


  translate(width/2, height/2); // move the origin to the center of the screen
  rotate(angle); // rotate the stars
  translate(-width/2, -height/2); // move the origin back to the top left corner of the screen


  for (int i = 0; i < stars.size(); i++) {
    BlinkingStar s = stars.get(i);
    s.update();
    s.render();
    if (s.isDead()) {
      stars.set(i, new BlinkingStar(new PVector(random(width), random(height))));
    }
  }

  // Draw the shooting stars if they exist and remove the dead ones from the array list
  for (int i = 0; i < shootingStars.size(); i++) {
    ShootingStar s = shootingStars.get(i);
    s.update();
    s.render();
    if (s.isDead()) { // if the shooting star is dead remove it from the array list
      shootingStars.remove(i);
    }
  }

  // Increment the rotation angle by a small amount to make the stars rotate (do better if time... And dont code stuff like this...)
  angle += 0.01;
}

void setGradient(int x, int y, float w, float h, color c1, color c2, String axis ) {
  noFill();
  if (axis == "Y_AXIS") {  // Top to bottom gradient (doesnt work fix if time... (lerp color sucks))
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter); // lerpColor() is a p5 function that interpolates between two colors
      stroke(c);
      line(x, i, x+w, i);
    }
  }
}

void mouseClicked() {
  // Create a new shooting star at the mouse position with a random velocity and size and add it to the array list of shooting stars
  shootingStars.add(new ShootingStar(new PVector(mouseX, mouseY), PVector.random2D().mult(random(5, 10)), random(100, 200)));
}

class BlinkingStar {
  PVector loc; // added variable for location of the star
  PVector size; // added variable for size of the star
  float lifespan; // added variable for the lifespan of the star
  float lifespanChange;  // added variable for the change in lifespan of the star
  float rotation; // added variable for rotation of the star in radians
  float rotationSpeed; // added variable for rotation speed of the star in radians

  BlinkingStar() { 
    this(new PVector(0, 0)); // call the other constructor with a default location of (0, 0) (i hate object orianted languages... constructors are so stupid and uneffective...)
  }

  BlinkingStar(PVector tempLoc) {
    loc = tempLoc;
    size = new PVector(random(2, 4), random(2, 4)); 
    lifespan = random(100, 200); // initialize lifespan randomly between 100 and 200
    lifespanChange = random(1, 3); // initialize lifespan change randomly between 1 and 3
    rotation = random(TWO_PI); // initialize rotation randomly between 0 and 2*PI
    rotationSpeed = random(0.01, 0.05); // initialize rotation speed randomly between 0.01 and 0.05
  }

  void update() { // update the star
    lifespan -= lifespanChange;
    rotation += rotationSpeed; // rotate the star by the rotation speed
  }


  void render() { // draw the star
    pushMatrix(); // save the current transformation matrix
    translate(loc.x, loc.y); // move to the location of the star
    rotate(rotation); // apply the rotation
    noStroke();
    fill(255, lifespan); // make the star fade over time
    float radius = map(lifespan, 0, 200, 1, size.x); // make the star shrink over time
    ellipse(0, 0, radius, radius); // draw the star centered at (0, 0)
    popMatrix(); // restore the previous transformation matrix
    if (lifespan <= 50 && random(1) < 0.005) { // if the star is about to die, create a shooting star with 5% probability
      shootingStars.add(new ShootingStar(loc, size, rotation)); // add a new shooting star to the array list
    }
  }

  boolean isDead() {
    return lifespan <= 0;
  }
}

class ShootingStar { // added class for shooting stars
  PVector loc; // added variable for location of the star
  PVector size; // added variable for size of the star
  float lifespan; // added variable for the lifespan of the star
  PVector velocity; // added variable for the velocity of the star
  float rotation; // added variable for rotation of the star in radians
  PVector prevLoc; // added variable to keep track of previous location

  ShootingStar(PVector tempLoc, PVector tempSize, float tempRotation) {
    loc = tempLoc; 
    size = tempSize; 
    lifespan = random(100, 200); // initialize lifespan randomly between 100 and 200
    velocity = PVector.random2D().mult(random(5, 10)); // initialize velocity randomly between 5 and 10
    rotation = tempRotation; 
    prevLoc = loc.copy(); // initialize the previous location to the current location
  }

  void update() { // update the star
    prevLoc.set(loc); // update the previous location before changing the current location
    loc.add(velocity); // update the current location by adding the velocity
    lifespan--;
  }

  void render() {
    pushMatrix(); 
    translate(loc.x, loc.y);
    rotate(rotation);
    noStroke();
    fill(255, lifespan);
    ellipse(0, 0, size.x, size.y);
    popMatrix();

    // Draw a line from the previous position to the current position
    stroke(255, lifespan);
    strokeWeight(size.x / 2); // set the stroke weight to half the width of the ellipse
    line(prevLoc.x, prevLoc.y, loc.x, loc.y);
  }

  boolean isDead() { // return true if the star is dead
    return lifespan <= 0;
  }
}
