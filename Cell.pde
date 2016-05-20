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
  */
  public Cell( float x, float y ) {
    super( x, y, 20.0 );
    this.lightIntensity = new PVector( 0.8, 0.8, 0.8 );
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
    this.velocity.mult( this.velocityCapacity * 0.01 );
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
    l.mult( 0.3 + 0.1 * (1+cos(0.002*millis())) );
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