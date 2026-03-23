#include "include/server.h"

integer numAvatars = 0;

list players = [];
list pKeys = [];

// state variables that keep track of comings and goings
list priorVisitors = [];
list currentVisitors = [];
integer priorCount = 0;
list priorVisitorsKeys = [];
list currentVisitorsKeys = [];
list newbies = [];
list newKeys = [];

integer initp = FALSE;

// display above the prim data about the region
vector COLOR = <255.0, 105.0, 180.0>;
float  OPAQUE      = 1.0;

#ifndef debug
#define debug(msg)
#endif

initVars() {
  priorVisitors = currentVisitors;
  priorVisitorsKeys = currentVisitorsKeys;
  currentVisitors = [];
  currentVisitorsKeys = [];
  newbies = [];
  newKeys = [];

  players = [];
  pKeys = [];
}

// scan the region and update game scripts of players in region.
initializeAgents() {
  list avatarsInRegion = llGetAgentList(AGENT_LIST_REGION, []);
  numAvatars = llGetListLength(avatarsInRegion);

  // if no avatars, abort avatar listing process and give a short notice
  if (!numAvatars)  {
    return;
  }
  
  integer index;
  while (index < numAvatars) {
    key id = llList2Key(avatarsInRegion, index);

    // Can perform an experience check here and add to players only if in
    // experience.
    string name = llKey2Name(id);

    players += [name];
    pKeys += [id];

    // did somebody just arrive?
    // assume if reboot, nobody arrived
    if (llListFindList(priorVisitors, [name]) == -1) { // no new visitors if initializing
      debug("new visitor "+name);
      newbies += [name];
      newKeys += [id];
      llMessageLinked(LINK_THIS, rezComputo, (string) id, id);
      currentVisitors = [name] + currentVisitors;
      currentVisitorsKeys = [id] + currentVisitorsKeys;
    } else {
      currentVisitors = currentVisitors + [name];
      currentVisitorsKeys = currentVisitorsKeys + [id];
    }
    ++index;
  }
}

// ----------------
// initialize and check or wait for the DB to start
default {
  on_rez(integer foo) {
    llResetScript();
  }

  state_entry() {
    priorVisitors = [];
    priorVisitorsKeys = [];
    priorCount = 0;
    newbies = [];
    newKeys = [];
  }

  link_message(integer from, integer num, string msg, key akey) {
    if (num == runCheck && msg == "RUNNING") state run;
  }
}

// ----------------
//  
state run {
  state_entry()  {
    priorCount = 0;
    priorVisitors = [];
    priorVisitorsKeys = [];
    newbies = [];
    newKeys = [];
    
    debug("Region started");
  }

  link_message(integer from, integer channel, string message, key akey) {
    switch(channel) {
    case clockMsg: {
      if (message != "CLOCK:TICK") return;
      initVars();
      initializeAgents();
	
      if (newbies != []) {
	llMessageLinked(LINK_THIS, regionVisitors,
			llDumpList2String(newbies, "|") + "~" + llDumpList2String(newKeys, "|"),
			NULL_KEY);
      }
      if (priorVisitors != []) {
	llMessageLinked(LINK_THIS, regionDepart,
			llDumpList2String(priorVisitors, "|") + "~" +
			llDumpList2String(currentVisitors, "|") + "~" +
			llDumpList2String(priorVisitorsKeys, "|"),
			NULL_KEY);
      }
      // Say to region who is here
      if (newbies != [] || priorCount != llGetListLength(priorVisitors)) {
	llRegionSay(regionListen, llDumpList2String(currentVisitorsKeys,","));
      }
      priorCount = llGetListLength(priorVisitors);
      integer l = llGetListLength(players);
      if (l == 0) return;
      integer i;
      string text ="";
      for (i = 0; i < l; ++i) {
	string n = llGetSubString((string) players[i], 0, -9);
	text = text + "\n" + n;
      }
      llSetText(text, COLOR, OPAQUE );
      break;
    }
    default: break;
    }
  }

  state_exit() {
    debug("Region server is exiting");
    llResetScript();
  }
}
