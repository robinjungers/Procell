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
    this.excitement = 1.;
    this.destructCountDown = 0;
    this.nucleusSize = 0.3 * this.size;
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
      float agitation = map(this.reference.position.dist(this.position), 0., this.size, 1., 3.) ;
      this.excitement = Animator.ease( this.excitement, min(agitation, 3), 0.1);
      this.destructCountDown += 1;
      if (destructCountDown >= 60) {
        this.nucleusSize = 0.0;
        this.destructCountDown = 0;
      }
    } else {
      this.excitement = Animator.ease( this.excitement, 1.0, 5 );
      this.nucleusSize = Animator.ease( this.nucleusSize, 0.3 * this.size, 0.01 );
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
    if ( this.nucleusSize > 0.0 ) {
      for ( int i = 0; i < 3; i++ ) {
        float random = noise(i, this.excitement*0.001*this.k*millis(), this.k);
        float radius = this.excitement * 0.2 * random * this.size;
        float angle = map((i + random - 0.5)*this.excitement, 0.0, 3.0, 0.0, TWO_PI );
        scene.stroke( 255, 200, 200 );
        scene.strokeWeight( 2 );
        scene.ellipse( radius*cos(angle), radius*sin(angle), this.nucleusSize, this.nucleusSize );
      }
    }
    scene.popMatrix();
  }
}