/*
Microbe class.
Basic Entity.
*/

class Microbe extends Entity {
  
  private float orientation;
  private float spread;
  private float[] hairSizes;
  
  public Microbe( float x, float y ) {
    super( x, y, 55.0 );
    
    this.orientation = 0.0;
    this.spread = TWO_PI;
    this.hairSizes = new float[18];
    for (int i = 0; i < this.hairSizes.length; i++) {
      this.hairSizes[i] = 0.3;
    }
  }
  
  @Override
  public void update() {
    if ( super.position.dist( super.reference.position ) < super.size ) {
      PVector p = new PVector( (super.reference.position.x - this.position.x), (super.reference.position.y - this.position.y) ) ;
      for ( int i = 0; i < this.hairSizes.length ; i++ ) {
          float angle = 0.5 *pow( (map(i, 0.0, 18.0, this.orientation - this.spread/2, this.orientation + this.spread/2 ) - p.heading()) , 2);
          
          this.hairSizes[i] = Animator.ease( this.hairSizes[i], min(angle, 0.3), 0.04 );
          
      }
    } else {
      for( int i = 0; i < this.hairSizes.length ; i++){
      this.hairSizes[i] = Animator.ease( this.hairSizes[i], 0.3, 0.04 );
      }
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
        float radius1 = 0.5*super.size;
        float radius2 = radius1 + this.hairSizes[i]*super.size;
        float angle = map(i, 0.0, 18.0, orientation-spread/2, orientation+spread/2 );
        scene.strokeWeight( 2 );
        scene.line( radius1*cos(angle), radius1*sin(angle), radius2*cos(angle), radius2*sin(angle) );
      }
    scene.popMatrix();
  }
}