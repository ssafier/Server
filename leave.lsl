#include "include/server.h"

integer iter = 0;

list priorVisitors = [];
list priorVisitorsKeys = [];
list currentVisitors = [];

list exited;

#ifndef debug
#define debug(msg) 
#endif

increment() {
  --iter;
  if (iter < 0) return;

  string name = llList2String(priorVisitors, iter);
  while (llListFindList(currentVisitors, [name]) != -1) {
    --iter;
    if (iter < 0) return;
    name = llList2String(priorVisitors, iter);
  }
  debug(name + " is leaving");
  llRegionSay(regionEmptyChan, (string)priorVisitorsKeys[iter]);
  llRegionSayTo((key)"a424ada4-551b-dc57-da3d-8c35354b5373", (integer) ("0x5373"),
		"check-region|" +  (string) priorVisitorsKeys[iter]);

  llMessageLinked(LINK_THIS, regionExit,  name, (key)priorVisitorsKeys[iter]);
  llSetTimerEvent(1);
}

///////////////////////////////
default {
  on_rez(integer foo) {
    llResetScript();
  }

  link_message(integer from, integer channel, string msg, key akey) {
    if (channel == regionDepart) {
      integer index = llSubStringIndex(msg, "~");
      priorVisitors = llParseString2List(llGetSubString(msg, 0, index - 1), ["|"], []);
      msg = llGetSubString(msg, index + 1, -1);
      index = llSubStringIndex(msg, "~");
      currentVisitors = llParseString2List(llGetSubString(msg, 0, index - 1), ["|"], []);
      priorVisitorsKeys = llParseString2List(llGetSubString(msg, index + 1, -1), ["|"], []);
      
      iter = llGetListLength(priorVisitors) ;
      increment();
      return;
    }
    if (channel == departAck) {
      llSetTimerEvent(0);
      increment();
      return;
    }
  }
  
  timer() { 
    llSetTimerEvent(0);
    increment();
  }
  
  state_exit() { llSetTimerEvent(0.0); llResetScript(); }
}
