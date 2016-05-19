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
    if ( this.position.dist( this.reference.position ) < this.size/2 ) {
      this.size = Animator.ease( this.size, 140., 10 );
      this.reference.velocityCapacity = 0.5;
    } else {
      this.size = Animator.ease( this.size, 40, 10 );
      this.reference.velocityCapacity = 1.0;
    }
    this.applyPhysics();
  }

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