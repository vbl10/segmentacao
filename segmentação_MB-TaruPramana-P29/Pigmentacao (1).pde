PImage img;
int limiar = 128; 

void setup() {
  size(1218, 124);
  noLoop();

  img = loadImage("ICC.png");
  img.loadPixels(); 
  for (int j = 0; j < img.pixels.length; j++) {
    int cor = img.pixels[j]; 
    int cinza = (int)(red(cor) * 0.39 + green(cor) * 0.59 + blue(cor) * 0.11);
    // Limiarização
    if (cinza > limiar) {
      img.pixels[j] = color(255);
    } else {
      img.pixels[j] = color(0); 
    }
  }
  img.updatePixels(); 
}

void draw() {
  image(img, 0, 0); 
  save("IIIC23_L.jpg");
}
