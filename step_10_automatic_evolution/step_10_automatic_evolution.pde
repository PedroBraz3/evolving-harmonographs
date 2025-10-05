// ===== PARAMETERS =====
// Population and evolution parameters
int population_size = 50;           // Number of individuals in the population
int elite_size = 2;                // Number of best individuals to preserve
int tournament_size = 2;            // Size of tournament for selection
float crossover_rate = 0.5;         // Probability of crossover occurring
float mutation_rate = 0.3;         // Probability of mutation occurring
float individual_mutation_rate = 1; // Rate of mutation for individual genes
int resolution = 256;              // Resolution for phenotype rendering
int SuperFormulaNumber = 2;        // Number of SuperFormula components per individual
int max_generations = 2000;        // Maximum number of generations to evolve

// Target image path for automatic evaluation
String path_target_image = "superformulas/2025-09-28-13-18-25.png";

// ===== GLOBAL VARIABLES =====
PopulationInd pop;                 // Population of harmonograph individuals
PVector[][] cells;                // Grid layout for displaying individuals
boolean phenotype_mode = true;    // Toggle between phenotype and genotype display
boolean show_fitness = true;      // Toggle fitness value display

// ===== SETUP FUNCTIONS =====
void settings() {
  // Set window size to 90% of display with high-quality rendering
  size(int(displayWidth * 0.9), int(displayHeight * 0.8), P2D);
  smooth(8);
}

void setup() {
  // Initialize with fixed seed for reproducible results
  randomSeed(42);
  
  // Center the window on screen
  int centerX = (displayWidth - width) / 2;
  int centerY = (displayHeight - height) / 2;
  surface.setLocation(centerX, centerY);
  
  // Load target image and initialize population with evaluator
  PImage target = loadImage(path_target_image);
  pop = new PopulationInd(target);
  
  // Calculate grid layout for displaying individuals
  cells = calculateGrid(population_size, 0, 0, width, height, 30, 10, 30, true);
  
  // Set text properties for fitness display
  textSize(constrain(cells[0][0].z * 0.15, 11, 14));
  textAlign(CENTER, TOP);
  
  // Debug code for testing individual fitness (commented out)
  /*
  Individual teste = new Individual(new SuperFormula[]{new SuperFormula(11.840047, 17.885777, 9.935061,1.0129713,4.9151177,24.0),new SuperFormula(12.140578,19.416162,8.545664,4.6335735,5.5556393,28.0)});
  Evaluator evaluator = new Evaluator(target, resolution);
  println(evaluator.calculateFitness(teste));
  */
}

// ===== MAIN RENDERING LOOP =====
void draw() {
  // Continue evolution until max generations reached
  if (pop.getGenerations() < max_generations) {
    pop.evolve();
    println("Current generation: " + pop.getGenerations());
  } else {
    println("Max generations reached: " + pop.getGenerations());
  }
  
  // Set background based on display mode
  background(phenotype_mode ? 235 : 0);
  
  // Get cell dimensions for consistent sizing
  float cell_dim = cells[0][0].z;
  int row = 0, col = 0;
  
  // Display all individuals in grid layout
  for (int i = 0; i < pop.getSize(); i++) {
    noFill();
    
    // Display phenotype (rendered image) or genotype (point cloud)
    if (phenotype_mode) {
      image(pop.getIndiv(i).getPhenotype(resolution), cells[row][col].x, cells[row][col].y, cell_dim, cell_dim);
    } else {
      strokeWeight(max(cell_dim * 0.01, 1));
      stroke(255, 50);
      pop.getIndiv(i).renderPoints(getGraphics(), cells[row][col].x + cell_dim / 2, cells[row][col].y + cell_dim / 2, cell_dim, cell_dim);
    }
    
    // Display fitness value if enabled
    if (show_fitness) {
      fill(phenotype_mode ? 80 : 200);
      text(nf(pop.getIndiv(i).getFitness(), 0, 4), cells[row][col].x + cell_dim / 2, cells[row][col].y + cell_dim + 2);
    }
    
    // Move to next grid position
    col += 1;
    if (col >= cells[row].length) {
      row += 1;
      col = 0;
    }
  }
}

// ===== USER INTERACTION =====
void keyReleased() {
  if (key == 'e') {
    // Export the best individual (index 0 after sorting)
    pop.getIndiv(0).export();
  } else if (key == ' ') {
    // Toggle between phenotype and genotype display
    phenotype_mode = !phenotype_mode;
  } else if (key == 'f') {
    // Toggle fitness value display
    show_fitness = !show_fitness;
  }
}

// ===== UTILITY FUNCTIONS =====
// Calculate grid of square cells for displaying individuals
PVector[][] calculateGrid(int cells, float x, float y, float w, float h, float margin_min, float gutter_h, float gutter_v, boolean align_top) {
  int cols = 0, rows = 0;
  float cell_size = 0;
  
  // Calculate optimal grid dimensions
  while (cols * rows < cells) {
    cols += 1;
    cell_size = ((w - margin_min * 2) - (cols - 1) * gutter_h) / cols;
    rows = floor((h - margin_min * 2) / (cell_size + gutter_v));
  }
  
  // Adjust rows if we can fit all cells in fewer rows
  if (cols * (rows - 1) >= cells) {
    rows -= 1;
  }
  
  // Calculate horizontal margin for centering
  float margin_hor_adjusted = ((w - cols * cell_size) - (cols - 1) * gutter_h) / 2;
  if (rows == 1 && cols > cells) {
    margin_hor_adjusted = ((w - cells * cell_size) - (cells - 1) * gutter_h) / 2;
  }
  
  // Calculate vertical margin
  float margin_ver_adjusted = ((h - rows * cell_size) - (rows - 1) * gutter_v) / 2;
  if (align_top) {
    margin_ver_adjusted = min(margin_hor_adjusted, margin_ver_adjusted);
  }
  
  // Create position array for each cell
  PVector[][] positions = new PVector[rows][cols];
  for (int row = 0; row < rows; row++) {
    float row_y = y + margin_ver_adjusted + row * (cell_size + gutter_v);
    for (int col = 0; col < cols; col++) {
      float col_x = x + margin_hor_adjusted + col * (cell_size + gutter_h);
      positions[row][col] = new PVector(col_x, row_y, cell_size);
    }
  }
  return positions;
}
