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

import java.util.*;
import processing.svg.PGraphicsSVG;

ControlFrame cf;

Capture cam;
BlobDetection theBlobDetection;

boolean recordSVG = false;
boolean isDebug = false;

PImage img;
boolean newFrame=false;
// set default in controlFrame.pde
float brightnessThreshold;
boolean showCamera, showBlobDetection;
int easeTraces;

String currentMode = "mouse";
PGraphics canvas;
int setEpaisseurBoitier = 0;
int defaultEpaisseurThickness = 5;

String[] modesAvailable = {"mouse"};
ArrayList<PVector> lineCoords = new ArrayList();

PVector pointToTrace = new PVector(0, 0);
PVector currentPointPosition = new PVector(0, 0);

String setExportSuffix = "";

// for animation when exporting is done
int exportingAnimationMaxTime = 50;
int exportingAnimation = 0;
color[] exportAnimationColors = { color(27, 47, 129), color(75, 192, 180), color(255, 190, 50), color(255, 62, 81) };
color exportRectangleColor;

// function necessary for controlFrame
void settings() {
  size(1200, 800);
}

void setup()
{
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println("camera at i: " + i + cameras[i]);
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

    modesAvailable = append(modesAvailable, "camera");
  }

  cf = new ControlFrame(this, 480, 640, "Controls");
  canvas = createGraphics(640, 480);
}

// ==================================================
// draw()
// ==================================================
void draw()
{

  if (exportingAnimation > 0) {
    exportingAnimation--;
    println("export animation: " + exportingAnimation);
    exportAnimation();
  } else {
    background(0);

    // check if the coordinate is empty
    if (pointToTrace.mag() == 0) {

      recordCoordinates(currentPointPosition);
      currentPointPosition = new PVector(0, 0);
    } else if (PVector.dist(pointToTrace, currentPointPosition) > 1) {
      println("New point detected. Number of points in path : " + lineCoords.size());

      if (currentPointPosition.mag() == 0) {
        currentPointPosition = pointToTrace.copy();
      }

      currentPointPosition.lerp(pointToTrace, (easeTraces)/100.0f);    
      // show it, record it
      recordCoordinates(currentPointPosition);
    }

    drawCoordinates();
    
    if(recordSVG) {
      recordSVG = false;
      exportShapeSVG();
    }
  }
}

void recordCoordinates(PVector newVector) {
  lineCoords.add(newVector.copy());
}

void drawCoordinates() {

  ArrayList<PVector>[] lines = new ArrayList[20];
  int idx = 0;
  lines[idx] = new ArrayList();
  boolean newLineCreated = true;

  for (int i=0; i<lineCoords.size(); i++) {  
    if (lineCoords.get(i).mag() == 0) {
      if (!newLineCreated && idx < 20) {
        idx++;
        lines[idx] = new ArrayList();
        newLineCreated = true;
      }
    } else {
      lines[idx].add(lineCoords.get(i));
      newLineCreated = false;
    }
  }

  if (idx == 0 && lines[idx].isEmpty()) {
    return;
  }

  for (int index=idx; index>=0; index--) {

    if (lines[index].isEmpty())
      continue;

    PVector[] listOfPoints = new PVector[lines[index].size()];
    listOfPoints = lines[index].toArray(listOfPoints);

    // dessiner le trait gauche
    noStroke();
    fill(255);
    strokeWeight(0);

    if (isDebug) {
      stroke(255, 0, 0);
      noFill();
      strokeWeight(2);
    } 

    beginShape();
    for (int i=2; i<listOfPoints.length; i++) {    
      PVector ninety = getNinetyAtPoint(listOfPoints, i);
      PVector ninety2 = getNinetyAtPoint(listOfPoints, i-1);
      vertex(  ninety.x, ninety.y);
    }
    for (int i=listOfPoints.length-1; i>2; i--) {    
      PVector mninety = getMNinetyAtPoint(listOfPoints, i);
      PVector mninety2 = getMNinetyAtPoint(listOfPoints, i-1);
      vertex( mninety.x, mninety.y);      
      //vertex( mninety2.x, mninety2.y);
    }
    endShape(CLOSE);

    stroke(255, 0, 0);
    noFill();
    strokeWeight(0);
    if (isDebug) {
      strokeWeight(2);
    }

    beginShape();
    for (int i=0; i<listOfPoints.length; i++) {    
      PVector coord = listOfPoints[i];
      //vertex(coord.x, coord.y);

      stroke(0, 0, 255);
      point(coord.x, coord.y);

      //print("-- i: " + i + " and x:" + coord.x);
    }
    endShape();

    stroke(255, 255, 0);
    noFill();

    if (isDebug) {
      point(currentPointPosition.x, currentPointPosition.y);
      point(pointToTrace.x, pointToTrace.y);
    }
  }
}

PVector getNinetyAtPoint(PVector[] listOfPoints, int i) {
  PVector coord1 = listOfPoints[i-1];
  PVector coord2 = listOfPoints[i];
  PVector diff = PVector.sub(coord1, coord2);

  PVector ninety = PVector.fromAngle(diff.heading() - PI/2);
  ninety
    .normalize()
    .setMag(diff.mag() + 5 + setEpaisseurBoitier)
    .limit(30 + setEpaisseurBoitier)
    .add(coord2)
    ;
  return ninety;
}

PVector getMNinetyAtPoint(PVector[] listOfPoints, int i) {
  PVector coord1 = listOfPoints[i-1];
  PVector coord2 = listOfPoints[i];
  PVector diff = PVector.sub(coord1, coord2);

  PVector mninety = PVector.fromAngle(diff.heading() + PI/2);
  mninety
    .normalize()
    .setMag(diff.mag() + 5 + setEpaisseurBoitier)
    .limit(30 + setEpaisseurBoitier)
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
  println("EXPORT SVG");
  recordSVG = true;
}

void exportShapeSVG() {
  println("exportShapeSVG");
  DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd_HH_mm_ss");
  java.util.Date d = new java.util.Date();
  String dateFichier = formatter.format(d);
  String nomFichier = dateFichier + "_" + setExportSuffix + ".svg";

  println("Check point");
  
  beginRecord(SVG, "exports/" + nomFichier);
  background(0);
  fill(255);
  drawCoordinates();
  endRecord();
  
  println("Export SVG done. Now animating");
  exportingAnimation = exportingAnimationMaxTime;
  exportRectangleColor = exportAnimationColors[int(random(exportAnimationColors.length))];
}


void mouseDragged() {
  if (currentMode == "mouse") {
    pointToTrace = new PVector(mouseX, mouseY);
  }
}
void mouseReleased() {
  pointToTrace = new PVector(0, 0);
}


void keyReleased() {
  //println("key : " + key + " keyCode : " + keyCode);

  // dodoc box, blue arrow left
  if (key == 'w') {
    // reduce stroke weight
    setEpaisseurBoitier = setEpaisseurBoitier <= 0 ? 0 : (setEpaisseurBoitier - 2);
    // dodoc box, blue arrow right
  } else if (key == 's') {
    setEpaisseurBoitier = setEpaisseurBoitier >= 20 ? 20 : (setEpaisseurBoitier + 2);
    // dodoc box, green button
  } else if (key == 'a') {
    recordSVG = true;
  } else if(key==' '){
    startOver();
  } else {
    setExportSuffix = key + "";
  }  

  println("setEpaisseurBoitier ? " + setEpaisseurBoitier);
}