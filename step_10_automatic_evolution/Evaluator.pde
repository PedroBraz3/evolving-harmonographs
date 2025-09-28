import java.net.*;
import java.io.*;

class Evaluator {

  String serverUrl = "http://127.0.0.1:5000/evaluate";

  Evaluator(PImage image, int resolution) {
    println("Evaluator conectado ao Python em " + serverUrl);
  }

  float calculateFitness(Individual indiv) {
    try {
      // 1. Obter fenótipo como imagem
      PImage phenotype = indiv.getPhenotype(256);

      // 2. Obter pixels diretamente e converter para bytes RGB
      int w = phenotype.width;
      int h = phenotype.height;
      byte[] imgBytes = new byte[w * h * 3]; // RGB
      for (int i = 0; i < w * h; i++) {
        int c = phenotype.pixels[i];
        imgBytes[i*3 + 0] = (byte)((c >> 16) & 0xFF); // R
        imgBytes[i*3 + 1] = (byte)((c >> 8) & 0xFF);  // G
        imgBytes[i*3 + 2] = (byte)(c & 0xFF);         // B
      }

      // 3. Criar JSON (sem salvar arquivo)
      StringBuilder sbJson = new StringBuilder();
      sbJson.append("{\"image_bytes\":[");
      for (int i = 0; i < imgBytes.length; i++) {
        sbJson.append(imgBytes[i] & 0xFF);
        if (i < imgBytes.length - 1) sbJson.append(",");
      }
      sbJson.append("]}");
      String json = sbJson.toString();

      // 4. POST para Flask
      URL url = new URL(serverUrl);
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json");
      conn.setDoOutput(true);

      OutputStream os = conn.getOutputStream();
      os.write(json.getBytes());
      os.flush();

      // 5. Ler resposta
      BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      StringBuilder sb = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) sb.append(line);
      conn.disconnect();

      // 6. Extrair fitness
      String response = sb.toString();
      if (response.contains("fitness")) {
        String num = response.replaceAll("[^0-9\\.]", "");
        return Float.parseFloat(num);
      }

    } catch (Exception e) {
      e.printStackTrace();
    }
    return 0.0f;
  }
}
