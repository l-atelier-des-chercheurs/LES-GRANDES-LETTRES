// Baton magique
// program written for a workshop with children aged 6-8
// to draw letters with a torch and upload them to a laser cutter
// l’atelier des chercheurs - https://latelier-des-chercheurs.fr/
// - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
// - BlobDetection library

import processing.video.*;
import blobDetection.*;

import controlP5.*;

import java.text.*;

import java.util.List;
import processing.svg.PGraphicsSVG;

ControlFrame cf;

Capture cam;
BlobDetection theBlobDetection;

boolean recordSVG = false;

PImage img;
boolean newFrame=false;
// set default in controlFrame.pde
float brightnessThreshold;
boolean showCamera, showBlobDetection;

PGraphics canvas;

ArrayList<PVector> lineCoords = new ArrayList();

// function necessary for controlFrame
void settings() {
  size(1200, 800);
}

void setup()
{
  cf = new ControlFrame(this, 640, 480, "Controls");
  canvas = createGraphics(640, 480);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
    }
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();

    // BlobDetection
    // img which will be sent to detection (a smaller copy of the cam frame);
    img = new PImage(192, 108); 
    theBlobDetection = new BlobDetection(img.width, img.height);
    theBlobDetection.setPosDiscrimination(true);
  }
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

    theBlobDetection.computeBlobs(img.pixels);

    PVector brightestBlobCenter = getBrightestBlobCenter();

    if (mousePressed) {
      recordCoordinates(mouseX, mouseY);
    }
    //recordCoordinates(brightestBlobCenter.x, brightestBlobCenter.y);

    drawCoordinates();

    if (recordSVG) {
      recordSVG = false;
      exportShapeSVG();
    }


    if (showCamera) {
      image(img, 0, 0, img.width, img.height);
    }

    if (showBlobDetection) {
      drawBlobsAndEdges(true, true);
    }

    strokeWeight(1);
    stroke(255, 0, 0);
    point(brightestBlobCenter.x, brightestBlobCenter.y);
  }
}

void recordCoordinates(float x, float y) {
  lineCoords.add(new PVector(x, y));
}

void drawCoordinates() {

  // dessiner le trait gauche
  noStroke();
  fill(255);
  beginShape();
  for (int i=3; i<lineCoords.size(); i++) {    
    PVector ninety = getNinetyAtPoint(i);
    PVector ninety2 = getNinetyAtPoint(i-1);
    curveVertex(  ninety.x, ninety.y);      
    //vertex( ninety2.x, ninety2.y);
  }
  for (int i=lineCoords.size()-1; i>3; i--) {    
    PVector mninety = getMNinetyAtPoint(i);
    PVector mninety2 = getMNinetyAtPoint(i-1);
    curveVertex( mninety.x, mninety.y);      
    //vertex( mninety2.x, mninety2.y);
  }
  endShape(CLOSE);
}

PVector getNinetyAtPoint(int i) {
  PVector coord1 = lineCoords.get(i-1);
  PVector coord2 = lineCoords.get(i);
  PVector diff = PVector.sub(coord1, coord2);

  PVector ninety = PVector.fromAngle(diff.heading() - PI/2);
  ninety
    .normalize()
    .setMag( diff.mag()/2 + 2)
    //.setMag( 5)
    .limit(15)
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
    .setMag( diff.mag()/2 + 2)
    //.setMag( 5)
    .limit(15)
    .add(coord2)
    ;
  return mninety;
}


void captureEvent(Capture cam)
{
  cam.read();
  newFrame = true;
}

public void startOver() {
  lineCoords.clear();
}
public void exportSVG() {
  recordSVG = true;
}

void exportShapeSVG() {
  DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd_HH_mm_ss");
  java.util.Date d = new java.util.Date();
  String dateFichier = formatter.format(d);
  String nomFichier = dateFichier + ".svg";

  beginRecord(SVG, "exports/" + nomFichier);
  background(0);
  fill(255);
  drawCoordinates();
  endRecord();
}