class Evaluator {

  PImage target_image;
  int[] target_pixels_brightness;
  int[] target_binary;
  float[] target_weight; // peso para cada pixel baseado na intensidade

  Evaluator(PImage image, int resolution) {
    // Prepara a imagem alvo
    target_image = image.copy();
    target_image.resize(resolution, resolution);
    target_pixels_brightness = getPixelsBrightness(target_image);
    target_weight = getPixelWeights(target_image);
    target_binary = toBinary(target_image, 250); // threshold para binário >250 branco menor preto
  }

  // Calcula o fitness de um indivíduo
  float calculateFitness(Individual indiv) {
    PImage phenotype = indiv.getPhenotype(target_image.height);
    int[] phenotype_brightness = getPixelsBrightness(phenotype);
    int[] phenotype_binary = toBinary(phenotype, 250);

    // RMSE ponderado
    float rmse = getWeightedRMSE(target_pixels_brightness, phenotype_brightness, target_weight, 255);

    // Overlap binário com penalização de pixels extras
    float overlap = getBinaryOverlap(target_binary, phenotype_binary);

    // Fitness final combina forma (RMSE) e penalização de pixels extras
    return (1 - rmse) * overlap; //rmse 0 a 1 e o overlap 0 a 1 logo o maximo que temos é 1*1
  }

  // Converte imagem para brilho médio RGB
  int[] getPixelsBrightness(PImage image) {
    int[] pixels_brightness = new int[image.pixels.length];
    for (int i = 0; i < image.pixels.length; i++) {
      int c = image.pixels[i];
      int r = (c >> 16) & 0xFF;
      int g = (c >> 8) & 0xFF;
      int b = c & 0xFF;
      pixels_brightness[i] = (r + g + b) / 3;
    }
    return pixels_brightness;
  }

  // Define pesos: pixels escuros do target têm mais importância
  float[] getPixelWeights(PImage image) {
    float[] weights = new float[image.pixels.length];
    for (int i = 0; i < image.pixels.length; i++) {
      int c = image.pixels[i];
      int r = (c >> 16) & 0xFF; //Apanhar o vermelho mudando os pixeis e peguando os primeiros 8
      int g = (c >> 8) & 0xFF;
      int b = c & 0xFF;
      int brightness = (r + g + b) / 3;
      weights[i] = map(255 - brightness, 0, 255, 1.0, 5.0); //escala o valor consuante quão brilhante é 255-5 0-1 e algo entre 0-255 fica entre 1-5
    }
    return weights;
  }

  // RMSE ponderado pelos pesos
  float getWeightedRMSE(int[] target, int[] phenotype, float[] weight, float max_rmse) {
    float sum = 0;
    for (int i = 0; i < target.length; i++) {
      float diff = target[i] - phenotype[i];
      sum += weight[i] * diff * diff; //Um erro em que está fora da linha vale mais
    }
    float rmse = sqrt(sum / target.length);
    return rmse / max_rmse;
  }

  // Converte imagem para binário (linha = 1 (preto), fundo = 0 (branco))
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

  // Calcula overlap binário com penalização de pixels extras
  float getBinaryOverlap(int[] target_bin, int[] phenotype_bin) {
      float hits = 0;      // pixels corretos
      float extras = 0;    // pixels extras fora do alvo
      int total_target = 0;

      for (int i = 0; i < target_bin.length; i++) {
          if (target_bin[i] == 1) {
              total_target++;
              if (phenotype_bin[i] == 1) hits += 1; // acerto
          } else {
              if (phenotype_bin[i] == 1) extras += 0.1; // penalização leve
          }
      }

      if (total_target == 0) return 0; // evita divisão por zero

      float score = hits / total_target - extras / total_target;

      // garante que fique entre 0 e 1
      return Math.max(0, Math.min(1, score));
  }
}
