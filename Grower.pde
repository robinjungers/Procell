/*
Grower class.
 Basic Entity.
 */

class Grower extends Entity {
    public Grower( float x, float y ) {
    super( x, y, 40.0 );
  }
  
//grows when the cell is in contact with it
  @Override
    public void update() {
    if ( super.position.dist( super.reference.position ) < super.size ) {
      super.size = Animator.ease( super.size, 140., 10 );
      super.reference.velocityCapacity = 0.5;
    } else {
      super.size = Animator.ease( super.size, 40, 10 );
      super.reference.velocityCapacity = 1.0;
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
    float random = noise(0, 0.001*super.k*millis(), super.k);
    float radius = 0.2 * random * super.size;
    float angle = map(random - 0.5, 0.0, 3.0, 0.0, TWO_PI );
    scene.stroke( 255, 200, 200 );
    scene.strokeWeight( 2 );
    scene.ellipse( radius*cos(angle), radius*sin(angle), 0.3*super.size, 0.3*super.size );
    scene.popMatrix();
  }
}