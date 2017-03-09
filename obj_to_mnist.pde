// Processing 3 script to create 2D renderings from 3D .obj files. 
// You can for instance create MNIST like grayscale images using the default configurations.

// Return all file paths in a given directory.
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    return file.list();
  } else {
    return null;
  }
}

// Return a map of already finished and rendered 3D .obj file paths.
HashMap<String, Boolean> listProcessedObjFilePaths(int imsPerObj) {
   HashMap<String, Boolean> renderedObjFilePaths = new HashMap<String, Boolean>();
  for (File file : (new File(sketchPath())).listFiles()) { // Check all files in the project dir
    if (file.isDirectory()) {
      File[] renderedIms = file.listFiles();
      if (renderedIms.length >= imsPerObj) {
        String dirName = file.getAbsolutePath();
        String[] dirNameSplit = dirName.split("/");
        renderedObjFilePaths.put(dirNameSplit[dirNameSplit.length - 1] + ".obj", true);
      }
    }
  }
  return renderedObjFilePaths;
}

void setup() {
  
  // Out image size
  size(128, 128, P3D);
  
  // Directory containing all .obj files
  String objDirPath = "/Users/username/shapenet/train/03001627";
  
  // Files to skip
  String[] objSkipList = { "model_009042.obj", "model_011456.obj", "model_027850.obj", "model_043758.obj" };
 
  PShape s;
  int imsPerObj = 3; // # of renderings per .obj file 
  int outScale = 300;
  color outColor = color(255, 255, 255); // Rendering color
  
  // Preprocessing of .obj models such as rotation and translation
  float rx = PI/10; // Elevation
  float ry = -PI/2;
  float rz = PI;
  float tx = width/2;
  float ty = height/2;
  float tz = -200; // Zoom, negative values to zoom out
  
  String[] objFilePaths = listFileNames(objDirPath);
  
  println("Found a total of " + objFilePaths.length + " models.");
  
  HashMap<String, Boolean> renderedObjFilePaths = listProcessedObjFilePaths(imsPerObj);
  
  println("Found " + renderedObjFilePaths.size() + " already finished models.");

  translate(tx, ty, tz);
  rotateX(rx);
  rotateY(ry);
  rotateZ(rz);
  
  // Save all .obj files as rendered images
  int i = 0;
  for (String objFilePath : objFilePaths) {
    String path = objDirPath + "/" + objFilePath;
    
    if (renderedObjFilePaths.containsKey(objFilePath) && renderedObjFilePaths.get(objFilePath)) {
      continue;
    }
    
    boolean skip = false;
    for (String skipObj : objSkipList) {
      if (objFilePath.contains(skipObj)) {
        skip = true;
        continue;
      }
    }
    if (skip) {
      continue;
    }
    
    println((i + 1) + "/" + (objFilePaths.length - renderedObjFilePaths.size())  + " Processing:" + path);
    
    s = loadShape(path);
    
    s.setFill(outColor);
    s.scale(outScale);
    
    // print(s.getVertexCount());
    // print(s.getChildCount());
  
    String modelName = objFilePath.split("\\.")[0];
    
    // Save 2D renderings of the model from different angles
    for (int j = 0; j < imsPerObj; j++) {
      background(0); // Reset
      fill(255);
      shape(s);
      save(modelName + "/" + modelName + "_" + j + ".png");
      rotateY(2*PI/imsPerObj);
    }
    
    i++;
  }
}

void draw() {}