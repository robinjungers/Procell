/*
Bacteria class.
Basic Entity.
*/

class Bacteria extends Entity {
  
  public Bacteria( float x, float y ) {
    super( x, y, 35.0 );
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
      scene.strokeWeight( 4 );
      scene.noFill();
      scene.beginShape();
      for ( int i = 0; i < 64; i++ ) {
        float angle = map(i, 0.0, 31.0, 0.0, TWO_PI );
        float random = 0.5 + 0.5*noise(0.9*sin(angle), 0.001*super.k*millis(), super.k);
        float radius = 0.5 * random * super.size;
        scene.vertex( radius*cos(angle), radius*sin(angle) );
      }
      //scene.vertex( -super.size/2, 0 );
      //scene.bezierVertex( -super.size/3, -super.size/2, -super.size/3, super.size/2, -super.size/2, 0 );
      scene.endShape();
    scene.popMatrix();
  }
}