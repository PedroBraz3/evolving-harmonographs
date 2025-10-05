/**
 * EvaluatorA class provides automatic fitness evaluation for harmonograph individuals
 * by comparing their rendered phenotype to a target image using weighted RMSE and binary overlap.
 */
class EvaluatorA {

  PImage target_image;              // Target image for comparison
  int[] target_pixels_brightness;  // Brightness values of target pixels
  int[] target_binary;             // Binary representation of target (line vs background)
  float[] target_weight;           // Weight for each pixel based on intensity

  // Constructor - prepares target image for evaluation
  EvaluatorA(PImage image, int resolution) {
    // Prepare target image
    target_image = image.copy();
    target_image.resize(resolution, resolution);
    target_pixels_brightness = getPixelsBrightness(target_image);
    target_weight = getPixelWeights(target_image);
    target_binary = toBinary(target_image, 250); // Threshold for binary: >250 white, <250 black
  }

  // Calculate fitness of an individual based on similarity to target
  float calculateFitness(Individual indiv) {
    PImage phenotype = indiv.getPhenotype(target_image.height);
    int[] phenotype_brightness = getPixelsBrightness(phenotype);
    int[] phenotype_binary = toBinary(phenotype, 250);

    // Weighted RMSE (Root Mean Square Error) for shape similarity
    float rmse = getWeightedRMSE(target_pixels_brightness, phenotype_brightness, target_weight, 255);

    // Binary overlap with penalty for extra pixels
    float overlap = getBinaryOverlap(target_binary, phenotype_binary);

    // Final fitness combines shape (RMSE) and penalty for extra pixels
    return (1 - rmse) * overlap; // RMSE 0-1 and overlap 0-1, so maximum is 1*1
  }

  // Convert image to average RGB brightness
  int[] getPixelsBrightness(PImage image) {
    int[] pixels_brightness = new int[image.pixels.length];
    for (int i = 0; i < image.pixels.length; i++) {
      int c = image.pixels[i];
      int r = (c >> 16) & 0xFF;  // Extract red component
      int g = (c >> 8) & 0xFF;   // Extract green component
      int b = c & 0xFF;          // Extract blue component
      pixels_brightness[i] = (r + g + b) / 3;
    }
    return pixels_brightness;
  }

  // Define weights: darker pixels in target have more importance
  float[] getPixelWeights(PImage image) {
    float[] weights = new float[image.pixels.length];
    for (int i = 0; i < image.pixels.length; i++) {
      int c = image.pixels[i];
      int r = (c >> 16) & 0xFF; // Extract red component
      int g = (c >> 8) & 0xFF;  // Extract green component
      int b = c & 0xFF;         // Extract blue component
      int brightness = (r + g + b) / 3;
      // Scale value based on brightness: 255->5, 0->1, values between 0-255 map to 1-5
      weights[i] = map(255 - brightness, 0, 255, 1.0, 5.0);
    }
    return weights;
  }

  // Weighted RMSE (Root Mean Square Error) using pixel weights
  float getWeightedRMSE(int[] target, int[] phenotype, float[] weight, float max_rmse) {
    float sum = 0;
    for (int i = 0; i < target.length; i++) {
      float diff = target[i] - phenotype[i];
      sum += weight[i] * diff * diff; // Error outside the line is weighted more
    }
    float rmse = sqrt(sum / target.length);
    return rmse / max_rmse;
  }

  // Convert image to binary (line = 1 (black), background = 0 (white))
  int[] toBinary(PImage image, int threshold) {
    int[] binary = new int[image.pixels.length];
    for (int i = 0; i < image.pixels.length; i++) {
      int c = image.pixels[i];
      int r = (c >> 16) & 0xFF;
      int g = (c >> 8) & 0xFF;
      int b = c & 0xFF;
      int brightness = (r + g + b) / 3;
      binary[i] = (brightness < threshold) ? 1 : 0;
    }
    return binary;
  }

  // Calculate binary overlap with penalty for extra pixels
  float getBinaryOverlap(int[] target_bin, int[] phenotype_bin) {
      float hits = 0;      // Correct pixels
      float extras = 0;    // Extra pixels outside target
      int total_target = 0;

      for (int i = 0; i < target_bin.length; i++) {
          if (target_bin[i] == 1) {
              total_target++;
              if (phenotype_bin[i] == 1) hits += 1; // Hit
          } else {
              if (phenotype_bin[i] == 1) extras += 0.1; // Extra pixel penalty
          }
      }

      if (total_target == 0) return 0; // Avoid division by zero

      float score = hits / total_target - extras / total_target;

      // Ensure result is between 0 and 1
      return Math.max(0, Math.min(1, score));
  }
}
