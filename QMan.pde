import gifAnimation.*;

import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

// Need G4P library
import g4p_controls.*;

import java.awt.Font;
import java.awt.*;

Nut nut;
boolean isNut = false;

Sprite squirrel;
boolean stunEnemies = false;

int min_x = 64;
int min_y = 100;
int max_x = 576;
int max_y = 512;
int grid_size = 64;

final int NORTH = 0;
final int WEST = 1;
final int SOUTH = 2;
final int EAST = 3;

int obstacleCount = 5;

int tilesFlipped;
int moves = 0;

Player player;
ArrayList<Enemy> enemies;
ArrayList<Tile> tiles;
// Actual number of tiles and locations
ArrayList<PVector> allTilesOnMap;
// Available tiles after giving to the flippable ( OBSTACLES )
ArrayList<PVector> allAvailableTilesOnMap;
ArrayList<Sprinkler> sprinklers;
ArrayList<Obstacle> obstacles;

boolean playing = false;
boolean win = false;

int squirrelRot = 0;
int sCounter = 0;
int gCounter = 0;

PVector [][] tileMap = new PVector[8][7] ;

// IMAGES
ArrayList<PImage> obstacleImages;
ArrayList<Gif> sprinklerImages;
Sprite playerSprite;
Sprite enemySprite;
Sprite enemySprite1;
Sprite squirrelSprite;
Sprite nutSprite;
Gif grassImage;

public void setup() {
  size(640, 640, JAVA2D);
  frameRate(60);
  createGUI();
  customGUI();
  // Place your setup code here
  background(loadImage("bg.jpg"));

  InstantiateLists();
  LoadImages();
}

void InstantiateLists() {
  tiles = new ArrayList<Tile>();
  enemies = new ArrayList<Enemy>();
  obstacles = new ArrayList<Obstacle>();
  sprinklers = new ArrayList<Sprinkler>();


  obstacleImages = new ArrayList<PImage>();
  sprinklerImages = new ArrayList<Gif>();
}
void LoadImages() {

  for (int i = 0; i < obstacleCount; i++)
    obstacleImages.add(loadImage("obstacles/obstacle"+i+".png"));


  for (int i = 0; i < 2; i++)
    sprinklerImages.add(new Gif(this, "sprinkler"+i+".gif"));

  playerSprite = new Sprite(this, "QMan.png", 1, 1, 100);
  enemySprite = new Sprite(this, "Enemy.png", 1, 1, 100);
  enemySprite1 = new Sprite(this, "Enemy.png", 1, 1, 100);

  squirrelSprite = new Sprite(this, "squirrel.png", 1, 1, 100);
  nutSprite = new Sprite(this, "nut.png", 1, 1, 100);
  grassImage = new Gif(this, "grass.gif");
}

void playGame() {
  fillGridArray();
  createObstacles();
  createTileArray();
  setupSprinklers();

  tilesFlipped = 0;
  moves = 0;
  isNut = false;
  stunEnemies = false;
  stunTimer = 0;
  gCounter = 0;
  sCounter = 0;
  squirrelRot = 0;

  player = new Player(new PVector(64, 100), playerSprite);

  enemies.add(new Enemy(new PVector(512, 100), enemySprite));
  enemies.add(new Enemy(new PVector(512, 484), enemySprite1));
  playing = true;
}

void resetGame() {
  println("Reset");
  allTilesOnMap.clear();
  allAvailableTilesOnMap.clear();
  enemies.clear();
  tiles.clear();
  obstacles.clear();
  sprinklers.clear();
  win = false;
  playGame();
}

public void draw() {
  // background(230);
  if (playing) {
    background(#0000ff);
    rectMode(CORNER);
    drawObstacles();
    drawTiles();
    drawSprinklers();

    if (isNut) nut.draw();
    else {
      double nut_probability = 0.005;
      int randomNumber = (int)(random(0, 1000));
      // println("randomNumber: " + randomNumber);

      if (randomNumber <= nut_probability*1000) dropNut();
    }

    player.draw();

    for (Enemy e : enemies) { 
      if (e.moveTimer == 0 && !stunEnemies) e.chase(player);
      e.moveTimer++;
      if (e.moveTimer >= 60) e.moveTimer = 0;
      e.draw();
    }

    movesLabel.setText("Amount of Steps: " + moves);
    if (stunEnemies) stunTheEnemies();
    checkIfHitNut();
    checkIfWon();
    checkIfLost();
    // println("tilesFlipped : " + tilesFlipped);
  }
  if (win) {
    background(#0000ff);
    drawObstacles();
    drawSprinklers();

    switch(gCounter) {
    case 0: 
      runSprinklerAnimation();
      break;
    case 60:
    case 120:
    case 180:
      grassImage.play();
      break;
    case 90:
    case 150:
      grassImage.pause();
      break;
    case 209:
      grassImage.stop();
      break;
    }
    drawGrass();
    if (gCounter < 210) gCounter++;
  }
}

void drawObstacles() {
  for (Obstacle o : obstacles) {
    o.draw();
  }
}

void drawTiles() {
  for (Tile t : tiles)
    t.draw();
}

void drawSprinklers() {
  for (Sprinkler s : sprinklers)
    s.draw();
}

void fillGridArray() {
  int x_array_pos = 0;
  int y_array_pos = 0;

  allTilesOnMap = new ArrayList<PVector>();
  allAvailableTilesOnMap = new ArrayList<PVector>();
  for ( int x=min_x; x<max_x; x+=grid_size ) {
    for ( int y=min_y; y<max_y; y+=grid_size ) {
      allTilesOnMap.add(new PVector(x, y));
      allAvailableTilesOnMap.add(new PVector(x, y));

      tileMap[x_array_pos][y_array_pos] = new PVector(x, y);
      y_array_pos++;
    }
    x_array_pos++;
    y_array_pos = 0;
  }
}

void createTileArray() {
  /*
  ArrayList<Integer>colors = new ArrayList<Integer>();
   colors.add(#7628ca);
   colors.add(#ffff00);
   colors.add(#ff8f00);
   */

  // Create the Tiles
  for (int i = 0; i < allAvailableTilesOnMap.size(); i++)
    tiles.add(new Tile(new PVector(allAvailableTilesOnMap.get(i).x, allAvailableTilesOnMap.get(i).y)));
  allAvailableTilesOnMap.clear();
}

void createObstacles() {
  for (int i = 0; i < obstacleCount; i++) {

    PVector randomPosition = null;

    do {
      int randomX = (int)(random(1, 7));
      int randomY = (int)(random(1, 6));

      randomPosition = tileMap[randomX][randomY];
    } 
    while (obstacles.contains (new Obstacle (randomPosition)));

    // int randomIndex = (int)(random(0, allAvailableTilesOnMap.size()));
    // PVector randomPosition = allAvailableTilesOnMap.get(randomIndex);
    allAvailableTilesOnMap.remove(randomPosition);

    obstacles.add(new Obstacle(randomPosition, obstacleImages.get(i)));
  }
}

void setupSprinklers() {
  int num = 0;
  boolean first = true;
  int x = 0;
  // Create the Sprinklers
  for ( int i = 0; i < 2; i++ ) {
    for ( int y = min_y; y < max_y; y+=grid_size ) {
      if (first) {
        x = 0;
        num = 0;
      }
      else {
        x = width - 64;
        num = 1;
      }
      Sprinkler s = new Sprinkler(new PVector(x, y), sprinklerImages.get(num));
      sprinklers.add(s);
    }
    first = !first;
  }
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI() {
  title.setFont(new Font("Dialog", Font.PLAIN, 24));
  movesLabel.setFont(new Font("Dialog", Font.PLAIN, 24));
  movesLabel.setVisible(false);
}

public void startGame() {
  println("started");  
  playGame();
}

void checkIfWon() {
  if (tilesFlipped == tiles.size()) {
    println("YOU WIN!");
    playing = false;
    win = true;
  }
}

void checkIfLost() {
  for ( Enemy e : enemies ) {
    if ( e.getSprite().bb_collision(player.getSprite()) ) {
      println("YOU LOSE!");
      playing = false;
    }
  }
}

void drawGrass() {
  for ( Tile t : tiles ) {
    image(grassImage, t.getLoc().x, t.getLoc().y);
  }
}

void runSprinklerAnimation() {
  for ( Sprinkler s : sprinklers ) {
    s.play();
  }
}

void checkIfOnTile() {
  for ( Tile t : tiles ) {
    PVector playLoc = player.getLoc();
    PVector tileLoc = t.getLoc();
    if ((( playLoc.x > tileLoc.x )           && ( playLoc.x < tileLoc.x + t.w )           && ( playLoc.y > tileLoc.y )           && ( playLoc.y < tileLoc.y + t.h )) ||
      (( playLoc.x > tileLoc.x )           && ( playLoc.x < tileLoc.x + t.w )           && ( playLoc.y + player.h > tileLoc.y ) && ( playLoc.y + player.h < tileLoc.y + t.h )) ||
      (( playLoc.x + player.w > tileLoc.x ) && ( playLoc.x + player.w < tileLoc.x + t.w ) && ( playLoc.y + player.h > tileLoc.y ) && ( playLoc.y + player.h < tileLoc.y + t.h )) ||
      (( playLoc.x + player.w > tileLoc.x ) && ( playLoc.x + player.w < tileLoc.x + t.w ) && ( playLoc.y > tileLoc.y )           && ( playLoc.y < tileLoc.y + t.h ))) {
      t.flip();
    }
  }
}

void checkIfHitNut() {
  if (!isNut) return;
  if ( player.getSprite().bb_collision(nut.getSprite()) ) {
    println("Got a Nut!");
    stunEnemies = true;
    isNut = false;
    nut = null;
    squirrel = squirrelSprite;
  }
}

void dropNut() {
  if (stunEnemies) return;
  int randomIndex = (int)(random(0, tiles.size()));
  PVector randomPosition = tiles.get(randomIndex).getLoc();
  nut = new Nut(randomPosition, nutSprite);
  isNut = true;
}

int stunTimer = 0;
void stunTheEnemies() {
  if (stunTimer == 150) {
    stunTimer = 0;
    stunEnemies = false; 
    squirrel = null;
    return;
  }
  if (sCounter == 0)
    squirrelRot--;
  sCounter++;
  if (sCounter >= 10)
    sCounter = 0;

  for ( Enemy e : enemies ) {
    squirrel.setXY(e.getLoc().x+32, e.getLoc().y+32);
    squirrel.setRot(squirrelRot);
    squirrel.draw();
  }
  stunTimer++;
}

void keyPressed() {
  switch(key) {
  case 'r':
  case 'R':
    resetGame();
    break;
  case 'w':
  case 'W':
    if (playing) {
      if (!player.willHit(NORTH)) {
        player.move(NORTH);
        checkIfOnTile();
        moves++;
      }
    }
    break;
  case 's':
  case 'S':
    if (playing) {
      if (!player.willHit(SOUTH)) {
        player.move(SOUTH);
        checkIfOnTile();
        moves++;
      }
    }
    break;
  case 'a':
  case 'A':
    if (playing) {
      if (!player.willHit(WEST)) {
        player.move(WEST);
        checkIfOnTile();
        moves++;
      }
    }
    break;
  case 'd':
  case 'D':
    if (playing) {
      if (!player.willHit(EAST)) {
        player.move(EAST);
        checkIfOnTile();
        moves++;
      }
    }
    break;
  default:
    break;
  }
}

void keyReleased() {
}

