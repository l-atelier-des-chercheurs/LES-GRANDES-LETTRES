
// ==================================================
// drawBlobsAndEdges()
// ==================================================
PVector getBrightestBlobCenter()
{
  Blob b;
  EdgeVertex eA, eB;
  
  float brightestBlobValue = 0;
  int brightestBlobIdx = -1;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    float blobBright = getBlobBrightness(n);
    if(blobBright > brightestBlobValue) {
      brightestBlobIdx = n;
    }
  }
  
  if(brightestBlobIdx == -1) {
    return new PVector(0,0);
  } else {
    return getBlobCenter(brightestBlobIdx);
  }
  
}

float getBlobBrightness(int n) {
 
  Blob b;
  EdgeVertex eA, eB;
  
  b=theBlobDetection.getBlob(n);
  if (b == null) {
    return 0;
  }
  
  float brightness = 0;
  
  for (int m=0; m<b.getEdgeNb(); m++)
  {
    eA = b.getEdgeVertexA(m);
    eB = b.getEdgeVertexB(m);
    if (eA !=null && eB !=null)
      //line(
      //  eA.x*width, eA.y*height, 
      //  eB.x*width, eB.y*height
      //  );
      
      brightness++;
  }
  
  return brightness;
}

PVector getBlobCenter(int n) {
  Blob b=theBlobDetection.getBlob(n);
  return new PVector(b.xMin*width + (b.w*width/2), b.yMin*height + (b.h*height/2)); 
}