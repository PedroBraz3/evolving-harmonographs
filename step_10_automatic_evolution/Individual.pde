import processing.pdf.*;

class Individual {
    SuperFormula[] superformulas;
    float fitness = 0;
    PImage phenotype = null;

    Individual(){
        superformulas  = new SuperFormula[SuperFormulaNumber];
         inicializar();
    }

    void inicializar(){
        for(int i = 0; i<SuperFormulaNumber; i++){
            superformulas[i] = new SuperFormula();
        }
    }

    Individual(SuperFormula[] superformulas){
         this.superformulas = superformulas;
    }

    Individual getCopy() {
        SuperFormula[] newSuperformulas = new SuperFormula[superformulas.length];
        for (int i = 0; i < superformulas.length; i++) {
            newSuperformulas[i] = superformulas[i].getCopy(); // cria uma cópia independente
        }
        Individual copy = new Individual(newSuperformulas);
        copy.fitness = fitness;
        return copy;
    }

      //OnePointFlexibleCrossover corta para tras ou para a frente do ponto de corte
    Individual[] OnePointFlexibleCrossover(Individual partner) {
        Individual child1 = getCopy();
        Individual child2 = partner.getCopy();
        
        int numGenes = child1.superformulas.length;
        
        // Escolhe um ponto de corte aleatório (pode ser 0 ou o último)
        int cut = int(random(0, numGenes));
        
        // Escolhe direção: true = forward, false = backward
        boolean forward = random(1) < 0.5;

        if (forward) {
            for (int i = cut; i < numGenes; i++) {
                SuperFormula temp = child1.superformulas[i];
                child1.superformulas[i] = child2.superformulas[i];
                child2.superformulas[i] = temp;
            }
        } else {
            for (int i = cut; i >= 0; i--) {
                SuperFormula temp = child1.superformulas[i];
                child1.superformulas[i] = child2.superformulas[i];
                child2.superformulas[i] = temp;
            }
        }

        return new Individual[]{child1, child2};
    }

    void mutate(){
        if(random(1)<mutation_rate){
            for (int i = 0; i < superformulas.length; i++) {
                superformulas[i].mutate();
            }
        }
    }

    void display(float x, float y) {
        // Cria um canvas temporário para a composição
        PGraphics canvas = createGraphics(resolution, resolution);
        canvas.beginDraw();
        canvas.background(255);
        canvas.stroke(0);
        canvas.noFill();
        canvas.strokeWeight(2);

        // Desenha cada SuperFormula no mesmo canvas
        canvas.pushMatrix();
        canvas.translate(resolution/2, resolution/2);
        for (int i = 0; i < superformulas.length; i++) {
            superformulas[i].render(canvas, 0, 0, resolution, resolution);
        }
        canvas.popMatrix();
        canvas.endDraw();

        // Mostra o canvas na tela
        imageMode(CENTER);
        image(canvas, x, y);
    }

    int calculateFitness(){
        return 1;
    }

    void setFitness(float fitness){
        this.fitness=fitness;
    }

    float getFitness(){
        return fitness;
    }

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
    
    String toString(){
        String ind = "";
        for (int i = 0; i < superformulas.length; i++) {
            ind += superformulas[i].toString() + "\n";
        }
        return ind;
    }
    
    void renderPoints(PGraphics canvas, float cx, float cy, float w, float h) {
        canvas.pushMatrix();
        canvas.pushStyle();

        // move o sistema de coordenadas para o centro pedido
        canvas.translate(cx, cy);

        // podes ajustar strokeWeight aqui para que os pontos fiquem proporcionais
        float sw = max(1, w * 0.01);
        canvas.strokeWeight(sw);
        canvas.stroke(0);
        canvas.noFill();

        // delega para cada superformula
        for (int i = 0; i < superformulas.length; i++) {
            superformulas[i].renderPoints(canvas, 0, 0, w, h);
        }

        canvas.popStyle();
        canvas.popMatrix();
    }

    void export() {
        // cria o nome único (ano-mês-dia-hora-minuto-segundo)
        String output_filename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
            nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);

        String output_path = sketchPath("outputs/" + output_filename);
        println("Exporting individual to: " + output_path);

        // garante que a pasta "outputs" existe
        File outDir = new File(sketchPath("outputs"));
        if (!outDir.exists()) outDir.mkdirs();

        // --- exporta imagem PNG ---
        getPhenotype(2000).save(output_path + ".png");

        // --- exporta PDF (vetorial) ---
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

        // --- exporta genes (parâmetros) em txt ---
        String[] output_text_lines = new String[superformulas.length];
        for (int i = 0; i < superformulas.length; i++) {
            output_text_lines[i] = superformulas[i].toString();
        }
        saveStrings(output_path + ".txt", output_text_lines);

        println("✅ Export complete!");
    }
}