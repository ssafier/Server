#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

key requester;
list nearby;
list nearby_keys;

GLOBAL_DATA;

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case targetNearby: {
      GET_CONTROL_GLOBAL;
      requester = xyzzy;
      llSensor("", "", AGENT, DISTANCE, TWO_PI);
      break;
    }
    case selectAvi: {
      GET_CONTROL_GLOBAL;
      string name;
      POP(name);
      string aindex = llGetSubString(name,0,llSubStringIndex(name, ")"));
      integer l = llGetListLength(nearby);
      integer i;
      key target = NULL_KEY;
      while (l > 0 && target == NULL_KEY) {
	--l;
	if (llSubStringIndex((string) nearby[l], aindex) != -1) {
	  target = (key) nearby_keys[l];
	}
      }
      if (target) {
	PUSH(target);
	NEXT_STATE;
      }
      break;
    }
    default: break;
    }
  }
  sensor(integer num) {
    key k = llDetectedKey(0);
    if (k == NULL_KEY) return;

    integer i = 0;
    nearby = [];
    nearby_keys = [];
    while (i < num) {
      k = llDetectedKey(i);
      if (k != NULL_KEY && k != requester) {
	string name = llGetDisplayName(k);
	if (llStringLength(name) > 20) name = llGetSubString(name,0,19);
        nearby += (string)(i+1)+") "+name;
	nearby_keys += k;
      }
      ++i;
    }

    debug("found "+llDumpList2String(nearby,"~"));
    integer len =llGetListLength(nearby);
    if (len == 0) {
      llRegionSayTo(requester, 0, "No one nearby...");
      return;
    } else {
      llMessageLinked(LINK_THIS, doMenu,
		      (string) selectAvi + "+" + seq +
		      "|Select nearby player|"+llDumpList2String(nearby,"+"),
		      requester);
    } 
  }
  no_sensor() {
    llRegionSayTo(requester, 0, "No one nearby...");
  }
}
