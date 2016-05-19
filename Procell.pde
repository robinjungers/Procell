Game game;

TwitterReader twitter;

PShader lightComputer, lightRenderer;
PGraphics background, shadows, scene;

Cell cell;
ArrayList<Entity> entities;

PVector sceneSize;
PVector framePosition;
PVector frameSize;

void setup() {
  // Window Initializion
  size( 512, 512, P2D );
  frameRate( 60 );
  cursor( CROSS );
  textureMode( NORMAL );
  smooth();
  
  // Game launching variables
  game = new Game();
  twitter = new TwitterReader();

  // Shader loading
  lightComputer = loadShader( "light.compute.glsl" );
  lightRenderer = loadShader( "light.render.glsl" );
  
  // Frame initialization
  framePosition = new PVector( 0, 0 );
  frameSize = new PVector( width, height );
  
  // Frame buffers initialization
  background = createGraphics( (int) frameSize.x, (int) frameSize.y, P2D );
  shadows = createGraphics( (int) frameSize.x, (int) frameSize.y, P2D );
  scene = createGraphics( (int) frameSize.x, (int) frameSize.y, P2D );
  sceneSize = new PVector( 2*frameSize.x, 2*frameSize.x );
  
  // Game characters intializion
  cell = new Cell( 0.5*sceneSize.x, 0.5*sceneSize.y );
  entities = new ArrayList<Entity>();
}

void draw() {
  background( 255 );
  
  // Menu if needed
  if ( !game.isReady() ) {
    game.displayMenu();
    return;
  }
  
  // Uniform initialization
  PVector res = new PVector( frameSize.x, frameSize.y );
  lightComputer.set( "resolution", res );
  lightRenderer.set( "resolution", res );
  
  // Change value for faster/sharper shadows
  // Big values will make shaders miss thiner strokes
  lightComputer.set( "sharpness", 2.0 );
  lightRenderer.set( "lightIntensity", cell.getLightIntensity() );
  
  // Frame background construction
  background.beginDraw();
  background.background( 8, 7, 22 );
  background.endDraw();
  
  // Scene construction
  scene.beginDraw();
  scene.clear();
  scene.translate( scene.width/2-cell.getPosition().x, scene.height/2-cell.getPosition().y );
  for ( Entity e: entities ) {
    if ( e.isOnScreen( frameSize ) ) {
      e.setReference( cell );
      e.setSurroundings( entities );
      e.update();
      e.displayOn( scene );
    }
  }
  scene.endDraw();
  
  // Shadow casting
  shadows.beginDraw();
  shadows.clear();
  shadows.image( scene, 0, 0 );
  shadows.filter( lightComputer );
  shadows.filter( lightRenderer );
  shadows.endDraw();
  
  // Background Drawing
  image( background, framePosition.x, framePosition.y );
  
  // Shadow buffer drawing
  image( shadows, framePosition.x, framePosition.y );
  
  // Scene buffer drawing
  image( scene, framePosition.x, framePosition.y );
  
  // Player drawing
  cell.move( mouseX-width/2, mouseY-height/2 );
  cell.update();
  cell.displayAt( framePosition, frameSize );
}

void keyPressed() {
  if ( game.isReady() ) return;
  
  if ( key == BACKSPACE ) {
    game.backspaceTopicString();
  } else if ( key == ENTER || key == RETURN ) {
    game.pushTopicTo( twitter );
    twitter.buildEntities( entities );
  } else {
    game.addToTopicString( key );
  }
  
}