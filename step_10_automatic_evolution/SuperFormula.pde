import processing.pdf.*; // Needed to export PDFs

class SuperFormula {

    float a, b; 
    float n1, n2, n3;
    float m;
    PImage phenotype = null;
    ArrayList<PVector> points = new ArrayList<PVector>();
    int numPoints = 500;
    int offsetX = 0;
    int offsetY = 0;

  SuperFormula() {
    randomize();
  }

  SuperFormula(float a, float b, float n1, float n2, float n3, float m) {
    this.a = a; 
    this.b = b; 
    this.n1 = n1; 
    this.n2 = n2; 
    this.n3 = n3;
    this.m = m;
  }


  // Set all genes to random values
  void randomize() {
    a = random(0.5, 20.0);
    b = random(0.5, 20.0);
    n1 = random(0.5, 10.0);
    n2 = random(0.5, 10.0);
    n3 = random(0.5, 10.0);
    m = int(random(0, 50));
    //offsetX = int(random(-resolution/2 * 0.8, resolution/2 * 0.8));
    //offsetY = int(random(-resolution/2 * 0.8, resolution/2 * 0.8));
    phenotype = null;
  }
  /*
  void mutate(){
    randomize();
    phenotype = null;
  }*/
  
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

  
  // Mutation operator
  void mutate() {
    a = maybeMutate(a, 0.25,random(1) < 0.5, individual_mutation_rate, 0.5, 20.0);
    b = maybeMutate(b, 0.25,random(1) < 0.5, individual_mutation_rate, 0.5, 20.0);
    n1 = maybeMutate(n1, 0.25,random(1) < 0.5, individual_mutation_rate, 0.5, 15);
    n2 = maybeMutate(n2, 0.25,random(1) < 0.5, individual_mutation_rate, 0.5, 15);
    n3 = maybeMutate(n3, 0.25,random(1) < 0.5, individual_mutation_rate, 0.5, 15);
    if (random(1) < individual_mutation_rate) {
      m = int(random(1, 50));
    }
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
    phenotype = null;
  }

  // Get the phenotype (image)
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

  // Draw the harmonograph line on a given canvas, at a given position and with a given size
  void render(PGraphics canvas, float x, float y, float w, float h) {
      calculatePoints(w, h);
      canvas.pushMatrix();
      canvas.translate(x + offsetX, y + offsetY); // soma o offset
      canvas.beginShape();
      for (int i = 0; i < points.size(); i++) {
        canvas.vertex(points.get(i).x, points.get(i).y);
      }
      canvas.endShape();
      canvas.popMatrix();
  }

  // Draw the harmonograph points on a given canvas, at a given position and with a given size
  void renderPoints(PGraphics canvas, float x, float y, float w, float h) {
    calculatePoints(w, h);
    canvas.pushMatrix();
    canvas.translate(x+offsetX, y+offsetY);
    for (int i = 0; i < points.size(); i++) {
      canvas.point(points.get(i).x, points.get(i).y);
    }
    canvas.popMatrix();
  }

    SuperFormula getCopy() {
        SuperFormula copy = new SuperFormula();
        copy.a = this.a;
        copy.b = this.b;
        copy.m = this.m;
        copy.n1 = this.n1;
        copy.n2 = this.n2;
        copy.n3 = this.n3;
        // copie todos os outros parâmetros
        return copy;
    }

void calculatePoints(float w, float h) {
  boolean valid = false;

  while (!valid) {
    points.clear();
    float deltaPhi = TWO_PI / numPoints;

    float maxR = 0;
    float[] radii = new float[numPoints+1];
    valid = true; // assume válido até encontrar problema

    // calcula raios
    for (int i = 0; i <= numPoints; i++) {
      float phi = i * deltaPhi;
      float r = pow(
                  pow(abs(cos(m * phi / 4) / a), n2) +
                  pow(abs(sin(m * phi / 4) / b), n3),
                  -1/n1
                );

      if (Float.isNaN(r) || Float.isInfinite(r) || r <= 0) {
        valid = false;
        break; // sai do for e tenta de novo
      }

      radii[i] = r;
      if (r > maxR) maxR = r;
    }

    // se deu ruim → novos genes e tenta novamente
    if (!valid || maxR <= 0) {
      randomize();
      continue;
    }

    // Normaliza para caber no canvas
    float scale = min(w, h) / 2.0 / maxR;

    // gera coordenadas
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
  String toString(){
    return "a-" + a + "\n" + "b-" + b + "\n" + "n1-" + n1 + " n2-" + n2 + " n3-" + n3 + "\nm-" + m;
  }

 /* // Export image (png), vector (pdf) and genes (txt) of this harmonograph
  void export() {
    String output_filename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
      nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
    String output_path = sketchPath("outputs/" + output_filename);
    println("Exporting harmonograph to: " + output_path);

    getPhenotype(2000).save(output_path + ".png");

    PGraphics pdf = createGraphics(500, 500, PDF, output_path + ".pdf");
    pdf.beginDraw();
    pdf.noFill();
    pdf.strokeWeight(pdf.height * 0.001);
    pdf.stroke(0);
    render(pdf, pdf.width / 2, pdf.height / 2, pdf.width, pdf.height);
    pdf.dispose();
    pdf.endDraw();

    String[] output_text_lines = new String[genes.length];
    for (int i = 0; i < genes.length; i++) {
      output_text_lines[i] = str(genes[i]);
    }
    saveStrings(output_path + ".txt", output_text_lines);
  }*/
}
