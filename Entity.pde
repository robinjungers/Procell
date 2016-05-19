/*
Entity class.
All classes will inherit from Entity.
*/

public class Entity {
  
  private float k; // Special randomized parameter
  
  protected PVector position;
  protected PVector velocity;
  protected PVector destination;
  protected float size;
  protected float velocityCapacity;
  
  protected void setSize(float n){
   this.size = n; 
  }
  
  public float getSize(){
   return this.size; 
  }
  protected Entity reference;
  protected ArrayList<Entity> surroundings;
  
  public Entity( float x, float y, float size ) {
    this.k = random(1);
    this.position = new PVector( x, y );
    this.velocity = new PVector( 0, 0 );
    this.destination = new PVector( x, y );
    this.size = size;
    this.surroundings = new ArrayList<Entity>();
    this.velocityCapacity = 1.0;
  }
  
  // Set an entity to always consider
  public void setReference( Entity other ) {
    this.reference = other;
  }
  
  // Look at other entities and save references of the close ones
  public void setSurroundings( ArrayList<Entity> others ) {
    this.surroundings.clear();
    for ( Entity e: others ) {
      if ( this.position.dist( e.position ) < this.size/2 + e.size/2 ) {
        this.surroundings.add( e );
      }
    }
   // if ( this.reference != null ) {
    //  Entity e = this.reference;
     // if ( this.position.dist( e.position ) < this.size/2 + e.size/2 ) {
     //   this.surroundings.add( e );
     // }
   // }
  }
  
  // Check if visible
  public boolean isOnScreen( PVector size ) {
    if ( this.reference != null ) {
      if ( this.position.dist( this.reference.position ) > 0.71*size.x + this.size ) return false;
    }
    return true;
  }
  
  // Basic physics function
  public void applyPhysics() {
    for ( Entity e: this.surroundings ) {
      float c = 0.05; // Energy factor // 0.05 is calm, 0.5 is very bouncy 
      PVector toAdd = new PVector( c*(this.position.x - e.position.x), c*(this.position.y - e.position.y) );
      this.velocity.add( toAdd.lerp( e.velocity, 0.0 ) );
    }
    this.velocity.mult( 0.9 );
    this.position.add( this.velocity );
  }
  
  public void update() {}
  
  public void displayOn( PGraphics scene ) {}
  
}