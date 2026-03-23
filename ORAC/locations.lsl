#include "include/controlstack.h"
#include "include/computo.h"

// this system spams the channel with teleporter locations
#define TELEPORTER_NAME "Inferno of Hell Teleport V2"
#define TELEPORTER_CHANNEL -2012

#ifndef debug
#define debug(x)
#endif

#define TimeOut 5

#define DISABLE ""
#define ENABLE ""

integer listening;
integer handle;
key avi;
list locations;

#define find(s,l) (llListFindStrided(l, [s], 0, -1, 2) != -1)

default {
  state_entry() {
    handle = llListen(TELEPORTER_CHANNEL, TELEPORTER_NAME, NULL_KEY, "");
    llListenControl(handle, listening = FALSE);
  }
  
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != getLocations) return;
    GET_CONTROL;
    switch (chan) {
    case getLocations: {
      locations = [];
      avi = xyzzy;
      llListenControl(handle, listening = TRUE);      
      debug ("listening");
      llSetTimerEvent(2);
      break;
    }
    default: break;
    }
  }
  
  listen(integer chan, string name, key xyzzy, string msg) {
    if (!listening) return;
    locations += msg;
  }
  
  timer() {
    llSetTimerEvent(0);
    llListenControl(handle, listening = FALSE);

    integer len = llGetListLength(locations);
    list locs = LOCATIONS; // addional locations
    integer i;
    for (i = 0; i < len; ++i) {
      string s = (string) locations[i];
      list l = llParseString2List(s, ["    "],[]);
      if (llGetListLength(l) == 3) {
	key a = (key) (string) l[0];
	string name = (string) l[1];
	vector v = (vector) (string) l[2] + <0,0,1.5>; // add height

	if (a != NULL_KEY &&
	    v != ZERO_VECTOR &&
	    name != "" &&
	    llGetSubString(name,0,0) != "*" && // private
	    !find(name, locs)) {
	  locs += [name, v];
	}
      }
    }

    llMessageLinked(LINK_THIS, select_location,
		    s_teleport + "|Choose your destination|" +
		    llDumpList2String(llListSort(locs,2,TRUE),"~"),
		    avi);
  }
}
