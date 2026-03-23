#include "include/server.h"

// The clock has two functions.  It sets the interval which scans for new visitors
// and it sends a message to the region about TIME

#define CLOCK  -122333

// how long to sleep before scanning region for changes
#define scanTime 15.0
integer minTick = 0;

#ifndef debug
#define debug(x)
#endif

// ----------------
// initialize and check or wait for the DB to start
default {
  on_rez(integer foo) {
    llResetScript();
  }

  link_message(integer from, integer num, string msg, key akey) {
    if (num == runCheck && msg == "RUNNING") state run;
  }
}

// ----------------
//  
state run {
  state_entry()  {
      debug("Clock started");
      llSetTimerEvent(scanTime);
  }

  timer() {
    llSetTimerEvent(0);
    llMessageLinked(LINK_THIS, clockMsg, "CLOCK:TICK", NULL_KEY);
    minTick = minTick + 1;
    if (minTick > 3) {
      llRegionSay(CLOCK, (string) llGetUnixTime());
      minTick = 0;
    }
    llSetTimerEvent(scanTime);
  }

  state_exit() {
    debug("clock is exiting");
    llSetTimerEvent(0);
    llResetScript();
  }
}
