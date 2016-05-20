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
  */
  public Microbe( float x, float y ) {
    super( x, y, 55.0 );
    
    this.orientation = 0.0;
    this.spread = TWO_PI;
    this.hairSizes = new float[18];
    for (int i = 0; i < this.hairSizes.length; i++) {
      this.hairSizes[i] = 0.3;
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
    if ( this.position.dist( this.reference.position ) < this.size/2 ) {
      PVector p = new PVector( (this.reference.position.x - this.position.x), (this.reference.position.y - this.position.y) ) ;
      for ( int i = 0; i < this.hairSizes.length ; i++ ) {
          float angle = 0.5 *pow( (map(i, 0.0, 18.0, this.orientation - this.spread/2, this.orientation + this.spread/2 ) - p.heading()) , 2);
          
          this.hairSizes[i] = Animator.ease( this.hairSizes[i], min(angle, 0.3), 0.04 );
      }
    } else {
      for( int i = 0; i < this.hairSizes.length ; i++){
      this.hairSizes[i] = Animator.ease( this.hairSizes[i], 0.3, 0.04 );
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
        float radius1 = 0.5*this.size;
        float radius2 = radius1 + this.hairSizes[i]*this.size;
        float angle = map(i, 0.0, 18.0, orientation-spread/2, orientation+spread/2 );
        scene.strokeWeight( 2 );
        scene.line( radius1*cos(angle), radius1*sin(angle), radius2*cos(angle), radius2*sin(angle) );
      }
    scene.popMatrix();
  }
}