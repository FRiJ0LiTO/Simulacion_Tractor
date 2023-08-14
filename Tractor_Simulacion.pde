import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer sound1;

PImage cosechadoraImg;
PImage tractorImg;

int numRows = 10;
int numCols = 10;
float cellSize;

Cosechadora[] cosechadoras;
Tractor[] tractors;

boolean[][] harvested;

void setup() {
  size(800, 800);
  cellSize = width / numCols;
  
  minim = new Minim(this);
  sound1 = minim.loadFile("C:/Users/cabre/Downloads/tractor-sound.mp3");
  
  tractorImg = loadImage("C:/Users/cabre/Downloads/tractor.png");
  cosechadoraImg = loadImage("C:/Users/cabre/Downloads/cosechadora.png");
  cosechadoraImg.resize(int(cellSize), int(cellSize));
  
  harvested = new boolean[numCols][numRows];
  
  cosechadoras = new Cosechadora[1];
  cosechadoras[0] = new Cosechadora(1, color(255, 0, 0));
  
  tractors = new Tractor[1];
  tractors[0] = new Tractor();
  
  tractors[0].y = 0;
}

void draw() {
  noStroke(); // Desactiva el trazo de las líneas
  background(200);
  
  boolean allHarvested = true; // Variable para rastrear si todas las celdas están cosechadas
  
  for (int i = 0; i < numRows; i++) {
    for (int j = 0; j < numCols; j++) {
      if (!harvested[j][i]) {
        allHarvested = false; // Si hay al menos una celda no cosechada, cambia la variable a falso
        fill(245, 222, 179);
        rect(j * cellSize, i * cellSize, cellSize, cellSize);
      } else {
        fill(139, 69, 19);
        rect(j * cellSize, i * cellSize, cellSize, cellSize);
      }
    }
  }
  
  if (allHarvested) { // Si todas las celdas están cosechadas
    cosechadoras[0].x = 10; 
    cosechadoras[0].y = 710;
    cosechadoras[0].isStopped = true; // Detener definitivamente
  }
  
  for (Cosechadora cosechadora : cosechadoras) {
    cosechadora.move();
    cosechadora.update();
  }
  
  for (Tractor tractor : tractors) {
    tractor.move(cosechadoras[0]);
    tractor.update();
  }
}



class Cosechadora {
  float x, y;
  color fillColor;
  float capacity = 0;
  float maxCapacity = 60;
  float speed = 2;
  float loadedSpeed = 1;
  int direction = 1;
  boolean isFull = false;
  boolean isStopped = false;
  long stopTime; // Variable para rastrear el tiempo de parada
  final int waitTime = 15000; // 15 segundos en milisegundos
  
  Cosechadora(int id, color fillColor) {
    this.fillColor = fillColor;
    x = (id - 1) * (width / 3);
  }
  
void move() {
  if (!isStopped) {
    float currentSpeed = speed;
    
    x += currentSpeed * direction;
    if (x >= width || x <= -cellSize) {
      if (!sound1.isPlaying()) {
        sound1.loop();
      }
      x = constrain(x, 0, width - cellSize);
      y += cellSize;
      direction *= -1;
      
      if (y >= height) {
        y = 0;
      }
      if (isFull) {
        isStopped = true;
        sound1.pause();
        stopTime = millis(); // Almacena el tiempo cuando se detuvo la cosechadora    
      }
    }
  } else {
    if (!sound1.isPlaying()) {
      sound1.loop();
    }
  }
}


  
  void update() {
    int col = int(x / cellSize);
    int row = int(y / cellSize);
    
    print(capacity);
    if (col >= 0 && col < numCols && row >= 0 && row < numRows) {
      if (!harvested[col][row] && capacity < maxCapacity) {
        capacity += 1;
        harvested[col][row] = true;
      } else if (capacity >= maxCapacity) {
        isFull = true;
        isStopped = true;
      }
    }
    if (isStopped && millis() - stopTime >= waitTime) {
    isStopped = false;
    capacity = 0;
  }
    
    
    // Dibuja la imagen de la cosechadora en un rectángulo más grande
    float imgSize = cellSize * 1.5; // Ajusta el tamaño de la imagen aquí
    float imgX = x - (imgSize - cellSize) / 2;
    float imgY = y - (imgSize - cellSize) / 2;
    image(cosechadoraImg, imgX, imgY, imgSize, imgSize);
   
  }
}

class Tractor {
  float x, y;
  float targetX, targetY;
  float speed = 2;
  
  Tractor() {
    x = -cellSize; // Inicialmente fuera de la pantalla
    y = -cellSize;
  }
  
  boolean approachingCosechadora = true; // Variable para rastrear si el tractor se está acercando

  void move(Cosechadora cosechadora) {
    if (cosechadora.isStopped) {
      if (approachingCosechadora) {
        targetX = cosechadora.x;
        targetY = cosechadora.y - cellSize;

        if (dist(x, y, targetX, targetY) > 1) {
          float dx = targetX - x;
          float dy = targetY - y;
          float angle = atan2(dy, dx);
          x += cos(angle) * speed;
          y += sin(angle) * speed;
        } else {
          approachingCosechadora = false; // Cambia a alejarse después de acercarse
          targetX = -cellSize; // Cambia el objetivo al inicio
          targetY = -cellSize;
        }
      } else { // Si está alejándose
        if (dist(x, y, targetX, targetY) > 1) {
          float dx = targetX - x;
          float dy = targetY - y;
          float angle = atan2(dy, dx);
          x += cos(angle) * speed;
          y += sin(angle) * speed;
        } else {
          approachingCosechadora = true; // Cambia a acercarse después de alejarse
        }
      }
    }
  }
  
  void update() {
    image(tractorImg, x, y, cellSize, cellSize);
  }
}
