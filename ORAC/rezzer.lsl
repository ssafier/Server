#include "include/controlstack.h"
#include "include/computo.h"

// Contact the region's server and have it rez flying posemats.

#ifndef debug
#define debug(x)
#endif

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case rezFlyMat: {
      GET_CONTROL;
      string target;
      POP(target);
      llRegionSay(evolveServerChannel,
		  "rez-flight|" + (string) xyzzy + "|" + target + "|100|0|100|0|1");
      break;
    }
    case rezVampireMat: {
      GET_CONTROL;
      string target;
      POP(target);
      llRegionSay(evolveServerChannel, "rez-vampire|" + (string) xyzzy + "|" + target + "|100|0|100|0|1");
      break;
    }      
    default: break;
    }
  }
}
