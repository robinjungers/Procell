/**
 * Animator is a static class providing basic animation functions
 * <p>
 * Animator is not characterized by any attributes.
 * </p>
*/
static class Animator {
  
  /**
  * Eases in a value with cubic function
  *
  * @param t
  *          Current time
  * @param b
  *          Begining value
  * @param c
  *          Change value to reach
  * @param d
  *          Total duration desired
  */  
  public static float easeIn( float t, float b , float c, float d ) {
    return c*(t/=d)*t*t + b;
  }
  
  /**
  * Eases out a value with cubic function
  *
  * @param t
  *          Current time
  * @param b
  *          Begining value
  * @param c
  *          Change value to reach
  * @param d
  *          Total duration desired
  */  
  public static float easeOut( float t, float b , float c, float d ) {
    return c*((t=t/d-1)*t*t + 1) + b;
  }
  
  /**
  * Eases in and out a value with cubic function
  *
  * @param t
  *          Current time
  * @param b
  *          Begining value
  * @param c
  *          Change value to reach
  * @param d
  *          Total duration desired
  */  
  public static float easeInOut( float t, float b , float c, float d ) {
    if ((t/=d/2) < 1) return c/2*t*t*t + b;
    return c/2*((t-=2)*t*t + 2) + b;
  }
  
  /**
  * Smooths the change of a value 
  *
  * @param from
  *          Current value to ease
  * @param to
  *          Goal value
  * @param step
  *          Step value
  */    
  public static float ease( float from, float to, float step ) {
    if ( abs(from-to) < step ) return to;
    float dist = step;//pow( abs(from-to), step );
    return from + (from<to ? dist : -dist);
  }
  
  /**
  * Smooths the change of PVector values
  *
  * @param from
  *          Current Pvector to ease
  * @param to
  *          Goal PVector
  * @param step
  *          Step value
  */ 
  public static PVector ease( PVector from, PVector to, float step ) {
    return new PVector( ease(from.x, to.x, step), ease(from.y, to.y, step) );
  }
  
}