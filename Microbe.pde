/*
Microbe class.
Basic Entity.
*/

class Microbe extends Entity {
  
  private float orientation;
  private float spread;
  private float hairSize;
  
  public Microbe( float x, float y ) {
    super( x, y, 55.0 );
    
    this.orientation = 0.0;
    this.spread = TWO_PI;
    this.hairSize = 0.2;
  }
  
  @Override
  public void update() {
    if ( super.position.dist( super.reference.position ) < super.size ) {
      this.hairSize = Animator.ease( this.hairSize, 0, 0.04 );
    } else {
      this.hairSize = Animator.ease( this.hairSize, 0.2, 0.04 );
    }
    super.applyPhysics();
  }
  
  @Override
  public void displayOn( PGraphics scene ) {   
    scene.pushMatrix();
      scene.translate( super.position.x, super.position.y );
      scene.stroke( 255 );
      scene.strokeWeight( 3 );
      scene.noFill();
      scene.ellipse( 0, 0, super.size, super.size );
      for ( int i = 0; i < 18; i++ ) {
        float random = noise(i, 0.001*super.k*millis(), super.k);
        float radius1 = 0.5*super.size;
        float radius2 = radius1 + this.hairSize*super.size;
        float angle = map(i, 0.0, 18.0, orientation-spread/2, orientation+spread/2 );
        scene.strokeWeight( 2 );
        scene.line( radius1*cos(angle), radius1*sin(angle), radius2*cos(angle), radius2*sin(angle) );
      }
    scene.popMatrix();
  }
}