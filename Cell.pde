/*
Cell class.
Basic Entity, main character.
*/

class Cell extends Entity {
  
  private PVector lightIntensity;
  
  public Cell() {
    super( width/2, height/2, 20.0 );
    super.setLightCasting( true );
    lightIntensity = new PVector(0.8,0.8,0.8);
  }
  
  public PVector getLightIntensity() {
    PVector l = new PVector();
    l = lightIntensity.copy();
    l.mult( 0.3 + 0.1 * (1+cos(0.002*millis())) );
    return l;
  }
  
  @Override
  public void update() {
    super.velocity.set( mouseX-width/2, mouseY-height/2 );
    super.velocity.mult( 0.01 );
    super.applyPhysics();
  }
  
  public void display() {
    pushMatrix();
      translate( width/2, height/2 );
      noStroke();
      fill( 255 );
      ellipse( 0, 0, super.size, super.size );
    popMatrix();
  }
  
}