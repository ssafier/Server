#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

key avatar;

warpPos( vector destpos )  {
  //R&D by Keknehv Psaltery, 05/25/2006
  //with a little poking by Strife, and a bit more
  //some more munging by Talarus Luan
  //Final cleanup by Keknehv Psaltery
  //Changed jump value to 411 (4096 ceiling) by Jesse Barnett
  // Compute the number of jumps necessary
  integer jumps = (integer)(llVecDist(destpos, llGetPos()) / 10.0) + 1;

  // Try and avoid stack/heap collisions
  if (jumps > 411)  jumps = 411;
  list rules = [ PRIM_POSITION, destpos ];  //The start for the rules list

  integer count = 1;
  while ( ( count = count << 1 ) < jumps)
    rules = (rules=[]) + rules + rules;   //should tighten memory use.
  llSetPrimitiveParams( rules + llList2List( rules, (count - jumps) << 1, count) );
  if ( llVecDist( llGetPos(), destpos ) > .001 ) //Failsafe
    while ( --jumps ) llSetPos( destpos );
}

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != warp) return;
    GET_CONTROL;
    string loc;
    POP(loc);
    warpPos((vector) loc + <xIncrement,0,zIncrement>);
   NEXT_STATE;
  }
}
