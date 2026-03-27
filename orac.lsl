#include "include/server.h"

#define TIMER 1.15

#ifndef serverChannel
#define serverChannel ((integer)("0x"+llGetSubString((string)llGetKey(), -4, -1)))
#endif


#ifndef debug
#define debug(x)
#endif

#ifndef serverChannel
#define serverChannel ((integer)("0x"+llGetSubString((string)llGetKey(), -8, -1)))
#endif

list Q;

default {
  state_entry() {
    Q = [];
    llSetTimerEvent(TIMER);
  }
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan == rezComputo) {
      if (Q == []) llSetTimerEvent(TIMER);
      Q = Q + [msg + "|" + (string) xyzzy];
    }
  }
  timer() {
    if (Q == []) { llSetTimerEvent(0); return; }
    string entry = (string) Q[0];
    integer index = llSubStringIndex(entry,"|");
    key avi = (key) llGetSubString(entry,index+1,-1);
    entry = llGetSubString(entry,0,index-1); // json
    if (llGetListLength(Q) == 1)
      Q = [];
    else
      Q = llList2List(Q,1,-1);
    list val = llGetObjectDetails(avi, [OBJECT_POS]);
    llRezObjectWithParams("ORAC", 
			  [REZ_PARAM, serverChannel,
			   REZ_POS, llGetPos() + <0,0,0.1>, FALSE, FALSE,
			   REZ_VEL, ZERO_VECTOR, FALSE, FALSE,
			   REZ_ROT, ZERO_ROTATION, FALSE,
			   REZ_PARAM_STRING,
			   (string) avi + "|" + (string) (vector) val[0] + "|" + entry]);
  }
}
