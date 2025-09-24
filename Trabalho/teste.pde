void setup() {
size(500,500);
noFill();
stroke(255);
strokeWeight(2);
}

void draw(){
 //background(0);
 
 translate(width/2, height/2);
  
 beginShape();
 
 for (float theta = 0; theta < 2 * PI; theta += 0.01){
    float rad = r(theta,
      2, // a play around with these parameters to create interesting shapes.
      2, // b
      10000, // m
      1, // n1
      1.0, // n2
      1.0 // n3
    );
    float x = rad * cos(theta) * 50;
    float y = rad * sin(theta) * 50;
    vertex(x,y); 
   }
 
 endShape();
  
  
  //Creating a rectangle that creates a motion blur effect on the shapes
  fill (0,40);
  rect (-250,-250,height,width);
}


//SUPERFORMULA equation translated into processing syntax//
float r(float theta, float a, float b, float m, float n1, float n2, float n3){
 return pow(pow(abs(cos(m * theta/4.0) / a), n2) + 
        pow(abs(sin(m * theta/4.0) / b), n3), -1.0/n1) ; 
}
