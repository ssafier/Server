#include "include/server.h"

// Take some action on each newbie that enters.  sleeps between newbies.
#define sleep_time 1

#ifndef debug
#define debug(m)
#endif

integer iter = 0;

list newbies = [];
list newKeys = [];

// -----------------
increment() {
  --iter;
  if (iter < 0) return;
  llMessageLinked(LINK_THIS, regionEnter, (string) newbies[iter],
		  (key) (string) newKeys[iter]);
  llSetTimerEvent(sleep_time);
}

// -----------------
default {
  on_rez(integer foo) {
    llResetScript();
  }

  link_message(integer from, integer channel, string msg, key akey) {
    switch (channel) {
    case regionVisitors: {
      integer index = llSubStringIndex(msg, "~");
      newbies = llParseString2List(llGetSubString(msg,0, index - 1), ["|"], []);
      newKeys = llParseString2List(llGetSubString(msg, index + 1, -1), ["|"], []);
      iter = llGetListLength(newbies) ;
      increment();
      break;
    }
    case registerAck: {
      llSetTimerEvent(0);
      increment();
      break;
    }
    default: break;
    }
  }

  timer() { 
    llSetTimerEvent(0); 
    increment();
}
  
  state_exit() { llSetTimerEvent(0.0); }
}
