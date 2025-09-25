

class Individual {
    SuperFormula[] superformulas;
    float fitness;

    Individual(){
         superformulas = new SuperFormula[SuperFormulaNumber];
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
        Individual copy = new Individual(superformulas);
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
    


}