#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

string location;
string position;

default {
    link_message(integer from, integer chan, string msg, key xyzzy) {
      if (chan != teleport) return;
      GET_CONTROL;
      debug(xyzzy);
      
      POP(location);
      POP(position);

      llRequestExperiencePermissions(xyzzy,"");
    }
    
    experience_permissions(key avi) {
      llSleep(1);
      llTeleportAgentGlobalCoords(avi,
				  llGetRegionCorner(),
				  (vector) position,
				  ZERO_VECTOR);
      llSleep(1);
      llParticleSystem([]);
    }
    
    experience_permissions_denied(key avi, integer reason) {
      llRegionSayTo(avi,0,"Unable to teleport.");
      llParticleSystem([]);
    }
}
