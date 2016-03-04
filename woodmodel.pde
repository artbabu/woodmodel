import processing.pdf.*;

import java.util.*; 
import lsystem.util.*;
import lsystem.turtle.*;
import lsystem.collection.*;
import lsystem.*;
//import processing.opengl.*; // optimised for new version (else there is clipping)
// It'll be even better when I get PShapes3D to work!!!
import peasy.*;
 
PeasyCam cam; 
Grammar grammar;
 
float distance = 20;
float hDis = distance * 5;
float mainXTrans = 0 ;
float mainYTrans = 0 ;
float mainZTrans = 0 ;
int depth = 10;

float def_ang =0; 
PShape main ;
float PHI_BY_2 = radians(90);
float PHI = radians(180);

String production = "";
 
void setup() {
  //size(800, 600, OPENGL);
   size(1200, 1000, P3D);
   
   println(" H ===> "+height);
  println(" W ===> "+width); 
  ambientLight(80, 80, 80);
  directionalLight(100, 100, 100, -1, -1, 1);  
   background(20, 20, 200);
  lights();
  
 cam = new PeasyCam(this,0,0,0,1500); 
  
  
  //configureOpenGL();
  LUT.initialize();
  setupGrammar();
  main = createShape(GROUP);
  
  //float fov = PI/3.0;
  //float cameraZ = (height/2.0) / tan(fov/2.0);
  //perspective(fov, float(width)/float(height), cameraZ/2.0, cameraZ*2.0);
  //noStroke();
 
  
 
   mainXTrans =  (width/2) + 128 ;
  mainYTrans = (height/2) - 272 ; 
  
  parseAndRender();
  
   
}
 
//void configureOpenGL() {
//hint(ENABLE_OPENGL_4X_SMOOTH);
//hint(DISABLE_OPENGL_ERROR_REPORT);
//}
 
/**
 * Encapulates the lsystem rules, and calls the grammar to create the production rules
 * depth is number of repeats, and distance is adjusted according to the number of repeats
 */
 
void setupGrammar() {
  grammar = new SimpleGrammar(this, "A");   // this only required to allow applet to call dispose()
  grammar.addRule('A', "[xIIIyDDDzZT[rBBBr]]A");
  grammar.addRule('B', "{HP~HP>|HP>~HP<GR~GR>|GR>~GR<}B");
//  grammar.addRule('C', "[]");
 // grammar.addRule('S', "F>F>F>F");
 // grammar.addRule('D', "1>CFB>F<B1>FA+F-A1+FB>F<B1>FC1^");
 production = grammar.generateGrammar(depth);
 println(" prod ===>"+production);
  if (depth > 0) {
    //distance *= 1/(pow(2, depth) - 1);
  }
  println("distance ==>"+distance);
}
 
void draw() {
 
 
 //  background(20, 20, 200);
  
 
  
  //shape(main);
 

}
 
void parseAndRender()
{
    boolean render = false ;
    float sw = 10 ;
    char[] csArray = production.toCharArray();
    
     for (int i=0; i<csArray.length;i++) 
    {
      int pos = 0;
      switch(csArray[i])
      {
        
        // increment x for main shape
       case 'x' : 
           pos = updateMainTranslateCoor(csArray,csArray[i],i+1);
          i = pos ;
          break ;
       case 'y' : 
           pos = updateMainTranslateCoor(csArray,csArray[i],i+1);
          i = pos ;
          break ;
       case 'z' : 
          pos = updateMainTranslateCoor(csArray,csArray[i],i+1);
          i = pos ;
          break ;   
       case 'T' :
           println(" X ===> "+mainXTrans);
           println(" Y ===> "+mainYTrans);
           println(" Z ===> "+mainZTrans);
          translate( mainXTrans,  mainYTrans, mainZTrans);
          rotateX( 2 * PI/3);
           rotateY( 2 * PI/3);
         // rotateX(frameCount * 0.5f);
           // rotateY(frameCount * 0.5f); 
          break ;
       case '[' :  
           pushMatrix();
           break ;
       case ']' :
           popMatrix();
           break ;
       case 'r' :
       {
         if(!render)
           {
             pushStyle();
             render = true ;
             String subPartStr = getsubPartStr(csArray,csArray[i],i+1);
             i += subPartStr.length();
             println(" sub String "+subPartStr);
              shape(main);
              render(subPartStr,sw);
              if(sw > 4)
              sw = sw - 1 ; 
           }
         else
         {
            popStyle();
            render = false;
         }   
       }
         break;
        default:
      System.err.println("character " + csArray[i] + " not in grammar");
      }
      
    }
}
String getsubPartStr(char[] csArray,char endChar,int pos)
{
  String newProd = "";
  for(int i = pos ; csArray[i] != endChar ; i++)
    {
      newProd += String.valueOf(csArray[i]);
    }
  return newProd ;
}
int updateMainTranslateCoor(char[] csArray,char axis,int pos)
{
  int i = 0;
  Map<Character,Integer> charValueMap = new HashMap<Character,Integer>();
  charValueMap.put('I', 5);
  charValueMap.put('D', 3);
  charValueMap.put('Z', 0);
  /*
  * I -> iiii { i means increament 1 to axis coor}
  * D -> dddd { d means decrement 1 to axis coor}
  * Z -> plus 0
  */
  for(i = pos ; charValueMap.keySet().contains(csArray[i]) ; i++)
    {
  if(axis == 'x')
      mainXTrans += charValueMap.get(csArray[i]);
  else if(axis == 'y')
      mainYTrans += charValueMap.get(csArray[i]);
  else if(axis == 'z')
       mainZTrans += charValueMap.get(csArray[i]);
    }
  return i-1;
}


/**
 * Render wraps the drawing logic; draws a cylinder at origin,
 * followed by successive drawRod(distance) to complete the hilbert
 * according to lsystem rules (ie whenever there is an 'F').
 */
 
void render(String prod,float sw)
//void render()
{
  println("stroke :"+ sw);
  float translateX = 0 ;
  float translateY = 0 ;
  float translateZ = 0 ;
  boolean drawShape = false ;
  
  boolean doVertTransShape = false ;
  PShape currShape = createShape() ;
  PShape currFace = createShape();
  int repeats = 1;
  float ang = radians(def_ang) ;
  float currAngle = def_ang;
  fill(191, 191, 191);
  ambient(122, 122, 122);
  lightSpecular(30, 30, 30);
  specular(122, 122, 122);
  shininess(0.7);
  
  //char[] csArray = production.toCharArray();
  
    char[] csArray = prod.toCharArray();
    for (int i=0; i<csArray.length;i++) 
    {
      
    switch (csArray[i]) {
    case 'F':
    i++ ;
     currFace = drawFace(distance,csArray[i],sw,currAngle);
       currShape.addChild(currFace);
      break;
     case 'G':
     i++ ;
      currFace = drawFace(distance/2,csArray[i],sw,currAngle);
       currShape.addChild(currFace);
      break;
     case 'H':
     i++ ;
      currFace = drawFace(distance/4,csArray[i],sw,currAngle);
       currShape.addChild(currFace);
      break;
     case 'f':
      drawEmptyVertex(distance); 
      break;
     case 'g':
      drawEmptyVertex(distance/2); 
      break;
     case 'h':
      drawEmptyVertex(distance/3); 
      break; 
    case '+':
    if(drawShape)
      currFace.rotateX(ang * repeats);
   else
       rotateX(ang * repeats);
      repeats = 1;
      
      break;
    case '-':
    if(drawShape)
      currFace.rotateX(-ang * repeats);
     else  
      rotateX(-ang * repeats);
      repeats = 1;
      break; 
    case '>':
    if(drawShape)
      currFace.rotateY(ang * repeats);
    else
      rotateY(ang * repeats);
      repeats = 1;
      break;
    case '<':
      if(drawShape)
      currFace.rotateY(-ang * repeats);
      else
      rotateY(-ang * repeats);
      repeats = 1;
      break;
    case '^':
      if(drawShape)
      currFace.rotateZ(ang * repeats);
      else
      rotateZ(ang * repeats);
      repeats = 1;
      break;
    case '&':
      if(drawShape)
      currShape.rotateZ(-ang * repeats);
      else
      rotateZ(-ang * repeats);
      repeats = 1;
      break;  
    case '{':
    drawShape = true ;
    currShape = createShape(GROUP);
     break; 
    case '}':
    translateX += distance ;
    currShape.translate(translateX,translateY,translateZ);
    main.addChild(currShape);
    drawShape = false ;
     break; 
   case '|':
     ang = radians(180);
     currAngle = 180 ;
      break;
   case '~':
     ang = radians(90);
     currAngle = 90 ;
      break; 
   case '#' :
      ang = radians(def_ang);
     currAngle = 0 ;
    case '1':
      repeats += 1;
      break; 
    case 'A':
    case 'B':
    case 'C':
    case 'D':
      break;
    default:
      System.err.println("character " + csArray[i] + " not in grammar");
    }
  }
}
PShape drawFace(float dis,char type,float sw,float ang)
{ 
  
  println(" Angle ======> "+ang+" "+type);
  PShape shape = createShape();
  shape.beginShape(POLYGON);
  //shape.strokeWeight(sw);
  shape.fill(255, 255, 255);
  
  float l = dis ;
  float b = 5 * dis ;
   
  if(type == 'R')
      {
       
        shape.vertex(-(l), -hDis, +l);
        shape.vertex(+(l), -hDis, +l);
        shape.vertex(+(l), +hDis, +l);
        shape.vertex(-(l), +hDis, +l);
        
        if(ang == 90)
          insertPorousintoWall(shape,l,hDis);
       
        
      }else if(type == 'S')
      {
        shape.vertex(-(l), -l, +hDis);
        shape.vertex(+(l), -l, +hDis);
        shape.vertex(+(l), +l, +hDis);
        shape.vertex(-(l), +l, +hDis);
      }else if(type == 'P')
      {
        l = l + 2 ;
        b = (10 * dis) ;
         shape.vertex(-(l), -hDis, +l);
        shape.vertex(+(l), -hDis, +l);
        shape.vertex(+(l), +hDis, +l);
        shape.vertex(-(l), +hDis, +l);
        if(ang == 90)
          insertPorousintoWall(shape,l,hDis);
       
      }
   
     shape.endShape(CLOSE); 
     
     return shape ;  
    
} 
void insertPorousintoWall(PShape cellWall,float x,float y)
{
  
  println(" x :"+x+" y :"+y);
  int holeRes = 50 ;
  float holeRad = x / 2 ;
  
  float incY = y / 5 ;
    float py = incY - y;
 while( py < y)
 {
   cellWall.beginContour();
  for(int i = 0 ; i < holeRes;i++)
  {
   float angle = TWO_PI  * i / holeRes;
   float cx = sin(  angle ) * (holeRad);
   float cy = py + cos(  angle  ) * (2*holeRad);
   cellWall.vertex( cx, cy,x);     
  }
  cellWall.endContour();
  py = py + incY ;
 }
  
  
}
void drawEmptyVertex(float dis)
{
}
void keyReleased() {
  switch(key) {
  case '+':
    if (depth <= 3) { // guard against a depth we can't handle
      depth++;
      distance = 300;
      setupGrammar();
    }
    break;
  case '-':
    if (depth >= 2) {
      depth--;
      distance = 300;
      setupGrammar();
    }
    break;
  }
}