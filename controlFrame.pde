
class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);

    cp5.addSlider("Brightness Threshold")
      .plugTo(parent, "brightnessThreshold")
      .setPosition(20, 50)
      .setSize(250, 30)
      .setRange(0, 50)
      .setValue(80)
      ;

    cp5.addSlider("Easing")
      .plugTo(parent, "easeTraces")
      .setPosition(20, 90)
      .setSize(250, 30)
      .setRange(0, 100)
      .setValue(40)
      ;

    cp5.addSlider("Thickness")
      .plugTo(parent, "setEpaisseurBoitier")
      .setPosition(20, 130)
      .setSize(250, 30)
      .setRange(0, 30)
      .setValue(defaultEpaisseurThickness)
      ;

    List l = Arrays.asList(modesAvailable);
    /* add a ScrollableList, by default it behaves like a DropdownList */
    cp5.addScrollableList("dropdown")
      .setPosition(20, 190)
      .setSize(200, 100)
      .setBarHeight(20)
      .setItemHeight(20)
      .addItems(l)
      .setType(ScrollableList.DROPDOWN) // currently supported DROPDOWN and LIST
      ;

    cp5.addToggle("Show Camera")
      .plugTo(parent, "showCamera")
      .setPosition(width/2, 190)
      .setSize(20, 20)
      .setValue(false)
      ;

    cp5.addToggle("Show Blob Detection")
      .plugTo(parent, "showBlobDetection")
      .setPosition(width/2, 230)
      .setSize(20, 20)
      .setValue(false)
      ;

    cp5.addToggle("Debug")
      .plugTo(parent, "isDebug")
      .setPosition(width - 80, 20)
      .setSize(20, 20)
      .setValue(false)
      ;

    cp5.addButton("Start Over")
      .plugTo(parent, "startOver")
      .setPosition(20, 20)
      .setSize(100, 20)
      ;

    cp5.addButton("Export to SVG")
      .plugTo(parent, "exportSVG")
      .setPosition(width-120, height-40)
      .setSize(100, 20)
      ;

    background(0);
  }


  void draw() {
    noStroke();
    fill(21);
    rect(0, 0, width, height/2);
    fill(41);
    rect(0, height/2 - 10, width, 20);
    
    textAlign(CENTER, CENTER);
    fill(255);
    text("Drawing an " + setExportSuffix, width/2, height/2);

    if (currentMode == "camera" && newFrame) {
      println("Got new camera frame");

      fill(21);
      rect(0, height/2 + 10, width, height/2);

      theBlobDetection.setThreshold(brightnessThreshold/100); // will detect bright areas whose luminosity > brightnessThreshold;
      newFrame = false;

      img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);
      fastblur(img, 2);

      PImage flipped = createImage(img.width, img.height, RGB);//create a new image with the same dimensions
      for (int i = 0; i < flipped.pixels.length; i++) {       //loop through each pixel
        int srcX = i % flipped.width;                        //calculate source(original) x position
        int dstX = flipped.width-srcX-1;                     //calculate destination(flipped) x position = (maximum-x-1)
        int y    = i / flipped.width;                        //calculate y coordinate
        flipped.pixels[y*flipped.width+dstX] = img.pixels[i];//write the destination(x flipped) pixel based on the current pixel
      }    
      img = flipped;
      
      theBlobDetection.computeBlobs(img.pixels);      
      PVector brightestBlobCenter = getBrightestBlobCenter();

      if (brightestBlobCenter.mag() > 0) {
        println("Found a bright point at x=" + pointToTrace.x + " y=" + pointToTrace.y);
      } else {
        println("No lights detected");
      }

      pointToTrace = brightestBlobCenter.copy();

      pushMatrix();
      translate(30, height/2 + 30);

      if (showCamera) {
        image(img, 0, 0);
      }

      if (showBlobDetection) {
        drawBlobsAndEdges(true, true);
      }

      strokeWeight(1);
      stroke(255, 0, 0);
      point(pointToTrace.x, pointToTrace.y);

      popMatrix();
    }
  }
  void dropdown(int n) {
    /* request the selected item based on index n */
    currentMode = cp5.get(ScrollableList.class, "dropdown").getItem(n).get("name").toString();
  }

  void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges) {


    noFill();
    Blob b;
    EdgeVertex eA, eB;
    for (int n=0; n<theBlobDetection.getBlobNb(); n++)
    {
      b=theBlobDetection.getBlob(n);
      if (b!=null)
      {
        // Edges
        if (drawEdges)
        {
          strokeWeight(3);
          stroke(0, 255, 0);
          for (int m=0; m<b.getEdgeNb(); m++)
          {
            eA = b.getEdgeVertexA(m);
            eB = b.getEdgeVertexB(m);
            if (eA !=null && eB !=null)
              line(
                eA.x*img.width, eA.y*img.height, 
                eB.x*img.width, eB.y*img.height
                );
          }
        }

        // Blobs
        if (drawBlobs)
        {
          strokeWeight(1);
          stroke(255, 0, 0);
          rect(
            b.xMin*img.width, b.yMin*img.height, 
            b.w*img.width, b.h*img.height
            );
        }
      }
    }
  }
}