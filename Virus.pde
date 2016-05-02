/*
Virus class.
Basic Entity.
*/

class Virus extends Entity {
  
  public Virus() {
    super( random(width), random(height), 35.0 );
  }
  
  @Override
  public void update() {
    super.applyPhysics();
  }
  
  @Override
  public void display( PGraphics scene ) {
    scene.pushMatrix();
      scene.translate( super.position.x, super.position.y );
      scene.stroke( 255 );
      scene.strokeWeight( 3 );
      scene.noFill();
      scene.ellipse( 0, 0, super.size, super.size );
      for ( int i = 0; i < 3; i++ ) {
        float radius = 0.2 * noise(i, 0.001*millis(), super.index) * super.size;
        float angle = map(i, 0.0, 3.0, 0.0, TWO_PI );
        scene.stroke( 255, 220, 220 );
        scene.strokeWeight( 2 );
        scene.ellipse( radius*cos(angle), radius*sin(angle), 0.3*super.size, 0.3*super.size );
      }
    scene.popMatrix();
  }
}