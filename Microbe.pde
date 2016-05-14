/*
Microbe class.
Basic Entity.
*/

class Microbe extends Entity {
  
  float orientation;
  float spread;
  
  public Microbe( float x, float y ) {
    super( x, y, 55.0 );
    
    orientation = 0.0;
    spread = TWO_PI;
  }
  
  @Override
  public void update() {
    super.applyPhysics();
  }
  
  @Override
  public void displayOn( PGraphics scene ) {   
    scene.pushMatrix();
      scene.translate( super.position.x, super.position.y );
      scene.stroke( 255 );
      scene.strokeWeight( 3 );
      scene.noFill();
      scene.ellipse( 0, 0, 0.7*super.size, 0.7*super.size );
      for ( int i = 0; i < 18; i++ ) {
        float random = noise(i, 0.001*super.k*millis(), super.k);
        float radius1 = 0.4*super.size;
        float radius2 = 0.5*super.size;
        float angle = map(i, 0.0, 18.0, orientation-spread/2, orientation+spread/2 );
        scene.strokeWeight( 2 );
        scene.line( radius1*cos(angle), radius1*sin(angle), radius2*cos(angle), radius2*sin(angle) );
      }
    scene.popMatrix();
  }
}