// - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
// - BlobDetection library

import processing.video.*;
import blobDetection.*;
import controlP5.*;
import java.util.List;
import processing.svg.PGraphicsSVG;

ControlP5 cp5;

Capture cam;
BlobDetection theBlobDetection;


PImage img;
boolean newFrame=false;
float brightnessThreshold = 80;

PGraphics canvas;

ArrayList<PVector> lineCoords = new ArrayList();


// ==================================================
// setup()
// ==================================================
void setup()
{

  size(640, 480);
  canvas = createGraphics(640, 480);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
    }
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  cp5 = new ControlP5(this);

  cp5.addSlider("brightnessThreshold")
    .setPosition(100, 50)
    .setRange(0, 100)
    ;

  // BlobDetection
  // img which will be sent to detection (a smaller copy of the cam frame);
  img = new PImage(80, 60); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(true);
}

// ==================================================
// captureEvent()
// ==================================================
void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}

// ==================================================
// draw()
// ==================================================
void draw()
{
  if (newFrame)
  {

    background(0);

    theBlobDetection.setThreshold(brightnessThreshold/100); // will detect bright areas whose luminosity > 0.2f;
    newFrame=false;
    //image(cam,0,0,width,height);
    img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
    fastblur(img, 2);

    if (mousePressed)
      image(img, 0, 0, cam.width/6, cam.height/6);

    theBlobDetection.computeBlobs(img.pixels);
    //drawBlobsAndEdges(true, true);

    PVector brightestBlobCenter = getBrightestBlobCenter();

    strokeWeight(1);
    stroke(255, 0, 0);
    point(brightestBlobCenter.x, brightestBlobCenter.y);

    //recordCoordinates(brightestBlobCenter.x, brightestBlobCenter.y);
    recordCoordinates(mouseX, mouseY);

    drawCoordinates();

    if (keyPressed) {
      beginRecord(SVG, "export.svg");
      endRecord();
    }
  }
}

void recordCoordinates(float x, float y) {
  lineCoords.add(new PVector(x, y));
}

void drawCoordinates() {
  background(255);

  for (int i=2; i<lineCoords.size(); i++) {

    // créer un vecteur partant de coord2, 
    // ayant la même magnitude, et à 90 degrés
    PVector ninety = getNinetyAtPoint(i);
    PVector mninety = getMNinetyAtPoint(i);

    PVector ninety2 = getNinetyAtPoint(i-1);
    PVector mninety2 = getMNinetyAtPoint(i-1);

    stroke(0, 0, 255);
    beginShape();
    vertex(  ninety2.x, ninety2.y);
    vertex(  ninety.x, ninety.y);
    vertex( mninety.x, mninety.y);      
    vertex( mninety2.x, mninety2.y);      
    endShape();

    PVector coord1 = lineCoords.get(i-1);
    PVector coord2 = lineCoords.get(i);

    stroke(255, 0, 0);
    //line(coord1.x, coord1.y, coord2.x, coord2.y);
  }  
  endShape();
}
  
PVector getNinetyAtPoint(int i) {
  PVector coord1 = lineCoords.get(i-1);
  PVector coord2 = lineCoords.get(i);
  PVector diff = PVector.sub(coord1, coord2);

  PVector ninety = PVector.fromAngle(diff.heading() - PI/2);
  ninety
    .normalize()
    .setMag( diff.mag())
    .add(coord2)
    ;
  return ninety;
}

PVector getMNinetyAtPoint(int i) {
  PVector coord1 = lineCoords.get(i-1);
  PVector coord2 = lineCoords.get(i);
  PVector diff = PVector.sub(coord1, coord2);

  PVector mninety = PVector.fromAngle(diff.heading() + PI/2);
  mninety
    .normalize()
    .setMag( diff.mag())
    .add(coord2)
    ;
  return mninety;
}