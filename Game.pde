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
 * </ul>
 *
*/

public class Game {
  
  private boolean isReady;
  
  private PFont menuFont;
  private PFont menuSubFont;
  private StringBuilder topic;
  
  public Game() {
    this.isReady = false;
    this.menuFont = loadFont( "PierSans-14.vlw" );
    this.menuSubFont = loadFont( "PierSans-24.vlw" );
    this.topic = new StringBuilder("");
  }
  
  public boolean isReady() {
    return this.isReady;
  }
  
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
    
  }
  
  public void addToTopicString( char c ) {
    this.topic.append( c );
  }
  
  public void backspaceTopicString() {
    if ( this.topic.length() > 0 )
      this.topic.setLength( this.topic.length() - 1);
  }
  
  public void pushTopicTo( TwitterReader t ) {
    if ( this.topic.length() < 1 ) return;
    this.isReady = true;
    
    t.setTopic( this.topic.toString() );
    t.getResults();
    t.printResults();
    
  }
  
  
}