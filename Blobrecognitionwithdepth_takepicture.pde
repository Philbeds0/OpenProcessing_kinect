/*
Developed from some snippets given by Shiffman (referencies in Blob)
You'll need the Open Kinect for Processing library (Sketch-Import Library)

Questo firmware rileva la presenza di un oggetto all'interno di un intervallo stabilito e successivamente lo colora di blu, creando poi un blob intorno alla zona colorata 
in base al numero di pixel che occupa nello schermo. Se l'oggetto entra in un nuovo intervallo verrà considerato come pressione e mostrerà un rettangolo grigio.
All'esterno dei due intervalli di profondità non sarà visualizzato niente.
*/

//Import OpenKinect for Processing Library
import org.openkinect.processing.*; 

//Detect Kinect as Kinect version 1
Kinect kinect; 

//Take a screenshot 640 x 480 pixel, higher the values bigger the image
PImage cam = createImage(640, 480, RGB); 

//Depth minimum threshold
int minThresh = 761; 

//Depth maximum threshold
int maxThresh = 850; 

int pushgreen1 = 700;
int pushgreen2 = 760;
int numpixel_green=0;

/*to detect how many pixels are red. This is optional, it's just to check if the firmware is working properly*/
long numpixel_trigger;

/*To create a blob comprised of a defined amount of pixel. Ex. The higher the value the bigger the blob. The chosen number is optimized for just one hand*/
long maxpixel_blob;

//Visual threshold, these numbers will affect the object's visibility range 
float threshold = 25;
float distThreshold = 50;

//array to contain Blob values
ArrayList<Blob> blobs = new ArrayList<Blob>();


void setup() 

{
  //Window size, does not affect the screenshot's size 
  size(640, 480, P3D);
  
  //Assigns the correct port 
  kinect = new Kinect(this); 
  
  //Activate mirror mode, so that it seems like I m in front of a mirror
  kinect.enableMirror(true);
  
  //Activate depth recognition
  kinect.initDepth(); 
}


void draw() {
  
//Load the taken snapshot inside the array "pixels"
  cam.loadPixels(); 
  
//Clear the blobs from previous runs
    blobs.clear();
    
//array to contain depth values
  int[] arraydepth0 = kinect.getRawDepth(); 
  
  //Until x is less than window height and width take each pixel and put it inside the array
  for (int x = 0; x < kinect.width; x++) { 
    
    
    for (int y = 0; y < kinect.height; y++) {  
      
      //total number of pixels
      int numCasellina = x + y * kinect.width;
      
      //Load data from the depth array to  numCasellina and call it "depth101"
      int depth101 = arraydepth0[numCasellina];
    
      //When "depth101" is full 
      if ((depth101 > minThresh) && (depth101 < maxThresh)) {
        
        
    //set found to false and look for previous blobs, this is to create just one blob instead of having multiple small blobs
        boolean found = false ;
        for (Blob b : blobs) {
          
          //if it find blob smaller than 12000 pixel, then join them
          if (b.isNear(x, y) && (maxpixel_blob>1 && maxpixel_blob<12000)) {
            b.add(x, y);
            found = true;
            break;
          }
        }
        
    /*otherwise create a new blob.*/
        if ((!found) && (maxpixel_blob>1 && maxpixel_blob<12000)) {
          Blob b = new Blob(x, y);
          blobs.add(b);
        }
 
  //Add 1 to count how many red pixels there are (debugging)
        numpixel_trigger++;
        
  //Add 1 to count how many red pixels there are (to create a blob)
        maxpixel_blob++;
        
      }

      else{
        
        //take a snapshot and add it to numcasellina, this is to compare between background and the blob.
        cam.pixels[numCasellina] = color(0); 
        
        if ((depth101 > pushgreen1) && (depth101 < pushgreen2)) {
        cam.pixels[numCasellina] = color(0, 255, 0);
        numpixel_green++;
  }
      }
    }
  }
  
//Camera refresh
  cam.updatePixels();
  
  //Show the results
  image(cam, 0, 0);
  
  //if the blob is bigger than 12000 pixel then show it on the screen
  for (Blob b : blobs) {
  if (b.size() > 7000) {
      b.show();
    }
    }
    
  //Debugging variables
  String parola = ("i pixel verdi sono");
  String parola2 = ("i pixel blu sono");

  //How many pixel inside the blob
  println(parola2,maxpixel_blob);
  
  //Draw a green rectangle if there are more than 5000 pixels
  if (numpixel_green > 5080){
  //pushMatrix();
  //  translate(30, 20);
  //  rect(0, 0, 50, 50);          
  //  fill(130);  
  //  popMatrix();
   saveFrame("output/img_####.png");// take a snapshot
    fill(255, 0, 0);
  }
  //Clean the variables, so that the firmware does not crash
   numpixel_trigger=0; 
   maxpixel_blob=0;
   numpixel_green=0;
 
}
//Distance from other blobs x and y
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}
//Distance from other blobs x and y and z
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
