#include "include/subservers.h"

#ifndef debug
#define debug(x)
#endif

integer handle;

#include "src/server/subservers/animation/alist.lsl"

integer find(string s, list l) {
  integer i = llGetListLength(l);
  while (i > 0) {
    --i;
    if (llList2String(l,i) == s) return TRUE;
  }
  return FALSE;
}

default {
  state_entry() {
    handle = llListen(serverChannel, "", NULL_KEY, "");
   }
  
  listen(integer chan, string name, key xyzzy, string msg) { 
    list m = llParseString2List(msg,["|"],[]);
    switch ((string) m[0]) {
    case "animate": {
      debug(msg);
      key avi = (key)(string)m[1];
      string an = (string) m[2];
      if (an == "" || avi == NULL_KEY) return;
      llMessageLinked(LINK_THIS, setPlayer,"|"+(string) avi,avi);
      llSleep(0.1);
      if (an == "[STOP]") {
	llMessageLinked(LINK_THIS, remoteStop, "|", avi);
      } else {
	llMessageLinked(LINK_THIS, remoteAnimateAvatar, "|" + an, avi);
      }
      break;
    }
    case "animate-menu": {
      debug("menu "+(string)m[1] + " " + (string) m[2]);
      list flexes = ["[STOP]", "[STOP]", cOffString] + bb + clanFlexes;;
      llRegionSayTo((key) (string)m[1],
		    (integer)(string)m[2],
		    llDumpList2String(llListSort(llList2ListStrided(flexes, 0,-1,3), 1, TRUE), "+"));
      break;
    }
    default: break;
    }
  }
}
    
