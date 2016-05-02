PShader lightComputer, lightRenderer;
PGraphics scene;

Cell cell;
ArrayList<Entity> entities;

void setup() {
  size( 512, 512, P2D );
  //pixelDensity( displayDensity() );
  frameRate( 60 );
  cursor( CROSS );
  textureMode(NORMAL);
  smooth();

  // SHADERS
  lightComputer = loadShader( "light.compute.glsl" );
  lightRenderer = loadShader( "light.render.glsl" );
  scene = createGraphics( width, height, P2D );

  // GAME VARIABLES
  entities = new ArrayList<Entity>();
  cell = new Cell();
  for ( int i = 0; i < 5; i++ ) {
    Virus virus = new Virus();
    entities.add( (Entity)virus );
  }
}

void draw() {
  background( 8, 7, 22 );
  PVector res = new PVector(width, height);
  lightComputer.set( "resolution", res );
  lightComputer.set( "sharpness", 1.0 );
  lightRenderer.set( "resolution", res );
  
  // DRAWINGS
  scene.beginDraw();
  scene.clear();
  scene.translate( width/2-cell.getPosition().x, height/2-cell.getPosition().y );
  for ( int i = 0; i < entities.size(); i++ ) {
    entities.get(i).update();
    entities.get(i).display( scene );
  }
  scene.endDraw();
  
  PGraphics actualScene = createGraphics( width, height, P2D );
  actualScene.beginDraw();
  actualScene.image( scene, 0, 0 );
  actualScene.endDraw();
  
  // SHADOW CASTING
  scene.beginDraw();
  scene.filter( lightComputer );
  scene.filter( lightRenderer );
  scene.endDraw();
  image( scene, 0, 0 );
  image( actualScene, 0, 0 );
  
  // MAIN CHARACTER
  lightRenderer.set( "lightIntensity", cell.getLightIntensity() );
  cell.update();
  cell.display();
  
  // INFO
  text( frameRate, 20, 20 );
} 