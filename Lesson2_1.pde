import processing.video.*;

Capture cam;
color targetColor = color(0,0,0,0);
color circleColor = color(0, 255, 0);

ArrayList<Blob> blobs = new ArrayList<Blob>();
int blobPointDistance = 50;

// Homework: puppet show images, based on the Load and Display Image example
// https://processing.org/examples/loaddisplayimage.html
// The image files go in the sketch's data folder.
PImage leftImg;  // shown when the blob is on the left side of the screen
PImage rightImg; // shown when the blob is on the right side of the screen
int puppetSize = 120;

void setup() {
  size(640, 480);

  leftImg = loadImage("left.png");
  rightImg = loadImage("right.png");

  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, 160, 120, cameras[0], 30);
    cam.start();     
  }      
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  pushMatrix();
  scale(-1,1);
  translate(-width,0);
  
  noStroke();
  int stepSize = 5;
  int numTargets = 0;
  //color targetColor = color(255, 0, 0);
  int threshold = 50;
  int xSum = 0;
  int ySum = 0;
  if(alpha(targetColor) == 0){
    image(cam,0,0,width,height);
  } else {
    background(0);
  }
  blobs.clear();
  
  for (int y = 0; y<cam.height; y+=stepSize){
    for (int x = 0; x<cam.width; x+=stepSize){
      float redV = red(cam.pixels[(y*cam.width)+x]);
      float greenV = green(cam.pixels[(y*cam.width)+x]);
      float blueV = blue(cam.pixels[(y*cam.width)+x]);
      
      //fill(0,0);
      //fill(cam.pixels[(y*cam.width)+x]);
      float cx = map(x, 0, cam.width, 0, width);
      float cy = map(y, 0, cam.height, 0, height);
      float cr = width/cam.width * stepSize;
      //circle(cx,cy,cr);
      
      if(mousePressed && alpha(targetColor) == 0){
        background(0);
        float mx = map(mouseX, 0, width, width, 0);
        float mouseDist = dist(mx, mouseY, cx, cy);
        if(mouseDist < cr){
          targetColor = color(redV, greenV, blueV);
        }
      } else if(alpha(targetColor) != 0){
        float redTarg = red(targetColor);
        float greenTarg = green(targetColor);
        float blueTarg = blue(targetColor);
      
        float colorDist = dist(redV, greenV, blueV, redTarg, greenTarg, blueTarg);
        if (colorDist < threshold){
          if(blobs.size() == 0){
            blobs.add(new Blob(cx, cy));
          } else {
            boolean newBlob = true;
            for(Blob blob:blobs){
              PVector center = blob.getCenter();
              float blobDist = dist(center.x, center.y, cx, cy);
              if(blobDist <= blobPointDistance){
                newBlob = false;
                blob.add(cx, cy);
                break;
              }
            }
            if(newBlob){
              blobs.add(new Blob(cx, cy));
            }
          }
        }
      }
    }
  }
  
  //for(Blob blob:blobs){
  //  fill(255);
  //  blob.display();
  //  fill(0,255,0);
  //  circle(blob.getCenter().x, blob.getCenter().y, 24);
  //}
  
  //image(cam, 0, 0, width, height);
  popMatrix();
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);

  // Homework: draw a puppet image instead of a box for each blob.
  // This is after popMatrix so the images are not drawn backward.
  // The blob x is in the flipped coordinates, so flip it back with map,
  // the same way mouseX was flipped above.
  for(Blob blob:blobs){
    PVector center = blob.getCenter();
    float sx = map(center.x, 0, width, width, 0);
    float sy = center.y;
    if(sx < width/2){
      image(leftImg, sx - puppetSize/2, sy - puppetSize/2, puppetSize, puppetSize);
    } else {
      image(rightImg, sx - puppetSize/2, sy - puppetSize/2, puppetSize, puppetSize);
    }
  }
}

void keyPressed(){
  if (key == 'r'){
    circleColor = color(255, 0, 0);
  } else if (key == 'g'){
    circleColor = color(0, 255, 0);
  } else if (key == 'b'){
    circleColor = color(0, 0, 255);
  } else if (key == 'c' || key == 'R'){ //rechoose/clear
    targetColor = color(0,0,0,0);
  }
}

class Blob {
  ArrayList<PVector> points;
  float minX;
  float minY;
  float maxX;
  float maxY;
  
  Blob(float x, float y){
    maxX = x;
    minX = x;
    maxY = y;
    minY = y;
    points = new ArrayList<PVector>();
    points.add(new PVector(x,y));
  }
  
  void add(float x, float y){
    maxX = max(maxX, x);
    minX = min(minX, x);
    maxY = max(maxY, y);
    minY = min(minY, y);
    points.add(new PVector(x,y));
  }
  
  void display(){
    float w = maxX - minX;
    float h = maxY - minY;
    rectMode(CORNER);
    rect(minX, minY, w, h);
  }
  
  PVector getCenter(){
    float w = maxX - minX;
    float h = maxY - minY;
    return new PVector(minX + w/2, minY + h/2);
  }
  
  PVector averagePos(){
    float xSum = 0;
    float ySum = 0;
    for(PVector pt:points){
      xSum += pt.x;
      ySum += pt.y;
    }
    return new PVector(xSum/points.size(), ySum/points.size());
  }
}
