#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

integer handle;
key avatar;

default {
  on_rez(integer x) {
    handle = llListen(321,"",NULL_KEY,"");
  }
  state_entry() {
      handle = llListen(321,"",NULL_KEY,"");
      //avatar = (key) "c4814bb6-38d1-4e6b-9ccb-51a3b0ef0ded";
  }
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case coraCommand: {
      avatar = xyzzy;
      break;
    }
    case sendBack: {
      //llSay(0,"sending "+msg);      
      list l = llParseString2List(msg, ["|"], []);
      string channel = (string) l[llGetListLength(l)-1];
      string whom = (key)(string) l[llGetListLength(l) - 2];
      debug(channel + " " + (string) whom + "|" + llDumpList2String(llList2List(l,1,-3), "|"));
      llRegionSay((integer) channel, (string) whom + "|" + llDumpList2String(llList2List(l,1,-3), "|"));

      break;
    }
    default: break;
    }
  }
  listen(integer chan, string name, key xyzzy, string msg) {
    debug("cora "+msg);
    LISTEN_CONTROL;
    string avi;
    POP(avi);
    debug(msg);
    if ((key) avi != avatar || avatar == NULL_KEY) return;
    xyzzy = avatar;
    debug("rest "+rest);
    debug("seq " + seq);
    UPDATE_NEXT(chan);
    NEXT_STATE;
  }
}
