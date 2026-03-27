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
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case coraCommand: {
      avatar = xyzzy;
      break;
    }
    case sendBack: {
      list l = llParseString2List(msg, ["|"], []);
      string channel = (string) l[llGetListLength(l)-1];
      string whom = (key)(string) l[llGetListLength(l) - 2];
      debug(channel + " " + (string) whom + "|" + llDumpList2String(llList2List(l,0,-2), "|"));
      llRegionSay((integer) channel, (string) whom + "|" + llDumpList2String(llList2List(l,0,-3), "|"));

      break;
    }
    default: break;
    }
  }
  listen(integer chan, string name, key xyzzy, string msg) {
    GET_CONTROL;
    string avi;
    POP(avi);
    debug(msg);
    debug(avi+" "+(string) avatar);
    if ((key) avi != avatar || avatar == NULL_KEY) return;
    NEXT_STATE;
  }
}
