PImage img;
int limiar = 128; // Limiar para a limiarização

void setup() {
  size(1218, 124);
  noLoop();

  img = loadImage("MB-TaruPramana-P29.jpg");
  img.loadPixels(); 
  for (int j = 0; j < img.pixels.length; j++) {
    int cor = img.pixels[j]; 
    int cinza = (int)(red(cor) * 0.3 + green(cor) * 0.7 + blue(cor) * 0.26);
    // Limiarização
    if (cinza > limiar) {
      img.pixels[j] = color(255); 
      img.pixels[j] = color(0); 
    }
  }
  img.updatePixels(); 
}

void draw() {
  image(img, 0, 0); 
  imprimirResultados(img); 
}

void imprimirResultados(PImage img)
{
  PImage groundTruth = loadImage("MB-TaruPramana-P29_GT1.bmp"); 
  groundTruth.loadPixels(); 
  int nFalsosPositivos = 0;
  int nFalsosNegativos = 0;
  int nErros = 0;
  img.loadPixels(); 
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
