import processing.pdf.*;

/**
 * Individual class representing a harmonograph composed of multiple SuperFormula components.
 * Each individual contains an array of SuperFormula objects and has associated fitness.
 */
class Individual {
    SuperFormula[] superformulas;  // Array of SuperFormula components
    float fitness = 0;            // Fitness score (0-1, higher is better)
    PImage phenotype = null;      // Cached rendered image

    // Default constructor - creates random individual
    Individual(){
        superformulas = new SuperFormula[SuperFormulaNumber];
        inicializar();
    }

    // Initialize with random SuperFormula components
    void inicializar(){
        for(int i = 0; i < SuperFormulaNumber; i++){
            superformulas[i] = new SuperFormula();
        }
    }

    // Constructor with predefined SuperFormula array
    Individual(SuperFormula[] superformulas){
        this.superformulas = superformulas;
    }

    // Create a deep copy of this individual
    Individual getCopy() {
        SuperFormula[] newSuperformulas = new SuperFormula[superformulas.length];
        for (int i = 0; i < superformulas.length; i++) {
            newSuperformulas[i] = superformulas[i].getCopy(); // Create independent copy
        }
        Individual copy = new Individual(newSuperformulas);
        copy.fitness = fitness;
        return copy;
    }

    // OnePointFlexibleCrossover - cuts either forward or backward from the cut point
    Individual[] OnePointFlexibleCrossover(Individual partner) {
        Individual child1 = getCopy();
        Individual child2 = partner.getCopy();
        
        int numGenes = child1.superformulas.length;
        
        // Choose random cut point (can be 0 or last index)
        int cut = int(random(0, numGenes));
        
        // Choose direction: true = forward, false = backward
        boolean forward = random(1) < 0.5;

        if (forward) {
            // Swap genes from cut point to end
            for (int i = cut; i < numGenes; i++) {
                SuperFormula temp = child1.superformulas[i];
                child1.superformulas[i] = child2.superformulas[i];
                child2.superformulas[i] = temp;
            }
        } else {
            // Swap genes from cut point to beginning
            for (int i = cut; i >= 0; i--) {
                SuperFormula temp = child1.superformulas[i];
                child1.superformulas[i] = child2.superformulas[i];
                child2.superformulas[i] = temp;
            }
        }

        return new Individual[]{child1, child2};
    }

    // Apply mutation to all SuperFormula components
    void mutate(){
        if(random(1) < mutation_rate){
            for (int i = 0; i < superformulas.length; i++) {
                superformulas[i].mutate();
            }
        }
    }

    // Display individual at specified position (for debugging/visualization)
    void display(float x, float y) {
        // Create temporary canvas for composition
        PGraphics canvas = createGraphics(resolution, resolution);
        canvas.beginDraw();
        canvas.background(255);
        canvas.stroke(0);
        canvas.noFill();
        canvas.strokeWeight(2);

        // Draw each SuperFormula on the same canvas
        canvas.pushMatrix();
        canvas.translate(resolution/2, resolution/2);
        for (int i = 0; i < superformulas.length; i++) {
            superformulas[i].render(canvas, 0, 0, resolution, resolution);
        }
        canvas.popMatrix();
        canvas.endDraw();

        // Display the canvas on screen
        imageMode(CENTER);
        image(canvas, x, y);
    }

    // Calculate fitness (placeholder - actual fitness calculated by Evaluator)
    int calculateFitness(){
        return 1;
    }

    // Set fitness value
    void setFitness(float fitness){
        this.fitness = fitness;
    }

    // Get fitness value
    float getFitness(){
        return fitness;
    }

    // Get rendered phenotype image (cached for performance)
    PImage getPhenotype(int resolution) {
        if (phenotype != null && phenotype.height == resolution) {
            return phenotype;
        }

        PGraphics canvas = createGraphics(resolution, resolution);
        canvas.beginDraw();
        canvas.background(255);
        canvas.noFill();
        canvas.stroke(0);
        canvas.strokeWeight(resolution * 0.002);

        canvas.pushMatrix();
        canvas.translate(resolution/2, resolution/2);
        for (int i = 0; i < superformulas.length; i++) {
            superformulas[i].render(canvas, 0, 0, resolution, resolution);
        }
        canvas.popMatrix();

        canvas.endDraw();

        phenotype = canvas.get(); 
        return phenotype;
    }
    
    // Convert individual to string representation
    String toString(){
        String ind = "";
        for (int i = 0; i < superformulas.length; i++) {
            ind += superformulas[i].toString() + "\n";
        }
        return ind;
    }
    
    // Render individual as points on given canvas
    void renderPoints(PGraphics canvas, float cx, float cy, float w, float h) {
        canvas.pushMatrix();
        canvas.pushStyle();

        // Move coordinate system to requested center
        canvas.translate(cx, cy);

        // Adjust stroke weight proportionally
        float sw = max(1, w * 0.01);
        canvas.strokeWeight(sw);
        canvas.stroke(0);
        canvas.noFill();

        // Delegate to each SuperFormula
        for (int i = 0; i < superformulas.length; i++) {
            superformulas[i].renderPoints(canvas, 0, 0, w, h);
        }

        canvas.popStyle();
        canvas.popMatrix();
    }

    // Export individual in multiple formats (PNG, PDF, TXT)
    void export() {
        // Create unique filename (year-month-day-hour-minute-second)
        String output_filename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
            nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);

        String output_path = sketchPath("outputs/" + output_filename);
        println("Exporting individual to: " + output_path);

        // Ensure "outputs" directory exists
        File outDir = new File(sketchPath("outputs"));
        if (!outDir.exists()) outDir.mkdirs();

        // Export PNG image
        getPhenotype(2000).save(output_path + ".png");

        // Export PDF (vector format)
        PGraphics pdf = createGraphics(2000, 2000, PDF, output_path + ".pdf");
        pdf.beginDraw();
        pdf.noFill();
        pdf.strokeWeight(pdf.height * 0.001);
        pdf.stroke(0);

        pdf.pushMatrix();
        pdf.translate(pdf.width / 2, pdf.height / 2);
        for (int i = 0; i < superformulas.length; i++) {
            superformulas[i].render(pdf, 0, 0, pdf.width, pdf.height);
        }
        pdf.popMatrix();

        pdf.dispose();
        pdf.endDraw();

        // Export genes (parameters) as text file
        String[] output_text_lines = new String[superformulas.length];
        for (int i = 0; i < superformulas.length; i++) {
            output_text_lines[i] = superformulas[i].toString();
        }
        saveStrings(output_path + ".txt", output_text_lines);

        println("✅ Export complete!");
    }
}