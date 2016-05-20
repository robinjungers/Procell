/**
 * Grower is a undertype of Entity.
 * Therefore, this class inherits of all attributes and methods of Entity
 * <p>
 * A Grower is characterized by multiple methods normal entities cannot do.
*/
class Grower extends Entity {
  
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
  */
    public Grower( float x, float y ) {
    super( x, y, 40.0 );
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
      this.size = Animator.ease( this.size, 140., 10 );
      this.reference.velocityCapacity = 0.5;
    } else {
      this.size = Animator.ease( this.size, 40, 10 );
      this.reference.velocityCapacity = 1.0;
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
    float random = noise(0, 0.001*this.k*millis(), this.k);
    float radius = 0.2 * random * this.size;
    float angle = map(random - 0.5, 0.0, 3.0, 0.0, TWO_PI );
    scene.stroke( 255, 200, 200 );
    scene.strokeWeight( 2 );
    scene.ellipse( radius*cos(angle), radius*sin(angle), 0.3*this.size, 0.3*this.size );
    scene.popMatrix();
  }
}