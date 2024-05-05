String caminho = "IIIC-24-1641-P1";
PImage imagem, groundTruth;

PImage escalaDeCinza(PImage img, int pesoR, int pesoG, int pesoB)
{
  int pesoSoma = pesoR + pesoG + pesoB;
  PImage aux = createImage(img.width, img.height, RGB);
  for (int i = 0, j = img.width * img.height; i < j; i++)
  {
    aux.pixels[i] = color(
      (
        pesoR * red(img.pixels[i]) +
        pesoG * green(img.pixels[i]) +
        pesoB * blue(img.pixels[i])
      ) / pesoSoma
    );
  }
  return aux;
}

PImage inverter(PImage img)
{
  PImage aux = createImage(img.width, img.height, RGB);
  for (int i = 0, j = img.width * img.height; i < j; i++)
  {
    aux.pixels[i] = color(255 - red(img.pixels[i]));
  }
  return aux;
}


PImage limearizar(PImage img, int threshold)
{
  PImage aux = createImage(img.width, img.height, RGB);
  for (int i = 0, j = img.width * img.height; i < j; i++)
  {
    aux.pixels[i] = color(red(img.pixels[i]) > threshold ? 255 : 0);
  }
  return aux;
}

PImage aplicarKernel(PImage img, float[] kernel, int janela)
{
  PImage aux = createImage(img.width, img.height, RGB);
  
  final int janTam = janela * 2 + 1;
  
  float kernelSoma = 0.0;
  for (int ky = 0; ky < janTam; ky++)
  {
    for (int kx = 0; kx < janTam; kx++)
    {
      kernelSoma += kernel[kx + ky * janTam];
    }
  }
  for (int y = janela; y < img.height - janela; y++)
  {
    for (int x = janela; x < img.width - janela; x++)
    {
      float r = 0, g = 0, b = 0;
      
      for (int ky = 0; ky < janTam; ky++)
      {
        for (int kx = 0; kx < janTam; kx++)
        {
          r += (float)red(img.pixels[x + kx - janela + (y + ky - janela) * img.width]) * kernel[kx + ky * janTam];
          g += (float)green(img.pixels[x + kx - janela + (y + ky - janela) * img.width]) * kernel[kx + ky * janTam];
          b += (float)blue(img.pixels[x + kx - janela + (y + ky - janela) * img.width]) * kernel[kx + ky * janTam];
        }
      }
      
      r /= kernelSoma;
      g /= kernelSoma;
      b /= kernelSoma;
      
      r = max(0.0, min(255.0, r));
      g = max(0.0, min(255.0, g));
      b = max(0.0, min(255.0, b));
      
      aux.pixels[x + y * img.width] = color((int)r, (int)g, (int)b);
    }
  }
  return aux;
}

PImage filtroMedia(PImage img, int janela)
{
  
  float[] kernel = new float[(janela * 2 + 1) * (janela * 2 + 1)];
  for (int i = 0; i < kernel.length; i++)
  {
    kernel[i] = 1.0;
  }
  return aplicarKernel(img, kernel, janela);
}

PImage filtroSobel(PImage img)
{
  PImage aux = createImage(img.width, img.height, RGB);
  PImage aux2 = createImage(img.width, img.height, RGB);
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = (y)*img.width + (x);
      aux.pixels[pos] = color(blue(img.pixels[pos]));
    }
  }
  
  //Kernel
  int[][] gx = {{-1,-2,-1},{0,0,0},{1,2,1}};
  int[][] gy = {{-1,0,1},{-2,0,2}, {-1,0,1}};

  // Filtro de Borda - Sobel
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int jan = 1;
      int pos = (y)*img.width + (x); /* acessa o ponto em forma de vetor */

      float mediaOx = 0, mediaOy = 0;

      // janela tamanho 1
      for (int i = jan*(-1); i <= jan; i++) {
        for (int j = jan*(-1); j <= jan; j++) {
          int disy = y+i;
          int disx = x+j;
          if (disy >= 0 && disy < img.height &&
            disx >= 0 && disx < img.width) {
            int pos_aux = disy * img.width + disx;
            float Ox = red(aux.pixels[pos_aux]) * gx[i+1][j+1];
            float Oy = red(aux.pixels[pos_aux]) * gy[i+1][j+1];
            mediaOx += Ox;
            mediaOy += Oy;
          }
        }
      }

      // Raiz da soma ao quadrado
      float mediaFinal = sqrt(mediaOx*mediaOx + mediaOy*mediaOy);

      //Absoluto de cada e soma
      //float mediaFinal = abs(mediaOx) + abs(mediaOy);

      // Absoluto da soma geral
      //float mediaFinal = abs(mediaOx + mediaOy);

      // Soma
      //float mediaFinal = mediaOx + mediaOy;

      // Multiplicação
      //float mediaFinal = mediaOx * mediaOy;

      // Limiarização
      if (mediaFinal > 255) mediaFinal = 255;
      if (mediaFinal < 0) mediaFinal = 0;

      aux2.pixels[pos] = color(mediaFinal);
    }
  }
  
  return aux2;
}

PImage recortar(PImage img, int x0, int y0, int x1, int y1, color fundo)
{
  PImage aux = createImage(img.width, img.height, RGB);
  
  for (int y = 0; y < img.height; y++)
  {
    for (int x = 0; x < img.width; x++)
    {
      aux.pixels[x + y * img.width] = 
        x >= x0 && x < x1 && y >= y0 && y < y1 ?
        img.pixels[x + y * img.width] :
        fundo;
    }
  }
  
  return aux;
}

int mapPrint(int val, int a, int b, int c, int d)
{
  int aux = (int)map(val, a, b, c, d);
  println(aux);
  return aux;
}

void imprimirResultados(PImage img)
{
  int nFalsosPositivos = 0;
  int nFalsosNegativos = 0;
  int nErros = 0;
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
  print(
    "Total:            " + (img.width * img.height) + '\n' +
    "Erros:            " + nErros + '\n' +
    "Erros (%):        " + ((float)nErros / (float)(img.width * img.height) * 100.0) + '\n' +
    "Falsos Positivos: " + nFalsosPositivos + '\n' +
    "Falsos Negativos: " + nFalsosNegativos + '\n'
  );
}

void setup()
{
  size(1600, 800);
  noLoop();
  
  imagem = loadImage(caminho + ".jpg");
  groundTruth = loadImage(caminho + "_GT1.bmp");
}

void draw()
{    
  PImage saida = createImage(imagem.width, imagem.height, RGB);
  
  saida = escalaDeCinza(imagem, 1, 0, 2);
  
  saida = limearizar(saida, 108);
    
  saida = recortar(saida, 797, 44, 1997, 456, 0xffffff);
 
  PImage segmentada = createImage(imagem.width, imagem.height, RGB);
  for (int i = imagem.width * imagem.height - 1; i >= 0; i--)
    segmentada.pixels[i] = (red(saida.pixels[i]) != 0 ? 0 : imagem.pixels[i]);
 
  imprimirResultados(saida);
 
  image(
    imagem,
    0,
    0 * height / 4,
    width,
    height / 4 - 10
  );
  image(
    groundTruth,
    0, 
    1 * height / 4, 
    width, 
    height / 4 - 10
  );
  image(
    saida,
    0,
    2 * height / 4,
    width, 
    height / 4 - 10
  );
  image(
    segmentada,
    0,
    3 * height / 4,
    width, 
    height / 4 - 10
  );
  save(caminho + "_Resultado.bmp");
  
}
