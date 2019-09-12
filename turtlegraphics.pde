// Author: Maxwell Zane Miller, copyright 2017. All Rights Reserved.
// import(s)
import java.util.Stack;

// Global variable declarations

// Variables declared at the start of runtime
float initX = 0; // initial X position.
float initY = 0; // initial Y position.
float initAngle = 0; // initial angle heading.

// Variables declared from L-systems.txt file.
int n = 1; // number of times to apply Production rules to the original axiom.
String originalAxiom; // Original Axiom.
String ruleF; // Production rule for F
String ruleX; // Production rule for X
String ruleY; // Production rule for Y
float angleChange = 0; // how much the angle should change every + or - command.

// These are generally used in multiple functions for various things, updated every iteration.
float curX; // X position for current turtle state.
float curY; // Y position for current turtle state.
float curAngle = 0.0; // angle for current turtle state.

float prevMX; // x coord of midpoint of current line
float prevMY; // y coord of midpoint of current line
float nextMX; // x coord of midpoint of next line
float nextMY; // y coord of midpoint of next line
float cX; // x coord of center point for curve tangent to two straight lines.
float cY; // y coord of center point for curve tangent to two straight lines.
// For the case of the equilateral triangles for the dragon.txt problem (60* all angles) =>
float prevThet; // angle to current line's midpoint from centerPoint => , means curThet will always be (360 - 150*) (relative to base direction of triangle)
float nextThet; // angle to next line's midpoint from centerPoint , means nextThet will always be (360 - 30*) (relative to base direction of triangle)

boolean first = true;

// These will (both) almost always just be the step size, d.
float bbWidth; // boundry box width
float bbHeight; // boundry box height

float nextX; // X position for next turtle state.
float nextY; // Y position for next turtle state.
float nextAngle = 0; // angle for the next turtle state.
String curComm; // next command, first character in curString.
int pos = 0; // current position within String (same as # of iterations of draw() we're on).
boolean once = true; // boolean to control whether we have drawn the last line or not.
boolean lastLine = true; // boolean to control whether we have drawn the last line or not.
boolean mouseTime = false; // boolean to determine if it's time to proceed to origin selector.
boolean drawTime = true; // boolean that controls whether it's time to draw the picture or not.
boolean cEnabled = true; // boolean to control whether curvy grammar is allowed. (allows toggling c - true/false with 'c' or 'C' during runtime).

// Grab bezier points.
// first bezier curve
float b1x1, b1y1; // point 1 is first end point.
float b1x2, b1y2; // control point
float b1x3, b1y3; // control point
float b1x4, b1y4; // control point
// second bezier curve
float b2x1, b2y1; // point 1 is first end point.
float b2x2, b2y2; // control point
float b2x3, b2y3; // control point
float b2x4, b2y4; // control point

float[] arcCalc = new float[3];

float CCAngle = 0; // angle to move toward the next center of circle when curvy interpretation of grammar is active.

// Creation of LIFO stack variables.
// States are an array of floats, of length 3. state[0] = x position, state[1] = y position, state[2] = angle heading.
Stack<float[]> myStack = new Stack<float[]>(); // create a Stack of turtle states

// Creation of Post-Production Rule applications String:
String[] preProductionStr;
String[] producedStr;
String[] tempStr;
String postIterationStr = "";
String printTestStr = "";

// While not assigned from L-systems file, these variables are assigned at runtime by the user. system defaults are shown here:
float stepSize = 5; // step size for draw distance. Default amount given here: (Should be changed to whatever user inputs at runtime)
boolean c = false; // curvy line interpretation = true, straight line interpretation = false. toggle with 'c' or 'C' after starting a drawing!

// Booleans that control the I/O capabilities and functionality of this program.
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// If you want to skip all I/O, and run with program defaults or hard-coded, set io = false.
// If you want to skip the step size input, set io = false.
boolean io = true; // boolean to determine if we want to wait for io behavior, or to draw from defaults.
// If you want to skip choosing the starting point for the drawing with your mouse, set ioMouse = false.
boolean ioMouse = true; // boolean to determine if user needs to select origin with mouse.

String fName = "dragon.txt"; // assign name of .txt file to pull from, here. Hard-coded for ease.

// Now that we've taken care of that; let's get drawing!

// setup() function only runes once per execution of the program, and runs first, before draw() is called the first time.
void setup() {
  size(1200, 1000); // Set size of window
  frameRate(120);
  background(255, 255, 255);
  smooth();
  
  if (io == true) {
    drawTime = false;
  }
  
  initX = 300;
  initY = 500;
  
  // Parse the file, grab relevant information.
  readFile(fName);
  initAngle = 0; // Initial Angle always 0 degrees? I don't know if this is correct, but I will assume it is.
  curAngle = initAngle;
  
  if (io == true && drawTime == false) {
    background(0, 0, 0);
    text("Please press an Integer ranging from (1 to 9) for step size, d, so we can begin drawing.", 400, 300);
    if (ioMouse) {
      text("You will then be prompted to click a location on the screen as the origin for the drawing.", 400, 350);
    }
  }

     curX = initX;
     curY = initY;
  
}

// draw() function runs continuously after setup() finishes. draw() is basically a while(true) loop.
void draw() {
  // check whether stepSize has been (and if it even needs to be) provided by user.
  if ((io == true && drawTime == true) || io == false || (drawTime == true && ioMouse == true && mouseTime == false)) {
    
    // Read the String's next character for the next command to execute.
    if (pos < producedStr.length && once) {
      if (!(pos == producedStr.length - 1)) {
        curComm = producedStr[pos];
      }
      else {
        curComm = "";
      
        if (once) {
          curComm = producedStr[pos];
          System.out.println("Last Line Drawn.");
          once = false;
        }
      
      }
    
    }
  
    else { // Drawn our last line. Sit tight.
        curComm = "";
    }
      
    // Begin executing current command. 
    if (curComm.equals("F")) { // if next character is F,
      // grab new x,y coords for next turtle position (endpoint of line)
      getNewX();
      getNewY();
      nextMX = curX + ((stepSize/2) * (cos(radians(curAngle))));
      nextMY = curY + ((stepSize/2) * (sin(radians(curAngle))));

      // draw a line between the turtle's current state and what his next position will be
      if (c == false) {
        line(curX, curY, nextX, nextY);
      }
      
      else { // c == true => curvy line interpretation of grammar.
        if (first == true) {
          line(initX, initY, nextMX, nextMY);
          first = false;
        }
        
        else { // Not first line
          // Since equilateral triangles all have 60* angles, and same length sides... ->
          // Our ellipse Arc is really a circular Arc. so bbWidth = bbHeight !
          bbWidth = stepSize;
          bbHeight = stepSize;
          // cX and cY are the only real challenging part.
          // Fortunately for us, an equilateral triangle makes finding the center of the inscribed circle very easy!
          if (nextX > curX && nextY > curY) {
            cX = nextMX + ((stepSize/2) * cos(radians(curAngle + 90)));
            cY = nextMY + ((stepSize/2) * sin(radians(curAngle - 90)));
          }
          if (nextX > curX && nextY < curY) {
            cX = nextMX + ((stepSize/2) * cos(radians(curAngle + 90))); 
            cY = nextMY + ((stepSize/2) * sin(radians(curAngle + 90)));
          }
          if (nextX < curX && nextY > curY) {
            cX = nextMX + ((stepSize/2) * cos(radians(curAngle - 90))); 
            cY = nextMY + ((stepSize/2) * sin(radians(curAngle - 90)));
          }
          else {
            cX = nextMX + ((stepSize/2) * cos(radians(curAngle - 90))); 
            cY = nextMY + ((stepSize/2) * sin(radians(curAngle + 90)));  
          }
         
            prevThet = atan2((prevMY - cY),(prevMX - cX));
            
            nextThet = atan2((nextMY - cY),(nextMX - cX));

          // Well that didn't work out super great. Let's give Bezier a shot.
          
          // Since this dragon.txt grammar forms a fractal of equilateral triangles: we know that curves will be in the part of ((2 * PI) / 3) radians long, or 120*.
          // We can use points we calculated from our failed arc() attempt;
          // bezer() curves require 4 points. 2 fixed end points, and 2 "control points".
          // the control points are simply picked over the arc and help ensure it fits nicely.
          // Because we're using angles over 90* (PI/2), we'll try to use 2 Bezier curves to produce 1 (total) F movement for our turtle.
          
          // first bezier curve; start at midpoint of previous "line".
          b1x1 = prevMX;
          b1y1 = prevMY;
          
          float[] bcalc = new float[3];
          bcalc = calculateAngle(prevMX,prevMY,nextMX,nextMY,(stepSize));
          float angleDiff = bcalc[2];
          
          b1x2 = cX + ((stepSize/2) * (cos(prevThet + (angleDiff/6))));
          b1y2 = cY + ((stepSize/2) * (sin(prevThet + (angleDiff/6))));
          
          b1x3 = cX + ((stepSize/2) * (cos(prevThet + (1/3*angleDiff))));
          b1y3 = cY + ((stepSize/2) * (sin(prevThet + (1/3*angleDiff))));
          
          // assign end point
          b1x4 = cX + ((stepSize/2) * (cos(prevThet + (0.5*angleDiff))));
          b1y4 = cY + ((stepSize/2) * (sin(prevThet + (0.5*angleDiff))));
          
          bezier(b1x1, b1y1, b1x2, b1y2, b1x3, b1y3, b1x4, b1y4);
          
          // second bezier curve; start at midpoint of previous "line".
          b2x1 = b1x4;
          b2y1 = b1y4;
          
          b2x2 = cX + ((stepSize/2) * (cos(prevThet + (2*angleDiff/3))));
          b2y2 = cY + ((stepSize/2) * (sin(prevThet + (2*angleDiff/3))));
          
          b2x3 = cX + ((stepSize/2) * (cos(prevThet + (5/6*angleDiff))));
          b2y3 = cY + ((stepSize/2) * (sin(prevThet + (5/6*angleDiff))));
          
          // asign end point
          b2x4 = nextMX;
          b2y4 = nextMY;
          
          bezier(b2x1, b2y1, b2x2, b2y2, b2x3, b2y3, b2x4, b2y4);
          
        } // end curve
        
      }
      
      // assign the next position to the position for the next loop iteration
      curX = nextX;
      curY = nextY;
      prevMX = nextMX;
      prevMY = nextMY;
    
    } // end Forward

    if (curComm.equals("+")) { // if next character is +,
      nextAngle = curAngle + angleChange; // increment angle
      curAngle = nextAngle; // set the angle for next iteration to the incremented value
    } // end rotate CW
  
    if (curComm.equals("-")) { // if next character is -,
      nextAngle = curAngle - angleChange; // decrement angle
      curAngle = nextAngle; // set the angle for next iteration to the decremented value
    } // end rotate CCW
  
    if (curComm.equals("[")) { // if next character is [,
      // create temporary variables to store current turtle state before pushing
      float tmpX;
      tmpX = curX;
      float tmpY;
      tmpY = curY;
      float tmpA;
      tmpA = curAngle;
      // create temporary turtle state to push onto Stack.
      float[] pushState = new float[3];
      pushState[0] = tmpX;
      pushState[1] = tmpY;
      pushState[2] = tmpA;
      // push current state onto the stack
      myStack.push(pushState);
    
    } // end push()
  
    if (curComm.equals("]")) { // if next character is ],
      // create temporary array to hold turtle state after pop
      float[] popState = new float[3];
      // pop off the state on top of the LIFO stack
      popState = myStack.pop();
      // assign next state to be the popped state.
      nextX = popState[0];
      nextY = popState[1];
      nextAngle = popState[2];
      curX = nextX;
      curY = nextY;
      curAngle = nextAngle;

    } // end pop()
  
    // Advance through the String
    if (pos < producedStr.length - 1) {
      pos = pos + 1;
    }
  
  }
  
} // end draw()

float[] calculateAngle(float p1x,float p1y,float p2x,float p2y, float radius) {
  float temp = 0;
  float[] temp2 = new float[3]; // temp2[0] = midpointX, [1] = midpointY, [2] = angle.
  float vectorCalc = 0;
  
  vectorCalc = sqrt(((p1x-p2x)*(p1x-p2x))+((p1y-p2y)*(p1y-p2y)));
  
  temp = (((2 * radius * radius) - (vectorCalc*vectorCalc)) / (2 * radius * radius));
  
  float midpointX = (p1x + p2x)/2;
  float midpointY = (p1y + p2y)/2;
  
  temp2[0] = midpointX;
  temp2[1] = midpointY;
  temp2[2] = acos(temp);
  
  return temp2;
}

// readFile() function reads the file, parses it by lines, assigns appropriate variables.
void readFile(String fileName) {
  
  String[] lines = loadStrings(fileName);

  n = Integer.parseInt(lines[0]); // assign number of production rule applications. (line 1:)
  angleChange = Float.parseFloat(lines[1]); // assign angle increment in degrees. (line 2:)
  originalAxiom = lines[2]; // assign original axiom. (line 3:)
  ruleF = lines[3]; // assign production rule for F. (line 4:)
  ruleX = lines[4]; // assign production rule for X. (line 5:)
  ruleY = lines[5]; // assign production rule for Y. (line 6:)
  
  preProductionStr = originalAxiom.split("");
  postIterationStr = originalAxiom;
  
  for (int i = 0; i < n; i++) { // start of production rule application loop
    tempStr = postIterationStr.split("");
            
    for (int j = 0; j < tempStr.length; j++) {
      if (tempStr[j].equals("F") && (ruleF != null) && (!ruleF.contains("nil"))) {
        tempStr[j] = ruleF;
      }
                
      if (tempStr[j].equals("X") && (ruleX != null) && (!ruleX.contains("nil"))) {
        tempStr[j] = ruleX;
      }
                
      if (tempStr[j].equals("Y") && (ruleY != null) && (!ruleY.contains("nil"))) {
        tempStr[j] = ruleY;
      }
                
    }
            
    StringBuilder s1 = new StringBuilder();
    StringBuilder s2 = new StringBuilder();
    for (int k = 0; k < tempStr.length; k++) {
      s2.append("(");
      s2.append(tempStr[k]);
      s2.append(")");
      s1.append(tempStr[k]);     
    }

    postIterationStr = s1.toString();
    printTestStr = s2.toString();
            
  } // end of production rule application loop
  
  producedStr = postIterationStr.split("");
  // System.out.println("ProducedString: " + printTestStr);
  
}

// Calculates the X position of the turtle's next state.
void getNewX() {
  nextX = curX + (stepSize * (cos(radians(curAngle))));
}

// Calculates the Y position of the turtle's next state.
void getNewY() {
  nextY = curY + (stepSize * (sin(radians(curAngle))));
}

// keyPressed() override
// I only allow stepsizes ranging from 1 to 9
void keyPressed() {
  // Drawing, or capable of drawing.
  if (cEnabled == true) {
    if (key == 'c' || key == 'C') {
      if (c == false) {

        c = true; // swap to curvey line interpritation.
      }
      else {
       c = false; // swap to straight line interpritation.
      }
    }
  }
  
  if (drawTime == false) {
    if (key == '1' || key == '1') {
      stepSize = 1;
      drawTime = true;
    }
    if (key == '2' || key == '2') {
      stepSize = 2;
      drawTime = true;
    }
    if (key == '3' || key == '3') {
      stepSize = 3;
      drawTime = true;
    }
    if (key == '4' || key == '4') {
      stepSize = 4;
      drawTime = true;
    }
    if (key == '5' || key == '5') {
      stepSize = 5;
      drawTime = true;
    }
    if (key == '6' || key == '6') {
      stepSize = 6;
      drawTime = true;
    }
    if (key == '7' || key == '7') {
      stepSize = 7;
      drawTime = true;
    }
    if (key == '8' || key == '8') {
      stepSize = 8;
      drawTime = true;
    }
    if (key == '9' || key == '9') {
      stepSize = 9;
      drawTime = true;
    }
    
    if (drawTime == true) {
      if (ioMouse == true) {
        drawTime = false;
        background(0, 0, 0);
        text("Please choose the origin of the drawing, by clicking on the canvas with a mouse button.", 400, 350);
        mouseTime = true;
      }
      else {
        background(255, 255, 255);
      }
    }
    
  }
}

// mousePressed() override
void mousePressed() {
  if (ioMouse == true && mouseTime == true) {
    initX = mouseX;
    initY = mouseY;
    curX = mouseX;
    curY = mouseY;
    mouseTime = false;
    background(255, 255, 255);
    drawTime = true;
  }
}
