import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import twitter4j.*; 
import twitter4j.api.*; 
import twitter4j.auth.*; 
import twitter4j.conf.*; 
import twitter4j.json.*; 
import twitter4j.management.*; 
import twitter4j.util.*; 
import twitter4j.util.function.*; 
import java.util.Date; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Procell extends PApplet {

Game game;

TwitterReader twitter;

PShader lightComputer, lightRenderer;
PGraphics background, shadows, scene;

Cell cell;
ArrayList<Entity> entities;

PVector sceneSize;
PVector framePosition;
PVector frameSize;

public void setup() {
  // Window Initializion
  
  frameRate( 60 );
  cursor( CROSS );
  textureMode( NORMAL );
  
  
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
  sceneSize = new PVector( 5*frameSize.x, 5*frameSize.x );
  
  // Game characters intializion
  cell = new Cell( 0.5f*sceneSize.x, 0.5f*sceneSize.y, 20.0f );
  entities = new ArrayList<Entity>();
}

public void draw() {
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
  lightComputer.set( "sharpness", 2.0f );
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
  
  // Tweet display
  for ( Entity e: entities )
    e.talk();
}

public void keyPressed() {
  if ( game.isReady() ) {
    if ( key == ' ' )
      game.stop();
    return;
  }
  
  if ( key == BACKSPACE ) {
    game.backspaceTopicString();
  } else if ( key == ENTER || key == RETURN ) {
    game.pushTopicTo( twitter );
    twitter.buildEntities( entities, sceneSize );
  } else {
    game.addToTopicString( key );
  }
  
}
/**
 * Animator is a static class providing basic animation functions
 * <p>
 * Animator is not characterized by any attributes.
 * </p>
*/
static class Animator {
  
  /**
  * Eases in a value with cubic function
  *
  * @param t
  *          Current time
  * @param b
  *          Begining value
  * @param c
  *          Change value to reach
  * @param d
  *          Total duration desired
  */  
  public static float easeIn( float t, float b , float c, float d ) {
    return c*(t/=d)*t*t + b;
  }
  
  /**
  * Eases out a value with cubic function
  *
  * @param t
  *          Current time
  * @param b
  *          Begining value
  * @param c
  *          Change value to reach
  * @param d
  *          Total duration desired
  */  
  public static float easeOut( float t, float b , float c, float d ) {
    return c*((t=t/d-1)*t*t + 1) + b;
  }
  
  /**
  * Eases in and out a value with cubic function
  *
  * @param t
  *          Current time
  * @param b
  *          Begining value
  * @param c
  *          Change value to reach
  * @param d
  *          Total duration desired
  */  
  public static float easeInOut( float t, float b , float c, float d ) {
    if ((t/=d/2) < 1) return c/2*t*t*t + b;
    return c/2*((t-=2)*t*t + 2) + b;
  }
  
  /**
  * Smooths the change of a value 
  *
  * @param from
  *          Current value to ease
  * @param to
  *          Goal value
  * @param step
  *          Step value
  */    
  public static float ease( float from, float to, float step ) {
    if ( abs(from-to) < step ) return to;
    float dist = step;//pow( abs(from-to), step );
    return from + (from<to ? dist : -dist);
  }
  
  /**
  * Smooths the change of PVector values
  *
  * @param from
  *          Current Pvector to ease
  * @param to
  *          Goal PVector
  * @param step
  *          Step value
  */ 
  public static PVector ease( PVector from, PVector to, float step ) {
    return new PVector( ease(from.x, to.x, step), ease(from.y, to.y, step) );
  }
  
}
/**
 * Bacteria is a undertype of Entity.
 * Therefore, this class inherits of all attributes and methods of Entity
 * <p>
 * A Microbe is characterized by multiple methods normal entities cannot call.
*/
class Bacteria extends Entity {
  
  /**
  * The float orientation is the orientation of the Bacteria (the angle) from the origin.
  * @see Bacteria#displayOn( PGraphics scene )
  */
  private float orientation;
  
  /**
  * The float spread is used to calculate the angle of the Bacteria compared to the origin.
  * @see Bacteria#displayOn( PGraphics scene )
  */
  private float spread;
  
  /**
  * The array of float radiuses represents the list of the sizes of the 64 different vertex that create the membran.
  * @see Bacteria#Bacteria( float x, float y )
  * @see Bacteria#update()
  * @see Bacteria#displayOn( PGraphics scene )
  */
  private float[] radiuses;
  
  /**
  * Bacteria Constructor.
  * <p>
  * When a Bacteria is constructed, it uses the Entity constructor.
  * By that, it gives the x and y parameters and uses 35.0 for the size.
  * Then it creates the orientation to 0.
  * The spread float is at TWO_PI.
  * The array of radiuses is created with a length of 64. All radiuses have a 0.5 value.
  * </p>
  *
  * @param x
  *          position on the x axe of the Bacteria cell
  * @param y
  *          position on the y axe of the Bacteria cell
  * @param size
  *          global size of the Bacteria cell
  */  
  public Bacteria( float x, float y, float size ) {
    super( x, y, size );
    this.radiuses = new float[64];
    for (int i = 0; i < this.radiuses.length; i++) {
      this.radiuses[i] = 0.5f;
    }
    this.orientation = 0.0f;
    this.spread = TWO_PI;
  }
  
  /**
  * Overrides the update() method of Entity
  * Updates the attributes of the Bacteria.
  * The vertex near the player's cell retract when they get touched.
  * The vertex retract in a ellipse way.
  * When not, the Bacteria's membran come back to its original size.
  * Then, the method calls the applyPhysics() method to do the rest of interactions (collision, velocity).
  * Uses an Animator method to animate the growing and retracting of the Bacteria's membran.
  *
  * @see Entity#reference
  * @see Entity#size
  * @see Bacteria#radiuses
  * @see Animator#ease( float from, float to, float step )
  * @see Entity#applyPhysics()
  */
  @Override
  public void update() {
    if ( this.position.dist( this.reference.position ) < 0.9f*this.size ) {
      PVector p = new PVector( -(this.reference.position.x - this.position.x), -(this.reference.position.y - this.position.y) ) ;
      for ( int i = 0; i < this.radiuses.length ; i++ ) {
          float angle = 0.5f *pow( (map(i, 0.0f, 64.0f, this.orientation - this.spread/2, this.orientation + this.spread/2 ) - p.heading()) , 2.f);
          this.radiuses[i] = Animator.ease( this.radiuses[i], min(max(angle,0.2f), 0.5f), 0.04f );
      }
    } else {
      for( int i = 0; i < this.radiuses.length ; i++){
      this.radiuses[i] = Animator.ease( this.radiuses[i], 0.5f, 0.04f );
      }
    }
    this.applyPhysics();
  }
  
  /**
  * Overrides the displayOn( PGraphics scene ) method of Entity
  * Draws the exterior circle of the cell
  * by drawing the 64 different vertex
  *
  * @see Entity#position
  * @see Entity#size
  * @see Bacteria#orientation
  * @see Bacteria#spread
  * @see Bacteria#radiuses
  */ 
  @Override
  public void displayOn( PGraphics scene ) {   
    scene.pushMatrix();
      scene.translate( this.position.x, this.position.y );
      scene.stroke( 255 );
      scene.strokeWeight( 4 );
      scene.noFill();
      scene.beginShape();
      for ( int i = 0; i < 64; i++ ) { 
        float angle = map(i, 0.0f, 63.f, 0.0f, TWO_PI)%TWO_PI;
        float random = 0.5f + 0.5f*noise(0.9f*sin(angle), 0.001f*this.k*millis(), this.k);
        float radius = radiuses[i] * random * this.size;
        scene.vertex( radius*cos(angle), radius*sin(angle) );
      }
      float angle = map(0, 0.0f, 63.f, 0.0f, TWO_PI)%TWO_PI;
      float random = 0.5f + 0.5f*noise(0.9f*sin(angle), 0.001f*this.k*millis(), this.k);
      float radius = radiuses[0] * random * this.size;
      scene.vertex( radius*cos(map(0, 0.0f, 63.f, 0.0f, TWO_PI)), radius*sin(map(0, 0.0f, 63.f, 0.0f, TWO_PI)) );
      scene.endShape();
    scene.popMatrix();
  }
}
/**
 * Cell is a undertype of Entity.
 * Therefore, this class inherits of all attributes and methods of Entity
 * <p>
 * A Cell is characterized by the fact that it's unique. 
 * The only Cell is the player's cell.
 * Therefore it has multiple methods normal entities cannot call.
*/
class Cell extends Entity {
  
  /**
  * The PVector lightIntensity is used for the light shader. It is the color of the light.
  * @see Cell#displayOn( PGraphics scene )
  */
  private PVector lightIntensity;

  /**
  * Cell Constructor.
  * <p>
  * When a Microbe is constructed, it uses the Entity constructor.
  * By that, it gives the x and y parameters and uses 20.0 for the size.
  * And initiates the lightIntensity to a vector of 0.8 x, y and z;
  * </p>
  *
  * @param x
  *          position on the x axe of the Grower cell
  * @param y
  *          position on the y axe of the Grower cell
  * @param size
  *          global size of the Grower cell
  */
  public Cell( float x, float y, float size ) {
    super( x, y, size );
    this.lightIntensity = new PVector( 0.8f, 0.8f, 0.8f );
  }
  
  /**
  * Moves the Cell of a Vector of x and y parameters.
  *
  * @see Cell#velocityCapacity
  * @see Entity#velocity
  * @see Animator#ease( float from, float to, float step )
  * @see Entity#applyPhysics()
  */
  public void move( float x, float y) {
    this.velocity.set(x, y );
    this.velocity.mult( this.velocityCapacity * 0.01f );
  }
  
  /**
  * Get the position of the Cell.
  *
  * @see Entity#position
  * 
  * @return position.
  */
  public PVector getPosition() {
    return this.position;
  }
  
  /**
  * Get the lightIntensity of the Cell.
  *
  * @see Entity#lightIntensity
  * 
  * @return lightIntensity vecto.
  */
  public PVector getLightIntensity() {
    PVector l = new PVector();
    l = lightIntensity.copy();
    l.mult( 0.3f + 0.1f * (1+cos(0.002f*millis())) );
    return l;
  }
  
  /**
  * Overrides the update() method of Entity
  * Updates the attributes of the Cell.
  * The hair near the player's cell retract when they get touched.
  * The hair retract in a ellipse way.
  * When not, the Microbe's hair come back to their original size.
  * Then, the method calls the applyPhysics() method to do the rest of interactions (collision, velocity).
  * Uses an Animator method to animate the growing and ungrowing of the Microbe's hair.
  *
  * @see Entity#velocity
  * @see Entity#position
  */
  @Override
  public void update() {
    this.position.add( this.velocity );
  }
  
  /**
  * Draws the cell
  *
  * @see Entity#position
  * @see Entity#size
  */ 
  public void displayAt( PVector position, PVector size ) {
    pushMatrix();
      translate( position.x + size.x/2, position.y + size.y/2 );
      noStroke();
      fill( 255 );
      ellipse( 0, 0, this.size, this.size );
    popMatrix();
  }
  
}
/**
 * Entity is the class representing a cellular entity on the screen.
 * <p>
 * An entity of Procell's game is characterized by the next information :
 * <ul>
 * <li> A position with x and y coordonates.
 * <li> A velocity permitting the entity to move.
 * <li> A size, depending on which the cell will be small or big.
 * <li> A velocity capacity that permits to change the velocity during interactions.
 * <li> A speech which will contain the tweet information to load.
 * <li> A reference referencing to the player's Cell.
 * <li> A list of the surroundings entities with who the entity will interact (collisions).
 * <li> A k float permitting to use a pseudo-random number.
 * </ul>
 * </p>
*/
public class Entity {
 
  /**
  * The float k is used to randomize different parameters of drawing.
  * @see Entity#Entity( float x, float y, float size )
  * @see Virus#displayOn( PGraphics scene )
  */
  protected float k; 

  /**
  * The PVector position has an x and y parameters and is used to position the entity on the screen.
  * @see Entity#Entity( float x, float y, float size )
  * @see Virus#displayOn( PGraphics scene )
  */
  protected PVector position;
  
  /**
  * The PVector velocity has an x and y parameters and is used to move the entity on the screen.
  * @see Entity#Entity( float x, float y, float size )
  * @see Entity#applyPhysics()
  */
  protected PVector velocity;
  
  /**
  * The float size is used for the size that the entity will take.
  * This is used to calculate collisions for example
  * @see Entity#Entity( float x, float y, float size )
  * @see Entity#setSurroundings( ArrayList<Entity> others )
  */
  protected float size;
  
  /**
  * The float velocityCapacity is used to change the velocity of an Entity from another class
  * @see Entity#Entity( float x, float y, float size )
  * @see Grower#update()
  */
  protected float velocityCapacity;
  
  /**
  * The String speech is used to collect the Tweet that is linked to the entity
  * @see Entity#Entity( float x, float y, float size )
  * @see Entity#setSpeech(String speech)
  * @see Entity#talk()
  */
  protected String speech;
  
  /**
  * The PFont menuFont is used to store a Processing typeface
  * @see Entity#Entity( float x, float y, float size )
  * @see Entity#talk()
  */
  private PFont menuFont;
  
  /**
  * The Entity reference represents the player's cell.
  * All Entities have to get information about the player's cell
  * @see Entity#setReference( Entity other )
  * @see Grower#update()
  */
  protected Entity reference;
  
  /**
  * The ArrayList of Entities surroundingsis represents all the entities near this Entity
  * All Entities have to know about their neighboors for collisions for example.
  * @see Entity#setSurroundings( ArrayList<Entity> others )
  * @see Entity#applyPhysics()
  */
  protected ArrayList<Entity> surroundings;
    
  /**
  * Entity Constructor.
  * <p>
  * When an entity is constructed, the k value is a random of 1.
  * The position is given by the x and y parameters entered.
  * The velocity is null at the start.
  * The size is given by the size parameter entered.
  * The surroundings list is created empty.
  * The velocityCapacity factor is created at 1.
  * The speech is created empty.
  * </p>
  *
  * @param x
  *          position on the x axe of the cell
  * @param y
  *          position on the y axe of the cell
  * @param size
  *          size of the cell
  *
  * @see Entity#size
  * @see Entity#position
  */
  public Entity( float x, float y, float size ) {
    this.k = random(1);
    this.position = new PVector( x, y );
    this.velocity = new PVector( 0, 0 );
    this.size = size;
    this.surroundings = new ArrayList<Entity>();
    this.velocityCapacity = 1.0f;
    this.speech = "";
    this.menuFont = loadFont( "PierSans-14.vlw" );
  }
  
  /**
  * Sets the speech of the entity.
  *
  * @param speech
  *          sentence the cell will "say" when touched
  *
  * @see Entity#speech
  */
  public void setSpeech( String speech ) {
    this.speech = speech;
  }

  /**
  * Set the reference of the Entity.
  *
  * @param other
  *          The entity corresponding to the player's cell.
  *
  * @see Entity#reference
  */
  public void setReference( Entity other ) {
    this.reference = other;
  }
  
  /**
  * Looks at other entities and save the references of the close ones in surroundings
  *
  * @param others
  *          A list of entities that are close to this Entity
  *
  * @see Entity#surroundings
  * @see Entity#position
  */
  public void setSurroundings( ArrayList<Entity> others ) {
    this.surroundings.clear();
    for ( Entity e: others ) {
      if ( this.position.dist( e.position ) < this.size/2 + e.size/2 ) {
        this.surroundings.add( e );
      }
    }
  }
  
  /**
  * Checks if the Entity is visible on screen.
  *
  * @param size
  *          The size of the entity to see if it is on screen
  *
  * @see Entity#reference
  * @see Entity#position
  * @see Entity#size
  *
  * @return boolean if the cell is on screen or not
  */
  public boolean isOnScreen( PVector size ) {
    if ( this.reference != null ) {
      if ( this.position.dist( this.reference.position ) > 0.71f*size.x + this.size ) return false;
    }
    return true;
  }

  /**
  * Applies the basic physics to the Entity as Velocity or Collisions and bouncing
  *
  * @see Entity#position
  * @see Entity#surroundings
  * @see Entity#velocity
  */
  public void applyPhysics() {
    for ( Entity e: this.surroundings ) {
      float c = 0.05f; // Energy factor // 0.05 is calm, 0.5 is very bouncy 
      PVector toAdd = new PVector( c*(this.position.x - e.position.x), c*(this.position.y - e.position.y) );
      this.velocity.add( toAdd.lerp( e.velocity, 0.0f ) );
    }
    this.velocity.mult( 0.9f );
    this.position.add( this.velocity );
  }
  
  /**
  * Displays the stored speech on the main processing window
  *
  * @see Entity#reference
  * @see Entity#position
  * @see Entity#size
  * @see Entity#menuFont
  * @see Entity#speech
  */
  public void talk() {
    if ( this.reference == null ) return;
    if ( this.position.dist( this.reference.position ) > this.size/2 ) return;
    
    fill( 255 );
    noStroke();
    textAlign( CENTER, CENTER );
    textFont( this.menuFont );
    text( this.speech, width/2, 3*height/4 );
  }
  
  /**
  * Updates the arguments of the Entity. Depends on each daughter class.
  */
  public void update() {};
  
  /**
  * Displays the entity in basics on the screen.
  */  
  public void displayOn( PGraphics scene ) {}
  
}
/**
 * Game is the class representing a game setup, providing a menu and launching initialization
 * <p>
 * A Game of Procell is characterized by the next information :
 * <ul>
 * <li> A isReady, defining whether it is ready to launch the game or not
 * <li> A menuFont, providing a Processing typeface 
 * <li> A menuSubFont, providing a secondary bigger Processing typeface 
 * <li> A topic containing the string of the subject for the game
 * </ul>
 * </p>
*/
public class Game {
  
  /**
  * The boolean isReady defines wether the game is ready to play or not
  * @see Game#pushTopicTo( TwitterReader t )
  * @see Game#isReady()
  */
  private boolean isReady;
  
  /**
  * The PFont menuFont stores a processing font for displaying text
  * @see Game#displayMenu()
  */
  private PFont menuFont;
  
  /**
  * The PFont menuSubFont stores a secondary, bigger, processing font for displaying text
  * @see Game#displayMenu()
  */
  private PFont menuSubFont;
  
  /**
  * The StringBuilder topic is used to store a subject on which the game will launch when ready
  * @see Game#addToTopicString( char c )
  * @see Game#backspaceTopicString()
  * @see Game#pushTopicTo( TwitterReader t )
  */
  private StringBuilder topic;

  /**
  * Game Constructor.
  * <p>
  * When a Game is constructed, its isReady param is set to false
  * The menuFont loads PierSans-14.vlw
  * The menuSubFont loads PierSans-24.vlw, a bigger version
  * The topic is initialized empty
  * </p>
  */
  public Game() {
    this.isReady = false;
    this.menuFont = loadFont( "PierSans-14.vlw" );
    this.menuSubFont = loadFont( "PierSans-24.vlw" );
    this.topic = new StringBuilder("");
  }
  
  /**
  * Returns the current state of isReady.
  *
  * @return The boolean value of isReady
  *
  * @see Game#isReady
  */
  public boolean isReady() {
    return this.isReady;
  }
  
  /**
  * Set the state of isReady to false.
  *
  * @see Game#isReady
  */
  public void stop() {
    this.isReady = false;
  }
  
  /**
  * Displays the menu on the main processing window. 
  *
  * @see Entity#menuFont
  * @see Entity#menuSubFont
  * @see Entity#topic
  */
  public void displayMenu() {
    noStroke();
    fill( 11 );
    rect( 0, 0, width, height );

    fill( 255 );
    textAlign( CENTER, CENTER );
    textFont( this.menuFont );
    text( "enter room with key :", width/2, height/2-50 );
    textFont( this.menuSubFont );
    text( this.topic.toString(), width/2, height/2 );

    if ( this.topic.length() < 1 ) {
      noFill();
      stroke( 255, 100000000*sin(0.08f*frameCount) );
      strokeWeight( 5 );
      line( width/2, height/2-10, width/2, height/2+10 );
    }
  }
  
  /**
  * Add a character to the current topic
  *
  * @param c
  *          The character to add
  *
  * @see Entity#topic
  */
  public void addToTopicString( char c ) {
    this.topic.append( c );
  }

  /**
  * Delete the last character of the topic stored, if long enough.
  *
  * @see Entity#topic
  */
  public void backspaceTopicString() {
    if ( this.topic.length() > 0 )
      this.topic.setLength( this.topic.length() - 1);
  }
  
  /**
  * Provides the current topic to a TwitterReader and switch to ready state.
  *
  * @param t
  *          The TwitterReader you want to provide the topic to
  *
  * @see Entity#topic
  * @see TwitterReader
  */
  public void pushTopicTo( TwitterReader t ) {
    if ( this.topic.length() < 1 ) return;
    this.isReady = true;
    
    fill( 255 );
    textAlign( CENTER, CENTER );
    textFont( this.menuFont );
    text( "loading", width/2, height/2+50 );
    
    t.setTopic( this.topic.toString() );
    t.getResults();
  }
}
/**
 * Grower is a undertype of Entity.
 * Therefore, this class inherits of all attributes and methods of Entity
 * <p>
 * A Grower is characterized by multiple methods normal entities cannot do.
*/
class Grower extends Entity {
  
  private float originalSize;
  
  /**
  * Grower Constructor.
  * <p>
  * When a Grower is constructed, it uses the Entity constructor.
  * By that, it gives the x and y parameters and uses 40.0 for the size.
  * </p>
  *
  * @param x
  *          position on the x axe of the Grower cell
  * @param y
  *          position on the y axe of the Grower cell
  * @param size
  *          global size of the Grower cell
  */
  public Grower( float x, float y, float size ) {
    super( x, y, size );
    this.originalSize = size;
  }
  
  /**
  * Overrides the update() method of Entity
  * Updates the attributes of the Grower cell.
  * Grows when the Grower is in contact with the player's cell.
  * When not, the Grower comes back to its original size.
  * Then, the method calls the applyPhysics() method to do the rest of interactions (collision, velocity).
  * Uses an Animator method to animate the growing and ungrowing of the Grower.
  *
  * @see Entity#reference
  * @see Entity#size
  * @see Entity#velocityCapacity
  * @see Animator#ease( float from, float to, float step )
  * @see Entity#applyPhysics()
  */
  @Override
    public void update() {
    if ( this.position.dist( this.reference.position ) < this.size/2 ) {
      this.size = Animator.ease( this.size, 3*this.originalSize, 10 );
      this.reference.velocityCapacity = 0.5f;
    } else {
      this.size = Animator.ease( this.size, this.originalSize, 10 );
      this.reference.velocityCapacity = 1.0f;
    }
    this.applyPhysics();
  }
  
  /**
  * Overrides the displayOn( PGraphics scene ) method of Entity
  * Draws the exterior circle of the cell
  * Draws the nucleus of the cell
  *
  * @see Entity#position
  * @see Entity#size
  */
  @Override
    public void displayOn( PGraphics scene ) {   
    scene.pushMatrix();
    scene.translate( this.position.x, this.position.y );
    scene.stroke( 255 );
    scene.strokeWeight( 3 );
    scene.noFill();
    scene.ellipse( 0, 0, this.size, this.size );
    float random = noise(0, 0.001f*this.k*millis(), this.k);
    float radius = 0.2f * random * this.size;
    float angle = map(random - 0.5f, 0.0f, 3.0f, 0.0f, TWO_PI );
    scene.stroke( 200, 200, 255 );
    scene.strokeWeight( 4 );
    scene.ellipse( radius*cos(angle), radius*sin(angle), 0.3f*this.size, 0.3f*this.size );
    scene.popMatrix();
  }
}
/**
 * Microbe is a undertype of Entity.
 * Therefore, this class inherits of all attributes and methods of Entity
 * <p>
 * A Microbe is characterized by multiple arguments and methods normal entities cannot call.
*/
class Microbe extends Entity {
  /**
  * The float orientation is the orientation of the Microbe cell (the angle) from the origin.
  * @see Microbe#displayOn( PGraphics scene )
  */
  private float orientation;
  
  /**
  * The float spread is used to calculate the angle of the Microbe compared to the origin.
  * @see Microbe#displayOn( PGraphics scene )
  */
  private float spread;
  
  /**
  * The array of float hairSizes represents the list of the sizes of the 18 different hairs of the Microbe.
  * @see Microbe#Microbe( float x, float y )
  * @see Microbe#update()
  * @see Microbe#displayOn( PGraphics scene )
  */
  private float[] hairSizes;

  /**
  * Microbe Constructor.
  * <p>
  * When a Microbe is constructed, it uses the Entity constructor.
  * By that, it gives the x and y parameters and uses 55.0 for the size.
  * </p>
  *
  * @param x
  *          position on the x axe of the Grower cell
  * @param y
  *          position on the y axe of the Grower cell
  * @param size
  *          global size of the Grower cell
  */
  public Microbe( float x, float y, float size ) {
    super( x, y, size );
    
    this.orientation = 0.0f;
    this.spread = TWO_PI;
    this.hairSizes = new float[18];
    for (int i = 0; i < this.hairSizes.length; i++) {
      this.hairSizes[i] = 0.3f;
    }
  }
    
  /**
  * Overrides the update() method of Entity
  * Updates the attributes of the Microbe cell.
  * The hair near the player's cell retract when they get touched.
  * The hair retract in a ellipse way.
  * When not, the Microbe's hair come back to their original size.
  * Then, the method calls the applyPhysics() method to do the rest of interactions (collision, velocity).
  * Uses an Animator method to animate the growing and ungrowing of the Microbe's hair.
  *
  * @see Entity#reference
  * @see Entity#size
  * @see Microbe#hairSizes
  * @see Animator#ease( float from, float to, float step )
  * @see Entity#applyPhysics()
  */
  @Override
  public void update() {
    if ( this.position.dist( this.reference.position ) < 1.2f*this.size ) {
      PVector p = new PVector( (this.reference.position.x - this.position.x), (this.reference.position.y - this.position.y) ) ;
      for ( int i = 0; i < this.hairSizes.length ; i++ ) {
          float angle = 0.5f *pow( (map(i, 0.0f, 18.0f, this.orientation - this.spread/2, this.orientation + this.spread/2 ) - p.heading()) , 2);
          
          this.hairSizes[i] = Animator.ease( this.hairSizes[i], min(angle, 0.3f), 0.04f );
      }
    } else {
      for( int i = 0; i < this.hairSizes.length ; i++){
      this.hairSizes[i] = Animator.ease( this.hairSizes[i], 0.3f, 0.04f );
      }
    }
    this.applyPhysics();
  }
  
  /**
  * Overrides the displayOn( PGraphics scene ) method of Entity
  * Draws the exterior circle of the cell
  * Draws the 18 different hair
  *
  * @see Entity#position
  * @see Entity#size
  * @see Microbe#orientation
  * @see Microbe#spread
  * @see Microbe#hairSizes
  */ 
  @Override
  public void displayOn( PGraphics scene ) {   
    scene.pushMatrix();
      scene.translate( this.position.x, this.position.y );
      scene.stroke( 255 );
      scene.strokeWeight( 3 );
      scene.noFill();
      scene.ellipse( 0, 0, this.size, this.size );
      for ( int i = 0; i < 18; i++ ) {
        float radius1 = 0.5f*this.size;
        float radius2 = radius1 + this.hairSizes[i]*this.size;
        float angle = map(i, 0.0f, 18.0f, orientation-spread/2, orientation+spread/2 );
        scene.strokeWeight( 2 );
        scene.line( radius1*cos(angle), radius1*sin(angle), radius2*cos(angle), radius2*sin(angle) );
      }
    scene.popMatrix();
  }
}











/**
 * TwitterReader is the class providing tools to fetch Twitter data.
 * <p>
 * The TwitterReader is characterized by the next information :
 * <ul>
 * <li> A twitterFactory, which allows to constructs Twitter instances from authentification
 * <li> A twitter, the actual instance of the twitterFactory
 * <li> A query, which stores the request and its settings
 * <li> A result, which will store the response from Twitter to the query
 * <li> A tweets to collect all the Tweets from the result
 * </ul>
 * </p>
*/
class TwitterReader {
  
  /**
  * The TwitterFactory is used to stores personnal twitter oAuth keys and get instances of Twitter
  * @see TwitterFactory
  * @see Twitter
  */
  private TwitterFactory twitterFactory;
  
  /**
  * The twitter is the actual instance of the TwitterFactory, through which we can send and receive data.
  *
  * @see TwitterReader#getResults()
  * @see Twitter
  * @see TwitterFactory
  */
  private Twitter twitter;
  
  /**
  * The query can store the Strinf for the reserch and its parameters
  *
  * @see TwitterReader#getResults()
  * @see Query
  * @see Twitter
  */
  private Query query;
  
  /**
  * The result will store the results from twitter after having sent a query
  *
  * @see TwitterReader#getResults()
  * @see Query
  * @see Twitter
  */
  private QueryResult result;

  /**
  * The tweets is a collection of all the received tweets from a response
  *
  * @see TwitterReader#getResults()
  * @see Query
  * @see Twitter
  */
  private ArrayList tweets;
  
  /**
  * TwitterReader Constructor.
  * <p>
  * When a TwitterReader is constructed, its query is by default set "default", with a 100 count response
  * A ConfigurationBuilder is set with Twitter keys
  * The twitterFactory is initialized with it
  * The twitter gets an instance out of the twitterFactory
  * </p>
  */
  public TwitterReader() {

    this.query = new Query( "default" );
    this.query.setCount( 100 );

    ConfigurationBuilder cb = new ConfigurationBuilder();

    cb.setOAuthConsumerKey( "PDK4d1s3w1CjBwC3wLIezZkMM" );
    cb.setOAuthConsumerSecret( "W6YInJhGLKASOqe3ngoJjOpMcyFKegjypFjtZIVERFZpxxdpeV" );
    cb.setOAuthAccessToken( "116720199-54LaxdHHT9l22woakmqBM4r9NBBviMKBStRxt571" );
    cb.setOAuthAccessTokenSecret( "ela7Fx70QPH9g2E95kA3gs0ls8VhEh72M9ORY5ar1G9ag" );

    this.twitterFactory = new TwitterFactory( cb.build() );
    this.twitter = twitterFactory.getInstance();
  }

  /**
  * Setter for the query with a new topic
  *
  * @param topic
  *          The topic string to set
  *
  * @see TwitterReader#query
  */
  public void setTopic( String topic ) {
    this.query = new Query( topic );
    this.query.setCount( 100 );
    this.query.resultType( Query.MIXED );
  }
  
  /**
  * Method for Twitter communication. The query is sent, an answer is returned.
  *
  * @see TwitterReader#query
  * @see TwitterReader#result
  * @see TwitterReader#tweets
  */
  public void getResults() {
    try {
      this.result = twitter.search( this.query );
      this.tweets = (ArrayList) this.result.getTweets();
    } 
    catch ( TwitterException e ) {
      println("Couldn't connect: " + e);
    }
  }
  
  /**
  * Method for Twitter results printing
  *
  * @see TwitterReader#query
  * @see TwitterReader#result
  * @see TwitterReader#tweets
  */
  public void printResults() {
    for ( int i = 0; i < this.tweets.size(); i++ ) {
      Status t = (Status) this.tweets.get(i);
      println( "Tweet n\u00b0" + (i+1) + " : " + t.getText().replace( "\n", "" ) );
    }
  }
  
  /**
  * Entities initializer
  *
  * @param list
  *          The arraylist of Entities in which new entities will be stored
  *
  * @param sceneSize
  *          The dimension within the entities will be constructed
  *
  * @see Entity
  * @see Virus
  * @see Bacteria
  * @see Microbe
  * @see Grower
  * @see TwitterReader#tweets
  */
  public void buildEntities( ArrayList<Entity> list, PVector sceneSize ) {
    list.clear();
    
    for ( int i = 0; i < this.tweets.size(); i++ ) {
      Status t = (Status) this.tweets.get(i);
      StringBuilder s = new StringBuilder( t.getText().replace( "\n", "" ) );
      int indexOfLink = s.indexOf( "http" );
      if ( indexOfLink > 0 )
        s.setLength( indexOfLink );
      println( "Entity n\u00b0" + i + " : " + s.toString() );
      if ( s.length() > 60 )
        s.insert( 60, '\n' );
      if ( s.length() > 120 )
        s.insert( 120, '\n' );
      
      Entity e;
      
      float x = noise( i );
      float y = noise( x, i );
      float z = 40 + 0.04f*t.getFavoriteCount();
      
      switch ( (int)(random(4.9f)) ) {
        case 0:
          e = new Virus( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 1:
          e = new Bacteria( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 2:
          e = new Grower( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 3:
          e = new Microbe( x*sceneSize.x, y*sceneSize.y, z );
        break;
        case 4:
          e = new Virus( x*sceneSize.x, y*sceneSize.y, z );
        break;
        default:
          e = new Virus( x*sceneSize.x, y*sceneSize.y, z );
        break;
      }
      
      e.setSpeech( s.toString() );
      list.add( e );
      
    }

  }
}
/**
 * Virus is a undertype of Entity.
 * Therefore, this class inherits of all attributes and methods of Entity
 * <p>
 * A Virus is characterized by multiple arguments and methods normal entities cannot call.
*/
class Virus extends Entity {
 
  /**
  * The float excitement is the factor of excitation that the nucleus will have.
  * @see Virus#displayOn( PGraphics scene )
  * @see Virus#Virus(float x, float y)
  * @see Virus#update()
  */
  private float excitement;
  
  /**
  * The int destructCountDown is the timer to recreate the nucleus when explosed.
  * @see Virus#update()
  * @see Virus#Virus(float x, float y)
  */
  private int destructCountDown;
  
  /**
  * The float nucleusSize is the size that the nucleus keep.
  * @see Virus#Virus(float x, float y)
  * @see Virus#update()
  * @see Virus#displayOn( PGraphics scene )
  */
  private float nucleusSize;
 
  /**
  * Virus Constructor.
  * <p>
  * When a Virus is constructed, it uses the Entity constructor.
  * By that, it gives the x and y parameters and uses 45.0 for the size.
  * </p>
  *
  * @param x
  *          position on the x axe of the Grower cell
  * @param y
  *          position on the y axe of the Grower cell
  */ 
  public Virus( float x, float y, float size ) {
    super( x, y, size );
    this.excitement = 1.f;
    this.destructCountDown = 0;
    this.nucleusSize = 0.3f * this.size;
  }

  /**
  * Overrides the update() method of Entity
  * Updates the attributes of the Virus cell.
  * When the player's cell is nearby, the excitement and agitation of the 3 nucleus increase.
  * When not, the Virus' nucleus calm down.
  * If the player's cell excites the 3 nucleus too much, these explose.
  * They only recreate themselves when the cell is gone.
  * Then, the method calls the applyPhysics() method to do the rest of interactions (collision, velocity).
  * Uses an Animator method to animate the growing and ungrowing of the Microbe's hair.
  *
  * @see Entity#reference
  * @see Entity#size
  * @see Virus#excitement
  * @see Virus#destructCountDown
  * @see Virus#nucleusSize
  * @see Virus#agitation
  * @see Animator#ease( float from, float to, float step )
  * @see Entity#applyPhysics()
  */
  @Override
    public void update() {
    if ( this.position.dist( this.reference.position ) < this.size/2 ) {
      float agitation = map(this.reference.position.dist(this.position), 0.f, this.size, 1.f, 3.f) ;
      this.excitement = Animator.ease( this.excitement, min(agitation, 3), 0.1f);
      this.destructCountDown += 1;
      if (destructCountDown >= 60) {
        this.nucleusSize = 0.0f;
        this.destructCountDown = 0;
      }
    } else {
      this.excitement = Animator.ease( this.excitement, 1.0f, 5 );
      this.nucleusSize = Animator.ease( this.nucleusSize, 0.3f * this.size, 0.01f );
    }
    this.applyPhysics();
  }
  
  /**
  * Overrides the displayOn( PGraphics scene ) method of Entity
  * Draws the exterior circle of the cell
  * Draws the 3 nucleus with a random factor to position them.
  *
  * @see Entity#position
  * @see Entity#size
  * @see Virus#nucleusSize
  * @see Virus#excitement
  */ 
  @Override
    public void displayOn( PGraphics scene ) {   
    scene.pushMatrix();
    scene.translate( this.position.x, this.position.y );
    scene.stroke( 255 );
    scene.strokeWeight( 3 );
    scene.noFill();
    scene.ellipse( 0, 0, this.size, this.size );
    if ( this.nucleusSize > 0.0f ) {
      for ( int i = 0; i < 3; i++ ) {
        float random = noise(i, this.excitement*0.001f*this.k*millis(), this.k);
        float radius = this.excitement * 0.2f * random * this.size;
        float angle = map((i + random - 0.5f)*this.excitement, 0.0f, 3.0f, 0.0f, TWO_PI );
        scene.stroke( 255, 200, 200 );
        scene.strokeWeight( 2 );
        scene.ellipse( radius*cos(angle), radius*sin(angle), this.nucleusSize, this.nucleusSize );
      }
    }
    scene.popMatrix();
  }
}
  public void settings() {  size( 700, 700, P2D );  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Procell" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
