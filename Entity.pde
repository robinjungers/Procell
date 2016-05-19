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
    this.velocityCapacity = 1.0;
    this.speech = "";
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
  */
  public boolean isOnScreen( PVector size ) {
    if ( this.reference != null ) {
      if ( this.position.dist( this.reference.position ) > 0.71*size.x + this.size ) return false;
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
      float c = 0.05; // Energy factor // 0.05 is calm, 0.5 is very bouncy 
      PVector toAdd = new PVector( c*(this.position.x - e.position.x), c*(this.position.y - e.position.y) );
      this.velocity.add( toAdd.lerp( e.velocity, 0.0 ) );
    }
    this.velocity.mult( 0.9 );
    this.position.add( this.velocity );
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