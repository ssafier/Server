#include "include/controlstack.h"

#define CORA 109

#ifndef debug
#define debug(x)
#endif

integer handle;
integer channel;
key avatar;
string default_value;

GLOBAL_DATA;

default {
  state_entry() {
    channel = (integer) ("0x"+llGetSubString((string) llGetKey(),-6, -1));
    handle = llListen(channel,"ORAC",NULL_KEY,"");
    llListenControl(handle, FALSE);
    default_value = "strength+1+intelligence+1+combat+1+power+1+durability+1+alignment+1+tier+1+enabled+0";
  }
  
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != CORA) return;
    llListenControl(handle, TRUE);
    GET_CONTROL_GLOBAL;
    llSetTimerEvent(2.5);
    avatar = xyzzy;
    llShout(321,"502+999|" + (string)xyzzy + "|" + (string)llGetKey() + "|" + (string) channel);
  }
  
  listen(integer chan, string name, key xyzzy, string msg) {
    list params = llParseString2List(msg, ["|"], []);
    if (llGetKey() != (key)(string)params[0]) return;
    llSetTimerEvent(0);
    llListenControl(handle, FALSE);
    if ((string)params[1] != "-1") {
      PUSH((string)params[1]);
    } else {
      PUSH(default_value);
    }
    xyzzy = avatar;
    NEXT_STATE;
  }
  timer() {
    llRegionSayTo(avatar, 0, "Cannot find ORAC...");
    llSetTimerEvent(0);
    llListenControl(handle, FALSE);
    PUSH(default_value);
    key xyzzy = avatar;
    NEXT_STATE;
  }
}
