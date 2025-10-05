// ===== PARAMETERS =====
// Population and evolution parameters (smaller population for interactive evaluation)
int population_size = 10;         // Number of individuals in the population
int elite_size = 0;              // Number of best individuals to preserve (disabled for interactive)
int tournament_size = 2;          // Size of tournament for selection
float crossover_rate = 0.5;       // Probability of crossover occurring
float mutation_rate = 0.3;        // Probability of mutation occurring
float individual_mutation_rate = 0.5; // Rate of mutation for individual genes
int resolution = 256;             // Resolution for phenotype rendering
int SuperFormulaNumber = 2;       // Number of SuperFormula components per individual

// ===== GLOBAL VARIABLES =====
PopulationInd pop;                // Population of harmonograph individuals
PVector[][] cells;               // Grid layout for displaying individuals
Individual hovered_indiv = null; // Currently hovered individual for interaction

// ===== SETUP FUNCTIONS =====
void settings() {
  // Set window size to 90% of display with high-quality rendering
  size(int(displayWidth * 0.9), int(displayHeight * 0.8), P2D);
  smooth(8);
}

void setup() {
  // Initialize with fixed seed for reproducible results
  randomSeed(42);
  
  // Initialize population (no target image needed for interactive evaluation)
  pop = new PopulationInd();
  
  // Calculate grid layout for displaying individuals (leave space for controls)
  cells = calculateGrid(population_size, 0, 0, width, height - 30, 30, 10, 30, true);
  
  // Set text properties for fitness display
  textSize(constrain(cells[0][0].z * 0.15, 11, 14));
  
  // Center the window on screen
  surface.setLocation(
    (displayWidth - width) / 2, 
    (displayHeight - height) / 2
  );
}

// ===== MAIN RENDERING LOOP =====
void draw() {
  background(235);
  hovered_indiv = null; // Clear hovered individual at start of frame
  int row = 0, col = 0;
  
  // Display all individuals in grid layout
  for (int i = 0; i < pop.getSize(); i++) {
    float x = cells[row][col].x;
    float y = cells[row][col].y;
    float d = cells[row][col].z;
    
    // Check if current individual is hovered by the cursor
    noStroke();
    fill(0);
    if (mouseX > x && mouseX < x + d && mouseY > y && mouseY < y + d) {
      hovered_indiv = pop.getIndiv(i);
      rect(x - 1, y - 1, d + 2, d + 2); // Highlight hovered individual
    }
    
    // Highlight individuals with fitness > 0 (user-evaluated)
    if (pop.getIndiv(i).getFitness() > 0) {
      rect(x - 3, y - 3, d + 6, d + 6); // Thicker border for evaluated individuals
    }
    
    // Draw phenotype of current individual
    image(pop.getIndiv(i).getPhenotype(resolution), x, y, d, d);
    
    // Draw fitness value below individual
    fill(0);
    textAlign(CENTER, TOP);
    text(nf(pop.getIndiv(i).getFitness(), 0, 2), x + d / 2, y + d + 5);
    
    // Move to next grid cell
    col += 1;
    if (col >= cells[row].length) {
      row += 1;
      col = 0;
    }
  }

  // Draw control instructions at bottom of screen
  fill(128);
  textSize(14);
  textAlign(LEFT, BOTTOM);
  text("Controls:     [click over indiv] set as preferred     [enter] evolve     [r] reset     [e] export individ hovered by the cursor", 30, height - 30);
}

// ===== USER INTERACTION =====
void keyReleased() {
  if (keyCode == ENTER || keyCode == RETURN) {
    // Press [enter] to evolve new generation
    pop.evolve();
  } else if (key == ' ') {
    // Press [space] to evolve (generate new population)
    pop.evolve();
  } else if (key == 'r') {
    // Press [r] to reset population
    pop.initialize();
  } else if (key == 'e') {
    // Press [e] to export selected individual
    if (hovered_indiv != null) {
      hovered_indiv.export();
    }
  } else {
    // Arrow key controls for fitness adjustment
    if (hovered_indiv != null) {
      int fit = hovered_indiv.getFitness();
      if (keyCode == UP) {
        fit = min(fit + 1, 10);      // Increase fitness (max 10)
      } else if (keyCode == DOWN) {
        fit = max(fit - 1, 1);       // Decrease fitness (min 1)
      } else if (keyCode == RIGHT) {
        fit = 1;                     // Set to minimum fitness
      } else if (keyCode == LEFT) {
        fit = 0;                     // Set to no fitness
      }
      hovered_indiv.setFitness(fit);
    }
  }
}

// Mouse interaction for fitness assignment
void mouseReleased() {
  // Toggle fitness of clicked individual between high and low values
  if (hovered_indiv != null) {
    if (hovered_indiv.getFitness() < 10) {
      hovered_indiv.setFitness(10);  // Set to high fitness
    } else {
      hovered_indiv.setFitness(1);   // Set to low fitness
    }
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


/*
Individual ind;

/*
a-11.840047
b-17.885777
n1-9.935061 n2-1.0129713 n3-4.9151177
m-24.0
a-12.140578
b-19.416162
n1-8.545664 n2-4.6335735 n3-5.5556393
m-28.0
*/
/*
void setup() {
    size(600, 600);
    ind = new Individual(new SuperFormula[]{new SuperFormula(11.840047, 17.885777,9.935061,1.0129713,4.9151177, 24),new SuperFormula(12.140578, 19.416162,8.545664,4.6335735,5.5556393, 28)});
    background(255);
    noLoop();
}

void draw() {
    background(255);
    ind.display(width/2, height/2); 
}

void keyReleased() {
    if (keyCode == ENTER){
            ind.mutate();
            redraw();
            println(ind);
        }    
}*/