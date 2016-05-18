/*
Cell class.
Basic Entity, main character.
*/

class Cell extends Entity {
  
  private PVector lightIntensity;
  
  public Cell( float x, float y ) {
    super( x, y, 20.0 );
    this.lightIntensity = new PVector( 0.8, 0.8, 0.8 );
  }
  
  public void move( float x, float y) {
    super.velocity.set(x, y );
    super.velocity.mult( super.velocityCapacity * 0.01 );
  }
  
  public PVector getPosition() {
    return super.position;
  }
  
  public PVector getLightIntensity() {
    PVector l = new PVector();
    l = lightIntensity.copy();
    l.mult( 0.3 + 0.1 * (1+cos(0.002*millis())) );
    return l;
  }
  
  @Override
  public void update() {
    super.position.add( super.velocity );
  }
  
  public void displayAt( PVector position, PVector size ) {
    pushMatrix();
      translate( position.x + size.x/2, position.y + size.y/2 );
      noStroke();
      fill( 255 );
      ellipse( 0, 0, super.size, super.size );
    popMatrix();
  }
  
}