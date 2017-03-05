void exportAnimation() {

  float enCours = 1 - ((float) exportingAnimation / (float) exportingAnimationMaxTime);

  // au fur et à mesure, enCours va de 0 à 1

  if(enCours > .5) {
    background(0);
  }

  fill(exportRectangleColor);
  rect(-width + (enCours*2*width), 0, width, height);

  if(exportingAnimation <= 0) {
    startOver();
    setEpaisseurBoitier = defaultEpaisseurThickness;
  }
}