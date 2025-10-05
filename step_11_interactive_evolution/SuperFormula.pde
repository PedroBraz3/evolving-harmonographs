import processing.pdf.*; // Needed to export PDFs

/**
 * SuperFormula class implements the superformula mathematical equation for generating
 * parametric curves. Used as building blocks for harmonograph individuals.
 */
class SuperFormula {

    float a, b;                    // Scale parameters for x and y axes
    float n1, n2, n3;             // Shape parameters controlling curve characteristics
    float m;                       // Symmetry parameter (number of lobes)
    PImage phenotype = null;       // Cached rendered image
    ArrayList<PVector> points = new ArrayList<PVector>(); // Calculated curve points
    int numPoints = 500;           // Number of points to calculate for the curve
    int offsetX = 0;               // Horizontal offset (currently unused)
    int offsetY = 0;               // Vertical offset (currently unused)

  // Default constructor - creates random SuperFormula
  SuperFormula() {
    randomize();
  }

  // Constructor with specific parameter values
  SuperFormula(float a, float b, float n1, float n2, float n3, float m) {
    this.a = a; 
    this.b = b; 
    this.n1 = n1; 
    this.n2 = n2; 
    this.n3 = n3;
    this.m = m;
  }

  // Set all parameters to random values within valid ranges
  void randomize() {
    a = random(0.5, 20.0);      // Scale parameter for x-axis
    b = random(0.5, 20.0);      // Scale parameter for y-axis
    n1 = random(0.5, 10.0);     // Shape parameter 1
    n2 = random(0.5, 10.0);     // Shape parameter 2
    n3 = random(0.5, 10.0);     // Shape parameter 3
    m = int(random(0, 50));      // Symmetry parameter (integer)
    //offsetX = int(random(-resolution/2 * 0.8, resolution/2 * 0.8));
    //offsetY = int(random(-resolution/2 * 0.8, resolution/2 * 0.8));
    phenotype = null;            // Clear cached image
  }
  /*
  void mutate(){
    randomize();
  }*/
  
  // Helper function for controlled mutation of parameter values
  float maybeMutate(float value, float percent, boolean plus, float mutationRate, float min, float max) {
      if (random(1) < mutationRate) {
        if(plus){
          return (value+value*percent) <= max ? (value+value*percent) : max;
        } else {
          return ((value-value*percent) >= min) ? (value-value*percent) : min;
        }         
      } else {
          return value;
      }
  }  

  // Mutation operator - modifies parameters within valid ranges
  void mutate() {
    // Mutate scale parameters (a, b)
    a = maybeMutate(a, 0.25, random(1) < 0.5, individual_mutation_rate, 0.5, 20.0);
    b = maybeMutate(b, 0.25, random(1) < 0.5, individual_mutation_rate, 0.5, 20.0);
    
    // Mutate shape parameters (n1, n2, n3)
    n1 = maybeMutate(n1, 0.25, random(1) < 0.5, individual_mutation_rate, 0.5, 15);
    n2 = maybeMutate(n2, 0.25, random(1) < 0.5, individual_mutation_rate, 0.5, 15);
    n3 = maybeMutate(n3, 0.25, random(1) < 0.5, individual_mutation_rate, 0.5, 15);
    
    // Mutate symmetry parameter (m) - completely random within range
    if (random(1) < individual_mutation_rate) {
      m = int(random(1, 50));
    }
    
    // Offset mutations (currently commented out)
    /*
    if (random(1) < individual_mutation_rate) {
      int step = (random(1) < 0.5) ? -10 : 10;
      offsetX += step;
      offsetX = constrain(offsetX, int(-resolution/2*0.8), int(resolution/2*0.8));
    }
    if (random(1) < individual_mutation_rate) {
      int step = (random(1) < 0.5) ? -10 : 10;
      offsetY += step;
      offsetY = constrain(offsetY, int(-resolution/2 *0.8), int(resolution/2*0.8));
    }*/
    phenotype = null; // Clear cached image
  }

  // Get the phenotype (cached rendered image)
  PImage getPhenotype(int resolution) {
    if (phenotype != null && phenotype.height == resolution) {
      return phenotype;
    }
    PGraphics canvas = createGraphics(resolution, resolution);
    canvas.beginDraw();
    canvas.background(255);
    canvas.noFill();
    canvas.stroke(0);
    canvas.strokeWeight(canvas.height * 0.002);
    render(canvas, canvas.width / 2, canvas.height / 2, canvas.width, canvas.height);
    canvas.endDraw();
    phenotype = canvas.copy();
    return canvas;
  }

  // Draw the superformula curve as connected lines on a given canvas
  void render(PGraphics canvas, float x, float y, float w, float h) {
      calculatePoints(w, h);
      canvas.pushMatrix();
      canvas.translate(x + offsetX, y + offsetY); // Apply offset
      canvas.beginShape();
      for (int i = 0; i < points.size(); i++) {
        canvas.vertex(points.get(i).x, points.get(i).y);
      }
      canvas.endShape();
      canvas.popMatrix();
  }

  // Draw the superformula curve as individual points on a given canvas
  void renderPoints(PGraphics canvas, float x, float y, float w, float h) {
    calculatePoints(w, h);
    canvas.pushMatrix();
    canvas.translate(x+offsetX, y+offsetY);
    for (int i = 0; i < points.size(); i++) {
      canvas.point(points.get(i).x, points.get(i).y);
    }
    canvas.popMatrix();
  }

    // Create a copy of this SuperFormula
    SuperFormula getCopy() {
        SuperFormula copy = new SuperFormula();
        copy.a = this.a;
        copy.b = this.b;
        copy.m = this.m;
        copy.n1 = this.n1;
        copy.n2 = this.n2;
        copy.n3 = this.n3;
        copy.offsetX = this.offsetX;
        copy.offsetY = this.offsetY;
        // Copy all other parameters
        return copy;
    }

// Calculate curve points using the superformula equation
void calculatePoints(float w, float h) {
  boolean valid = false;

  while (!valid) {
    points.clear();
    float deltaPhi = TWO_PI / numPoints;

    float maxR = 0;
    float[] radii = new float[numPoints+1];
    valid = true; // Assume valid until problem found

    // Calculate radii using superformula equation
    for (int i = 0; i <= numPoints; i++) {
      float phi = i * deltaPhi;
      float r = pow(
                  pow(abs(cos(m * phi / 4) / a), n2) +
                  pow(abs(sin(m * phi / 4) / b), n3),
                  -1/n1
                );

      // Check for invalid values (NaN, infinite, or negative)
      if (Float.isNaN(r) || Float.isInfinite(r) || r <= 0) {
        valid = false;
        break; // Exit loop and try again
      }

      radii[i] = r;
      if (r > maxR) maxR = r;
    }

    // If invalid parameters → generate new ones and try again
    if (!valid || maxR <= 0) {
      randomize();
      continue;
    }

    // Normalize to fit within canvas
    float scale = min(w, h) / 2.0 / maxR;

    // Generate coordinates
    for (int i = 0; i <= numPoints; i++) {
      float phi = i * deltaPhi;
      float r = radii[i] * scale;
      float x = r * cos(phi);
      float y = r * sin(phi);
      points.add(new PVector(x, y));
    }
  }
}
  /*    
    float a, b; 
    float n1, n2, n3;
    float m;
  */
  // Convert SuperFormula parameters to string representation
  String toString(){
    return "a-" + a + "\n" + "b-" + b + "\n" + "n1-" + n1 + " n2-" + n2 + " n3-" + n3 + "\nm-" + m;
  }
}
