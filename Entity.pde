/*
Entity class.
All classes will inherit from Entity.
*/

public class Entity {
  
  private float index; 
  private PVector position;
  private PVector velocity;
  private PVector destination;
  private float size;
  private boolean castsShadows;
  
  public Entity( float x, float y, float size ) {
    this.index = random(10);
    this.position = new PVector( x, y );
    this.velocity = new PVector( 0, 0 );
    this.destination = new PVector( x, y );
    this.size = size;
    castsShadows = false;
  }
  
  public void setLightCasting( boolean castsLight ) {
    this.castsShadows = castsShadows;
  }
  
  public void moveTo( float x, float y) {
    destination.set( x, y );
  }
  
  public PVector getPosition() {
    return position;
  }
  
  public void applyPhysics() {
    position.add( velocity );
  }
  
  public void update() {}
  
  public void display( PGraphics scene ) {}
  
}