static class Animator {
  
  // Cubic timed animations
  
  public static float easeIn( float t, float b , float c, float d ) {
    return c*(t/=d)*t*t + b;
  }
  
  public static float easeOut( float t, float b , float c, float d ) {
    return c*((t=t/d-1)*t*t + 1) + b;
  }
  
  public static float easeInOut( float t, float b , float c, float d ) {
    if ((t/=d/2) < 1) return c/2*t*t*t + b;
    return c/2*((t-=2)*t*t + 2) + b;
  }
  
  // Non-timed easing
  
  public static float ease( float from, float to, float step ) {
    if ( abs(from-to) < step ) return to;
    float dist = step;//pow( abs(from-to), step );
    return from + (from<to ? dist : -dist);
  }

  public static PVector ease( PVector from, PVector to, float step ) {
    return new PVector( ease(from.x, to.x, step), ease(from.y, to.y, step) );
  }
  
}