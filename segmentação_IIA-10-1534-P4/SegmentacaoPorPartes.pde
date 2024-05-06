void setup() { 
  size(1218, 124); 
  noLoop(); 
}

void draw() {
  
  PImage img = loadImage("IIA-10-1534-P4.png"); 
  PImage imgPB = createImage(img.width, img.height, RGB); 
  PImage seg1 = createImage(img.width, img.height, RGB);
  PImage seg2 = createImage(img.width, img.height, RGB);
  PImage seg = createImage(img.width, img.height, RGB);

  
  // Filtro escala de cinza 
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) { 
      int pos = y * img.width + x; // Correção: posição y * largura da imagem + x
      float media = green(img.pixels[pos]);
      imgPB.pixels[pos] = color(media);
    }
  }
  
  imgPB.updatePixels(); // Atualize os pixels da imagem após processá-la
  
  image(imgPB, 0, 0); 
  save("imgPB.jpg");
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) { 
      int pos = y * img.width + x; // Correção: posição y * largura da imagem + x
      if (green(imgPB.pixels[pos]) < 65.2) seg1.pixels[pos] = color(255);
      else seg1.pixels[pos] = color(0);
    }
  }
  
  seg1.updatePixels(); // Atualize os pixels da imagem após processá-la
  
  image(seg1, 0, 0); 
  save("seg1.jpg");
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) { 
      int pos = y * img.width + x; // Correção: posição y * largura da imagem + x
      if (green(imgPB.pixels[pos]) > 99) seg2.pixels[pos] = color(255);
      else seg2.pixels[pos] = color(0);
    }
  }
  
  seg2.updatePixels(); // Atualize os pixels da imagem após processá-la
  
  image(seg2, 0, 0); 
  save("seg2.jpg");
  
  // Combine as duas imagens segmentadas
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) { 
      int pos = y * img.width + x; // Correção: posição y * largura da imagem + x
      if (green(seg1.pixels[pos]) == 255 || green(seg2.pixels[pos]) == 255) {
        seg.pixels[pos] = color(255);
      } else {
        seg.pixels[pos] = color(0); 
      }
    }
 }
  
  seg.updatePixels(); // Atualize os pixels da imagem após processá-la
  
  image(seg, 0, 0); 
  save("img.jpg");
  
  imprimirResultados(seg); // Vamos verificar os resultados usando a imagem segmentada final
}

void imprimirResultados(PImage img)
{
  PImage groundTruth = loadImage("IIA-10-1534-P4_GT1.bmp"); // Carregar a imagem de referência
  groundTruth.loadPixels();
  img.loadPixels(); // Carregar pixels da imagem processada
  
  int nFalsosPositivos = 0;
  int nFalsosNegativos = 0;
  int nErros = 0;
  
  for (int y = 0; y < img.height; y++)
  {
    for (int x = 0; x < img.width; x++)
    {
      int pos = y * img.width + x; // Correção: posição y * largura da imagem + x
      // Verificar se o pixel da imagem de referência é preto (0)
      if (green(groundTruth.pixels[pos]) == 0)
      {
        // Se for preto e o pixel correspondente na imagem processada não for preto, é um falso negativo
        if (green(img.pixels[pos]) != 0)
        {
          nFalsosNegativos++;
        }
      }
      else // Se não for preto na imagem de referência, mas for na imagem processada, é um falso positivo
      {
        if (green(img.pixels[pos]) == 0)
        {
          nFalsosPositivos++;
        }
      }
    }
  }
  
  nErros = nFalsosPositivos + nFalsosNegativos;
  float erroPercentual = (float) nErros / (img.width * img.height) * 100.0;
  
  print(
    "Total:            " + (img.width * img.height) + '\n' +
    "Erros:            " + nErros + '\n' +
    "Erros (%):        " + erroPercentual + '\n' +
    "Falsos Positivos: " + nFalsosPositivos + '\n' +
    "Falsos Negativos: " + nFalsosNegativos + '\n'
  );
}
