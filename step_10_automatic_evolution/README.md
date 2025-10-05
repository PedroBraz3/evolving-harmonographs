# Automatic Evolution of Harmonographs

This module demonstrates the automatic evolution of harmonograph drawings using a fitness function that evaluates individuals based on their visual similarity to a preset target image. The system uses SuperFormula-based individuals composed of multiple parametric curves that evolve to match a target shape.

![](../images/automatic-evolution.gif)
*Population of harmonographs being evolved to resemble the target image*

## Key Features

- **Automatic Fitness Evaluation**: Uses `EvaluatorA` class to compare rendered phenotypes with target images
- **SuperFormula Individuals**: Each individual contains multiple SuperFormula components
- **Advanced Evaluation Metrics**: Combines weighted RMSE and binary overlap with penalty for extra pixels
- **Elitism and Roulette Selection**: Preserves best individuals and uses fitness-proportional selection
- **Flexible Crossover**: OnePointFlexibleCrossover with forward/backward direction selection
- **Controlled Mutation**: Parameter-specific mutation rates with valid range constraints

## Architecture

### Core Classes

- **`Individual`**: Represents a harmonograph with multiple SuperFormula components
- **`PopulationInd`**: Manages population evolution with automatic fitness evaluation
- **`SuperFormula`**: Implements parametric curve generation using superformula equation
- **`EvaluatorA`**: Provides automatic fitness calculation based on target image similarity

### Evolution Process

1. **Initialization**: Creates random population and evaluates fitness automatically
2. **Selection**: Uses roulette wheel selection based on fitness scores
3. **Crossover**: OnePointFlexibleCrossover with configurable direction
4. **Mutation**: Controlled parameter mutation within valid ranges
5. **Elitism**: Preserves best individuals across generations
6. **Evaluation**: Automatic fitness calculation using weighted RMSE and binary overlap

## Parameters

- **Population Size**: 50 individuals
- **Elite Size**: 2 (best individuals preserved)
- **Crossover Rate**: 0.5 (50% chance of crossover)
- **Mutation Rate**: 0.3 (30% chance of individual mutation)
- **Individual Mutation Rate**: 1.0 (100% chance of gene mutation)
- **Max Generations**: 2000
- **Resolution**: 256x256 pixels for phenotype rendering

## Controls

Users can interact with the program using the following controls:

- Press key `p` to toggle between phenotype and genotype display modes
- Press key `f` to toggle the visibility of fitness values
- Press key `e` to export the best individual to file (PNG, PDF, TXT formats)

## Fitness Evaluation

The `EvaluatorA` class implements a sophisticated fitness function that:

1. **Weighted RMSE**: Compares pixel brightness with higher weights for darker target pixels
2. **Binary Overlap**: Measures shape similarity with penalty for extra pixels
3. **Combined Score**: `(1 - rmse) * overlap` for final fitness value

## Export Functionality

Individuals can be exported in multiple formats:
- **PNG**: High-resolution raster image (2000x2000)
- **PDF**: Vector format for scalable graphics
- **TXT**: Parameter values for reproduction

## Challenges

- Implement adaptive mutation rates based on population diversity
- Add automatic export when fitness plateaus
- Implement multiple target image support
- Add real-time fitness visualization
- Implement parameter sensitivity analysis