PShader lightComputer, lightRenderer;
PGraphics scene, actualScene;

PVector sceneSize;

Cell cell;
ArrayList<Entity> entities;

void setup() {
  // Window Initializion
  size( 512, 512, P2D );
  frameRate( 60 );
  cursor( CROSS );
  textureMode( NORMAL );
  smooth();
  sceneSize = new PVector( 3*width, 3*height );

  // Shader loading
  lightComputer = loadShader( "light.compute.glsl" );
  lightRenderer = loadShader( "light.render.glsl" );
  
  // Texture buffers initializion
  scene = createGraphics( width, height, P2D );
  actualScene = createGraphics( width, height, P2D );

  // Game characters intializion
  cell = new Cell( 0.5*sceneSize.x, 0.5*sceneSize.y );
  entities = new ArrayList<Entity>();
  for ( int i = 0; i < 30; i++ ) {
    float x = noise( i );
    float y = noise( x, i );
    Virus virus = new Virus( x*sceneSize.x, y*sceneSize.y );
    virus.setReference( (Entity) cell );
    entities.add( (Entity) virus );
  }
}

void draw() {
  background( 8, 7, 22 );
  
  // Uniform initialization
  PVector res = new PVector( width, height );
  lightComputer.set( "resolution", res );
  lightRenderer.set( "resolution", res );
  // Change value for faster/sharper shadows
  // Big values will make shaders miss thiner strokes
  lightComputer.set( "sharpness", 2.0 );
  lightRenderer.set( "lightIntensity", cell.getLightIntensity() );
  
  // Scene construction
  scene.beginDraw();
  scene.clear();
  scene.translate( width/2-cell.getPosition().x, height/2-cell.getPosition().y );
  for ( int i = 0; i < entities.size(); i++ ) {
    Entity e = entities.get(i);
    if ( e.needsToBeDrawn() ) {
      e.update();
      e.displayOn( scene );
    }
  }
  scene.endDraw();
  
  actualScene.beginDraw();
  actualScene.clear();
  actualScene.image( scene, 0, 0 );
  actualScene.endDraw();
  
  // Shadow casting
  scene.beginDraw();
  scene.filter( lightComputer );
  scene.filter( lightRenderer );
  scene.endDraw();
  
  // Shadow buffer drawing
  image( scene, 0, 0 );
  
  // Scene buffer drawing
  image( actualScene, 0, 0 );
  
  // Player drawing
  cell.update();
  cell.display();
  
  // Extra infos
  text( frameRate, 20, 20 );
} 