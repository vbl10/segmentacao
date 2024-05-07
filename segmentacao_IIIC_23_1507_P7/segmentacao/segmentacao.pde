void setup() {
  size(1218, 124);
  noLoop();
}

void draw() {
  PImage img = loadImage("IIIC_23_L.jpg"); 
  PImage seg = createImage(img.width, img.height, RGB);

  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) { 
      int pos = y * img.width + x; 
      // Se o pixel na imagem original for preto, vira marrom na imagem segmentada
      if (green(img.pixels[pos]) < 40) {
        seg.pixels[pos] = color(139, 69, 19); // Cor marrom
      } else {
        seg.pixels[pos] = color(0); // Fundo preto
      }
    }
  }

  image(seg, 0, 0); 
  save("IIIC_23_L_segmentacao.jpg");
}
