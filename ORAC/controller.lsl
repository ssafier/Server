#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

key avatar;
integer handle;

default {
  on_rez(integer f) {
    if (f == 0) return;
    list message = llParseString2List(llGetStartString(),["|"],[]); // avi | location
    key avi = (key) (string) message[0];
    if (avi == NULL_KEY) llDie();
    llSetLinkPrimitiveParamsFast(LINK_SET,
				 [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0]);
    llMessageLinked(LINK_THIS, warp,
		    s_Welcome + "+" + s_Check + "+" + s_Position + "+" + s_Circle + "|" +
		    (string) message[1] + "|" + (string) avi,
		    avi);
  }
}
