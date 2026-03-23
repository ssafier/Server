#include "include/server.h"

// This file starts the server.  Scripts are either not running
// or waiting for the start message.

list scripts =
  ["~clock",
   "~sniffer"
   ]; 


#ifndef debug
#define debug(x)
#endif

setRunning(integer st) {
  list InventoryList;
  integer count = llGetInventoryNumber(INVENTORY_SCRIPT);  // Count of all items in prim's contents
  string  ItemName;
  while (count--)  {
    ItemName = llGetInventoryName(INVENTORY_SCRIPT, count);
    if (ItemName != llGetScriptName() )  
      llSetScriptState(ItemName, st);
  }
}


default {
  state_entry() {
    llSay(0, "Server is off (touch to switch on)");
    setRunning(FALSE);
  }
  
  touch_start(integer i) {
    if (llDetectedKey(0) == llGetOwner()) {
      debug("Starting...");
      setRunning(TRUE);
      state run;
    }    
  }
}

state run {
  state_entry() {
    llMessageLinked(LINK_THIS, runCheck,  "RUNNING", NULL_KEY);
  }
}
// END //
