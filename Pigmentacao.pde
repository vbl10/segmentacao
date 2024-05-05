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
  save("IIIC23_L.jpg");
}
