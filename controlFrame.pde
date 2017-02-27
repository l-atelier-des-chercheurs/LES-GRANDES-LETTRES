
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
      
    cp5.addSlider("brightnessThreshold")
      .plugTo(parent, "brightnessThreshold")
      .setPosition(20, 60)
      .setSize(200, 30)
      .setRange(0, 100)
      .setValue(80)
      ;

          
    cp5.addToggle("showCamera")
       .plugTo(parent, "showCamera")
       .setPosition(20, 120)
       .setSize(20, 20)
       .setValue(false)
       ;

    cp5.addToggle("showBlobDetection")
       .plugTo(parent, "showBlobDetection")
       .setPosition(20, 180)
       .setSize(20, 20)
       .setValue(false)
       ;

    cp5.addButton("startOver")
       .plugTo(parent, "startOver")
       .setPosition(20, 20)
       .setSize(100, 20)
       ;

    cp5.addButton("exportSVG")
       .plugTo(parent, "exportSVG")
       .setPosition(width-120, height-40)
       .setSize(100, 20)
       ;

}


  void draw() {
    background(0);
  }
}