String caminho = "MB-TaruPramana-P30";
PImage imagem, groundTruth;

float mapX(float a, float b)
{
  float aux = map((float)mouseX, 0.0, (float)width, a, b);
  return aux;
}

float mapY(float a, float b)
{
  float aux = map((float)mouseY, 0.0, (float)height, a, b);
  return aux;
}

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


PImage binarizar(PImage img, int threshold)
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
    kernel[i] = 1.0 / (float)kernel.length;
  }
  return aplicarKernel(img, kernel, janela);
}

PImage filtroGauss(PImage img)
{
  float[] kernel = new float[]
  {
    0.0625, 0.125, 0.0625,
    0.125, 0.25, 0.125,
    0.0625, 0.125, 0.0625
  };
  return aplicarKernel(img, kernel, 1);
}

PImage filtroSobel(PImage img)
{
  PImage aux = createImage(img.width, img.height, RGB);
  PImage aux2 = createImage(img.width, img.height, RGB);
  float[] aux3 = new float[img.width * img.height];
  float minVal = 100000.0, maxVal = -100000.0;
  
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
      //if (mediaFinal > 255) mediaFinal = 255;
      //if (mediaFinal < 0) mediaFinal = 0;

      if (mediaFinal > maxVal) maxVal = mediaFinal;
      if (mediaFinal < minVal) minVal = mediaFinal;
      
      aux3[pos] = mediaFinal;
    }
  }
  
  for (int i = img.width * img.height - 1; i >= 0; i--)
    aux2.pixels[i] = color((int)map(aux3[i], minVal, maxVal, 0.0, 255.0));
    
  //for (int i = img.width * img.height - 1; i >= 0; i--)
    //aux2.pixels[i] = color((int)max(min(aux3[i], 255.0), 0.0));
  
  return aux2;
}

PImage equalizarHistograma(PImage img)
{
  PImage saida = createImage(img.width, img.height, RGB);
  
  int[] nk = new int[256];
  float[] p = new float[256];
  float[] s = new float[256];
  int[] ns = new int[256];
  float somatorio = 0;
  
  for (int i = 0; i < 256; i++) {
    nk[i] = 0;
  }

  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = x + y * img.width;
      int val = (int)red(img.pixels[pos]);
      nk[val]++;
    }
  }

  for (int i = 0; i < 256; i++) {
    p[i] = (float)nk[i] / (float)(img.width*img.height);
    somatorio += p[i];
    s[i] = somatorio;
    ns[i] = int(s[i]*255 + 0.5);
  }


  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = x + y * img.width;
      int val = ns[(int)red(img.pixels[pos])];
      saida.pixels[pos] += color(val);
    }
  }
  
  return saida;
}

interface PixelShader { color main(color in); }
PImage aplicarPixelShader(PImage img, PixelShader ps)
{
  PImage aux = createImage(img.width, img.height, RGB);
  
  for (int y = 0; y < img.height; y++)
  {
    for (int x = 0; x < img.width; x++)
    {
      aux.pixels[x + y * img.width] = ps.main(img.pixels[x + y * img.width]);
    }
  }
  
  return aux;
}

interface OperadorBinario { int main(int a, int b); }
PImage operacaoBinaria(PImage a, PImage b, OperadorBinario op)
{
  PImage saida = createImage(a.width, a.height, RGB);
  
  for (int i = a.width * a.height - 1; i >= 0; i--)
    saida.pixels[i] = color(op.main((int)red(a.pixels[i]), (int)red(b.pixels[i])));
  
  return saida;
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
  
  saida = escalaDeCinza(imagem, 1, 1, 1);
  
  //melhorar contraste
  saida = aplicarPixelShader(saida, new PixelShader(){
    @Override
    color main(color in)
    {
      return color(4.7712 * (float)red(in) - 382.5);
    }
  });
  
  PImage rec1 = recortar(saida, 219, 31, 1605, 299, 0xffffff);
  PImage rec2 = recortar(saida, 2577, 35, 3726, 363, 0xffffff);
  saida = operacaoBinaria(rec1, rec2, new OperadorBinario() {
    @Override
    int main(int a, int b)
    {
      return (a + b) / 2;
    }
  });
  
  saida = binarizar(saida, 177);
   
  
  //RESULTADOS... 
  
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

  save(caminho + "_Resultado.jpg");
  
}
