#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

key avatar;

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != warp) return;
    GET_CONTROL;
    string loc;
    POP(loc);
    llSetRegionPos((vector) loc + <xIncrement,0,zIncrement>);
   NEXT_STATE;
  }
}
