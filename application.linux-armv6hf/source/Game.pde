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
      stroke( 255, 100000000*sin(0.08*frameCount) );
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