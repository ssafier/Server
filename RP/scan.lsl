// Scanning is a varient of telepathy.
// level 7, region and location
// level 6, region, parcel location
// level 5, parcel and location
// level 4, parcel
// level 3, 96 meters
// level 2, llSay range

#include "include/controlstack.h"
#include "include/computo.h"

key player;
// -------------------
list listSetDifference(list a, list b) {
    list result = [];
    integer len = llGetListLength(a);
    while (len > 0) {
      --len;
        list item = llList2List(a, len, len); 
        if (llListFindList(b, item) == -1) result += item;
    }
    return result;
}

// -------------------

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != scanRolePlayer) return;
    GET_CONTROL;
    string p;
    POP(p);
    integer power = (integer) p + 1;
    list agents;

    player = xyzzy;
    
    switch (power) {
    case 7: {
      agents = llGetAgentList(AGENT_LIST_REGION, []);
      llMessageLinked(LINK_THIS,
		      scanPlayerLocation, "|" + llDumpList2String(agents, "+"),
		      xyzzy);
      break;
    }
    case 6: {
      agents = llGetAgentList(AGENT_LIST_REGION, []);
      list parcel = llGetAgentList(AGENT_LIST_PARCEL, []);
      list region = listSetDifference(agents, parcel);
      llMessageLinked(LINK_THIS, scanPlayerLocation, (string) scanPlayer + "|" +
		      llDumpList2String(parcel, "+") + "|" + llDumpList2String(region, "+"),
		      xyzzy);
      break;
    }
    case 5: {
      agents = llGetAgentList(AGENT_LIST_PARCEL, []);
      llMessageLinked(LINK_THIS,
		      scanPlayerLocation, "|" + llDumpList2String(agents, "+"),
		      xyzzy);
      break;
    }
    case 4: {
      agents = llGetAgentList(AGENT_LIST_PARCEL, []);
      llMessageLinked(LINK_THIS,
		      scanPlayer, "|" + llDumpList2String(agents, "+"),
		      xyzzy);
      break;
    }
    case 3: {
      llSensor("", NULL_KEY, AGENT, 96, PI);
      break;
    }
    case 2: {
      llSensor("", NULL_KEY, AGENT, 15, PI);
      break;
    }
    case 1: {
      break;
    }
    default: break;
    }
    NEXT_STATE;
  }

  sensor(integer num) {
    list agents = [];
    while(num > 0) {
      --num;
      key a = llDetectedKey(num);
      if (a != NULL_KEY) {
	agents = [a] + agents;
      }
      llMessageLinked(LINK_THIS,
		      scanPlayer, "|" + llDumpList2String(agents, "+"),
		      player);
    }
  }
}
    
