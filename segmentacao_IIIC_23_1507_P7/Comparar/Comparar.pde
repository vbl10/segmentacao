PImage img;

void setup() {
  size(1282, 114);
  img = loadImage("ICC.png"); 
  img.resize(width, height); 
  image(img, 0, 0); 
noLoop(); 
}

void draw() {
  loadPixels();

  // Filtro Sobel
  float[][] sobelX = {{-1, 0, 1},
                      {-2, 0, 2},
                      {-1, 0, 1}};
  float[][] sobelY = {{1, 2, 1},
                      {0, 0, 0},
                      {-1, -2, -1}};

  for (int x = 1; x < width - 1; x++) {
    for (int y = 1; y < height - 1; y++) {
      float sumX = 0;
      float sumY = 0;

      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int idx = (x + i) + (y + j) * width;
          sumX += brightness(img.pixels[idx]) * sobelX[i + 1][j + 1];
          sumY += brightness(img.pixels[idx]) * sobelY[i + 1][j + 1];
        }
      }

      float magnitude = sqrt(sumX * sumX + sumY * sumY);
      pixels[x + y * width] = color(255 - magnitude);
    }
  }

  updatePixels();
    imprimirResultados(img);
    save("ICC_23_L.png");
}
void imprimirResultados(PImage img)
{
  PImage groundTruth = loadImage("IIIC-23-1506-P7_GT1.bmp"); // Carregar a imagem de referência
  groundTruth.loadPixels(); // Carrega os pixels da imagem de referência
  int nFalsosPositivos = 0;
  int nFalsosNegativos = 0;
  int nErros = 0;
  img.loadPixels(); // Carrega os pixels da imagem processada
  for (int y = 0; y < img.height; y++)
  {
    for (int x = 0; x < img.width; x++)
    {
      if (red(groundTruth.pixels[x + y * img.width]) == 0)
      {
        if (red(img.pixels[x + y * img.width]) != 0)
        {
          nFalsosNegativos++;
        }
      }
      else if (red(img.pixels[x + y * img.width]) == 0)
      {
        nFalsosPositivos++;
      }
    }
  }
  nErros = nFalsosPositivos + nFalsosNegativos;
  println(
    "Total:            " + (img.width * img.height) + '\n' +
    "Erros:            " + nErros + '\n' +
    "Erros (%):        " + ((float)nErros / (float)(img.width * img.height) * 100.0) + '\n' +
    "Falsos Positivos: " + nFalsosPositivos + '\n' +
    "Falsos Negativos: " + nFalsosNegativos + '\n'
  );
 
}
