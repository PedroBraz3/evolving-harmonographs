import java.util.*; // Needed to sort arrays

/**
 * PopulationInd class manages a population of harmonograph individuals for automatic evolution.
 * Uses EvaluatorA for fitness calculation based on target image similarity.
 */
class PopulationInd {
  
  Individual[] individuals;  // Array to store the individuals in the population
  int generations;          // Integer to keep count of how many generations have been created
  EvaluatorA evaluator;     // Evaluator for automatic fitness calculation
  
  // Constructor with target image for automatic evaluation
  PopulationInd(PImage target) {
    individuals = new Individual[population_size];
    evaluator = new EvaluatorA(target, resolution);
    initialize();
  }
  
  // Create the initial individuals with automatic fitness evaluation
  void initialize() {
    // Fill population with random individuals
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new Individual();
      // Calculate fitness using evaluator (scaled 1-10 for roulette selection)
      float fitness = evaluator.calculateFitness(individuals[i]) * 9 + 1;
      individuals[i].setFitness(fitness);
    }
    
    // Reset generations counter
    generations = 0;
    sortIndividualsByFitness();
  }
  
  // Create the next generation using genetic operators
  void evolve() {
    // Create new generation array
    Individual[] new_generation = new Individual[individuals.length];
    
    // Sort individuals by fitness
    sortIndividualsByFitness();
    
    // Count number of individuals with fitness score
    int eliteSizeAdjusted = min(elite_size, getPreferredIndivsShuffled().size());
    
    // Copy the elite to the next generation (elitism)
    for (int i = 0; i < eliteSizeAdjusted; i++) {
      new_generation[i] = individuals[i].getCopy();
    }
    
    // Create new individuals with crossover or reproduction
    for (int i = eliteSizeAdjusted; i < population_size; i += 2) {
      Individual[] newIndivs;
      if (random(1) < crossover_rate) {
        // Perform crossover between two parents
        Individual parent1 = selectByRoulette();
        Individual parent2 = selectByRoulette();
        newIndivs = parent1.OnePointFlexibleCrossover(parent2);
      } else {
        // Simple reproduction (copy parents)
        newIndivs = new Individual[]{selectByRoulette().getCopy(), selectByRoulette().getCopy()};
      }
      new_generation[i] = newIndivs[0];
      if (i + 1 < population_size) {
        new_generation[i + 1] = newIndivs[1];
      }
    }
    
    // Apply mutation to new individuals
    for (int i = eliteSizeAdjusted; i < new_generation.length; i++) {
       new_generation[i].mutate();
    }
    
    // Replace the individuals in the population with the new generation
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new_generation[i];
    }
    
    // Calculate fitness for new individuals (excluding elite)
    for (int i = eliteSizeAdjusted; i < new_generation.length; i++) {
      float fitness = evaluator.calculateFitness(new_generation[i]) * 9 + 1;
      new_generation[i].setFitness(fitness);
    }
    sortIndividualsByFitness();
    
    // Increment the number of generations
    generations++;
  }

  // Roulette wheel selection - probability proportional to fitness
  Individual selectByRoulette() {
        float totalFitness = 0;
        for (int i = 0; i < individuals.length; i++) {
            totalFitness += individuals[i].getFitness();
        }

        float r = random(totalFitness);
        float acum = 0;
        for (int i = 0; i < individuals.length; i++) {
            acum += individuals[i].getFitness();
            if (acum >= r) {
                return individuals[i];
            }
        }
        // Fallback in case something goes wrong
        return individuals[individuals.length-1];
    }
  
  Individual tournamentSelectionV2() {
    // Define pool of individuals from which one will be selected by tournament
    Individual[] selectionPool;
    ArrayList<Individual> prefferedIndividuals = getPreferredIndivsShuffled();
    if (prefferedIndividuals.size() > 1) {
      Collections.shuffle(prefferedIndividuals);
      selectionPool = prefferedIndividuals.toArray(new Individual[0]);
    } else if (prefferedIndividuals.size() == 1) {
      return prefferedIndividuals.get(0);
    } else {
      selectionPool = individuals;
    }
    
    // Select a set of individuals at random
    Individual[] tournament = new Individual[tournament_size];
    for (int i = 0; i < tournament.length; i++) {
      int randomIndex = int(random(0, selectionPool.length));
      tournament[i] = selectionPool[randomIndex];
    }

    // Return the fittest individual from the selected ones
    Individual fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }
    return fittest;
  }

  /*
  // Select one individual using a tournament selection 
  Harmonograph tournamentSelection() {
    // Select a random set of individuals from the population
    Harmonograph[] tournament = new Harmonograph[tournament_size];
    for (int i = 0; i < tournament.length; i++) {
      int random_index = int(random(0, individuals.length));
      tournament[i] = individuals[random_index];
    }
    // Get the fittest individual from the selected individuals
    Harmonograph fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }
    return fittest;
  }*/
  
  /**
   * Returns list with individuals with fitness greater than zero.
   */
  ArrayList<Individual> getPreferredIndivsShuffled() {
    ArrayList<Individual> output = new ArrayList<Individual>();
    for (Individual indiv : individuals) {
      if (indiv.getFitness() > 0) {
        output.add(indiv);
      }
    }
    return output;
  }
  
  // Sort individuals in the population by fitness in descending order (fittest first)
  void sortIndividualsByFitness() {
    Arrays.sort(individuals, new Comparator<Individual>() {
      public int compare(Individual indiv1, Individual indiv2) {
        return Float.compare(indiv2.getFitness(), indiv1.getFitness());
      }
    });
  }
  
  // Get an individual from the population located at the given index
  Individual getIndiv(int index) {
    return individuals[index];
  }
  
  // Get the number of individuals in the population
  int getSize() {
    return individuals.length;
  }
  
  // Get the number of generations that have been created so far
  int getGenerations() {
    return generations;
  }
}
