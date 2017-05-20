import static javax.swing.JOptionPane.*;
import static java.awt.event.KeyEvent.*;

int drawpile[][];
int sandpile[][];
int new_sandpile[][];
int heatpile[][];

int wide;
int high;
int cellSize = 5;


String helpString;

color c[];

boolean follow_mouse = false;
float genX;
float genY;

boolean always_sand = true;
int dropValue = 400000;
int startValue = 0;

boolean showHeat = false;
boolean invert = false;
int curPal = 0;
int maxPal = 10;
int white_scale = 50;

boolean doDelay = false;
int delay_ = 50;

boolean saveFile = false;
boolean loadFile = false;

int strokeSize = 0;
int defaultStroke = 20;

boolean renderEveryFrame = true;
int framesPerRender = 200;
int curFrame = 0;

void setup() {
  size(750, 750);
  wide = width / cellSize;
  high = height / cellSize;
  
  noSmooth();
  updateStroke();
  
  c = new color[4];
  sandpile = new int[wide][high];
  new_sandpile = new int[wide][high];
  drawpile = new int[wide][high];
  heatpile = new int[wide][high];
  for (int x = 0; x < wide; x++) {
    for (int y = 0; y < high; y++) {
      sandpile[x][y] = startValue;
      heatpile[x][y] = 0;
    }
  }
  genX = wide/2;
  genY = high/2;
  sandpile[wide/2][high/2] = dropValue;
  makePal(curPal);
  makeHelp();
  background(0);
}

void makeHelp() {
  helpString = "Q : Quit \n";
  helpString += "SPACE : start/stop sand \n";
  helpString += "+/- : change palate \n";
  helpString += ">/< : increase/decrease cell size (restarts) \n";
  helpString += "E : restart simulation \n";
  helpString += "I : invert palate \n";
  helpString += "F : flip palate \n";
  helpString += "D : randomize palate \n";
  helpString += "V : view every frame \n";
  helpString += "S : show grid \n";
  helpString += "M : mouse follow \n";
  helpString += "P : save screenshot \n";
  helpString += "W : wait (delay between frames) \n";
  helpString += "R : randomize generator location \n";
  helpString += "G : drop 1 grain of sand \n";
  helpString += "H : change to heat map view \n";
  helpString += "C : recenter generator \n";
  helpString += "F2 : save snapshot of current pile \n";
  helpString += "F3 : load snapshot of current pile \n";

  
}

void makePal(int pal) {
  switch(pal){
   case 0:
    c[0] = color(0,0,0);
    c[1] = color(0,0,255);
    c[2] = color(0,255,0);
    c[3] = color(255,0,0);
    break;
   case 1:
    c[0] = color(55,119,113);
    c[1] = color(76,224,179);
    c[2] = color(237,106,94);
    c[3] = color(255,142,114);
    break;
   case 2:
    c[0] = color(5,102,141);
    c[1] = color(2,128,144);
    c[2] = color(0,168,150);
    c[3] = color(2,195,154);
    break;
   case 3:
    c[0] = color(0);
    c[1] = color(80);
    c[2] = color(165);
    c[3] = color(255);
    break;
   case 4:
    c[0] = color(0, 0, 0);
    c[1] = color(85, 0, 0);
    c[2] = color(170, 0, 0);
    c[3] = color(255, 0, 0);
    break;
   case 5:
    c[0] = color(0, 0, 0);
    c[1] = color(0, 85, 0);
    c[2] = color(0, 170, 0);
    c[3] = color(0, 255, 0);
    break;
   case 6:
    c[0] = color(0, 0, 0);
    c[1] = color(0, 0, 85);
    c[2] = color(0, 0, 170);
    c[3] = color(0, 0, 255);
    break;
   case 7:
    c[0] = color(0, 21, 20);
    c[1] = color(107, 5, 4);
    c[2] = color(163, 50, 11);
    c[3] = color(245, 225, 179);
    break;
   case 8:
    c[0] = color(80, 81, 79);
    c[1] = color(36, 123, 160);
    c[2] = color(255, 224, 102);
    c[3] = color(242, 95, 92);
    break;
   case 9:
    c[0] = color(0, 0, 0);
    c[1] = color(20, 33, 61);
    c[2] = color(252, 163, 17);
    c[3] = color(229, 229, 229);
    break;
   case 10:
    c[0] = color(27, 231, 255);
    c[1] = color(110, 235, 131);
    c[2] = color(228, 255, 26);
    c[3] = color(232, 170, 20);
    break;
   default:
    break;
  }
   if (invert) {
     invertPal();
  }
}

void updateStroke(){
    if (strokeSize == 0) {
   noStroke(); 
  } else {
   stroke(strokeSize);
  }
}

void invertPal(){
    for (int j = 0; j<=3; j++) {
      c[j] = color(255-red(c[j]), 255-green(c[j]), 255-blue(c[j]));
    }
}



void draw() {
  
  curFrame++;

  if (follow_mouse) {
    genX = mouseX / cellSize;
    genY = mouseY / cellSize;
  }
  
  if (always_sand) {
    sandpile[int(genX)][int(genY)] = 12;
  }

  arrayCopy(sandpile, drawpile);
  arrayCopy(sandpile, new_sandpile);
  
  if (renderEveryFrame||curFrame >= framesPerRender) { 
    for (int x = 0; x < wide; x++) {
      for (int y = 0; y < high; y++) {
        int sand = drawpile[x][y];
        if (sand <= 3) {
          fill(c[sand]);
        } else {
          int a = sand * white_scale;
          fill(a,a,a);
        }
        if (showHeat) {
          float heatcol = float(heatpile[x][y]);
          float rcol = map(heatcol, 0, 1000, 0, 255);
          float gcol = map(heatcol, 0, 10000, 0, 255);
          float bcol = map(heatcol, 0, 100000,0 ,255);
          if (rcol > 255) { rcol = 255; }
          if (gcol > 255) { gcol = 255; }
          if (bcol > 255) { bcol = 255; }
          fill(rcol, gcol, bcol);
        }
        rect (x*cellSize, y*cellSize, cellSize, cellSize);
      }      
    }
  }
        
  for (int x = 0; x < wide; x++) {
    for (int y = 0; y < high; y++) {
      int sand2 = new_sandpile[x][y];      
      if (sand2 >= 4) {
        sandpile[x][y] = sand2 - 4;
        heatpile[x][y]++;
        if (x-1 >= 0) {
          sandpile[x-1][y]++;
        }
        if (x+1 < wide) {
          sandpile[x+1][y]++;
        }
        if (y-1 >= 0) {
          sandpile[x][y-1]++;
        }
        if (y+1 < high) {
          sandpile[x][y+1]++;
        }
      }
    }
  }
  if (doDelay) { delay(delay_); }
  curFrame %= framesPerRender;
}

void keyPressed(){
  // special keys
  if (key == CODED) {
    if (keyCode == VK_F1) { 
      showMessageDialog(null, helpString, "Sandpile", INFORMATION_MESSAGE);
    }
    if (keyCode == VK_F2) {
      saveFile = true;
      selectOutput("Save sandpile to file (.sdp)", "fileSelected");
    }
    if (keyCode == VK_F3) {
      loadFile = true;
      selectInput("Load sandpile (.sdp)", "fileSelected");
    }
  }
  // regular keys
  if (key==' ') {
    always_sand = !always_sand;
  }
  if (key=='R'||key=='r'){
    follow_mouse = false;
    genX = random(wide);
    genY = random(high);
  } if (key=='I'||key=='i'){
    invert = !invert;
    invertPal();
  }
  if (key=='M'||key=='m'){
    follow_mouse = !follow_mouse;
  }
  if (key=='G'||key=='g'){
    sandpile[int(genX)][int(genY)]++;
  }
  if (key=='P'||key=='p'){
    saveFrame("sandpile-######.png");
  }
  if (key=='<'||key==','){
    cellSize--;
    if (cellSize <= 0) { cellSize = 1; }
    setup();
  }
  if (key=='>'||key=='.'){
    cellSize++;
    setup();
  }
  if (key=='C'||key=='c'){
    follow_mouse = false;
    genX = wide/2;
    genY = high/2;  
  }
  if (key=='E'||key=='e'){
    setup();
  }
  if (key=='s'||key=='S'){
    strokeSize = (strokeSize == 0) ? defaultStroke : 0;
    updateStroke();
  }
  boolean palChanged = false;
  if (key=='='||key=='+'){
    curPal++;
    palChanged = true;
  }
  if (key=='Q'||key=='q'){
    exit(); 
  }
  if (key=='W'||key=='w'){
    doDelay = !doDelay;
  }
  if (key=='V'||key=='v'){
    renderEveryFrame = !renderEveryFrame;
  }
  if (key=='F'||key=='f'){
    color ctemp = c[0];
    c[0] = c[3];
    c[3] = ctemp;
    ctemp = c[1];
    c[1] = c[2];
    c[2] = ctemp;
  }
  if (key=='-'||key=='_'){
    curPal--;
    palChanged = true;
  }
  if (key=='D'|key=='d') {
    for (int j = 0; j<3; j++) {
      float nr = random(255);
      float ng = random(255);
      float nb = random(255);
      c[j] = color(nr, ng, nb);
    }
  }
  if (key=='H'|key=='h'){
    showHeat = !showHeat;
  }
  if (palChanged) {
    if(curPal < 0) {
      curPal = maxPal;
    }
    if (curPal > maxPal) {
      curPal = 0;
    }
    makePal(curPal);
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    // do nothing
  } else {
    if (saveFile) {
      saveFile = false;
      println("Saving: " + selection.getAbsolutePath());
      // save our file here
    } else if (loadFile) {
      loadFile = false;
       println("Loading: " + selection.getAbsolutePath());
       // load our file here
    } else {
      // something went wrong
    }
  }
}