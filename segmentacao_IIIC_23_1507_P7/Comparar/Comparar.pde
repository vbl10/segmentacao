PImage img;
int limiar = 128; // Limiar para a limiarização

void setup() {
  size(1218, 124);
  noLoop();

  img = loadImage("ICC.png");
  img.loadPixels(); // Carrega os pixels da imagem
  for (int j = 0; j < img.pixels.length; j++) {
    int cor = img.pixels[j]; // Obtém a cor do pixel atual
    // Calcula a média das componentes de cor para obter a escala de cinza
    int cinza = (int)(red(cor) * 0.39 + green(cor) * 0.59 + blue(cor) * 0.11);
    // Limiarização
    if (cinza > limiar) {
      img.pixels[j] = color(255); // Define o pixel como branco
    } else {
      img.pixels[j] = color(0); // Define o pixel como preto
    }
  }
  img.updatePixels(); // Atualiza os pixels da imagem após aplicar as alterações
}

void draw() {
  image(img, 0, 0); // Exibe a imagem processada
  imprimirResultados(img); // Chamada da função para imprimir os resultados
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
