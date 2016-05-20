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
      this.radiuses[i] = 0.5;
    }
    this.orientation = 0.0;
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
    if ( this.position.dist( this.reference.position ) < 0.9*this.size ) {
      PVector p = new PVector( -(this.reference.position.x - this.position.x), -(this.reference.position.y - this.position.y) ) ;
      for ( int i = 0; i < this.radiuses.length ; i++ ) {
          float angle = 0.5 *pow( (map(i, 0.0, 64.0, this.orientation - this.spread/2, this.orientation + this.spread/2 ) - p.heading()) , 2.);
          this.radiuses[i] = Animator.ease( this.radiuses[i], min(max(angle,0.2), 0.5), 0.04 );
      }
    } else {
      for( int i = 0; i < this.radiuses.length ; i++){
      this.radiuses[i] = Animator.ease( this.radiuses[i], 0.5, 0.04 );
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
        float angle = map(i, 0.0, 63., 0.0, TWO_PI)%TWO_PI;
        float random = 0.5 + 0.5*noise(0.9*sin(angle), 0.001*this.k*millis(), this.k);
        float radius = radiuses[i] * random * this.size;
        scene.vertex( radius*cos(angle), radius*sin(angle) );
      }
      float angle = map(0, 0.0, 63., 0.0, TWO_PI)%TWO_PI;
      float random = 0.5 + 0.5*noise(0.9*sin(angle), 0.001*this.k*millis(), this.k);
      float radius = radiuses[0] * random * this.size;
      scene.vertex( radius*cos(map(0, 0.0, 63., 0.0, TWO_PI)), radius*sin(map(0, 0.0, 63., 0.0, TWO_PI)) );
      scene.endShape();
    scene.popMatrix();
  }
}