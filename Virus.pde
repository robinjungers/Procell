/*
Virus class.
Basic Entity.
*/

class Virus extends Entity {
  
  private float excitement;
  private int destructCountDown;
  private float nucleusSize;
  
  public Virus( float x, float y ) {
    super( x, y, 45.0 );
    this.excitement = 1.;
    this.destructCountDown = 0;
    this.nucleusSize = 0.3 * this.size;
  }
  
  @Override
  public void update() {
    if ( this.position.dist( this.reference.position ) < this.size/2 ) {
      float agitation = map(this.reference.position.dist(this.position), 0., this.size, 1., 3.) ;
      this.excitement = Animator.ease( this.excitement, min(agitation, 3), 0.1);
      this.destructCountDown += 1;
      if(destructCountDown >= 40){
        this.nucleusSize = 0.001;
        this.destructCountDown = 0;
      }
    } else {
      this.excitement = Animator.ease( this.excitement, 1.0, 5 );
      this.nucleusSize = Animator.ease( this.nucleusSize, 0.3 * this.size, 0.1 );
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
      for ( int i = 0; i < 3; i++ ) {
        float random = noise(i, this.excitement*0.001*this.k*millis(), this.k);
        float radius = this.excitement * 0.2 * random * this.size;
        float angle = map((i + random - 0.5)*this.excitement, 0.0, 3.0, 0.0, TWO_PI );
        scene.stroke( 255, 200, 200 );
        scene.strokeWeight( 2 );
        scene.ellipse( radius*cos(angle), radius*sin(angle), this.nucleusSize, this.nucleusSize );
      }
    scene.popMatrix();
  }
}