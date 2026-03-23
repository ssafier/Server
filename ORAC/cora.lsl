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
    if (chan == coraCommand) avatar = xyzzy;
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
