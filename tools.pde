/*
Generic functions & tools.
*/

float ease( float from, float to, float step ) {
  float dist = pow( abs(from-to), step );
  return from + (from<to ? dist : -dist);
}

PVector ease( PVector from, PVector to, float step ) {
  return new PVector( ease(from.x, to.x, step), ease(from.y, to.y, step) );
}