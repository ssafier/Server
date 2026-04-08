#include "include/subservers.h"

#define DIECMD "kill-flight"

#ifndef debug
#define debug(x)
#endif

#ifndef PAUSE_TIME
#define PAUSE_TIME 1.1
#endif

integer dhandle;

default {
  state_entry() {
    // it an avatar is seated and someone wants to grab him for detach
    dhandle = llListen(SUBSERVER_FORCE_DETACH + SUBSERVER_ME,
		       "",
		       NULL_KEY,
		       "");
  }

  listen(integer chan, string name, key xyzzy, string msg) {
    if (chan == (SUBSERVER_FORCE_DETACH + SUBSERVER_ME)) {
      llSetTimerEvent(0);
      llMessageLinked(LINK_SET, killAndPause, msg, NULL_KEY);
      return;
    }
  }
}
