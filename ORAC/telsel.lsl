#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

#define Forward "=>"
#define Backward "<="
#define Close "Close"

#define ActiveTime 20

integer menuChannel;

integer handle = 0;
integer active;

integer next;
string rest;
string data;
key agent;
string text;

list menu_items = [];
integer menuIter = 0;
list locations;

list getDialogItems() {
  integer len = llGetListLength(menu_items);
  list retval;
  if (menuIter == 0) {
    if (len > 11) {
      retval = [Forward, Close] + llList2List(menu_items, 0, 9);
    } else {
      retval = menu_items + [Close];
    }
  } else {
    if ((menuIter + 9) > len) {
      retval =llList2List(menu_items, menuIter, menuIter) +  [Close, Backward];
      if ((menuIter + 1) < len) retval = retval + llList2List(menu_items, menuIter + 1, -1);
    } else {
      retval = [Forward, Close, Backward] +  llList2List(menu_items, menuIter, menuIter + 8);
    }
  }
  return retval;
}

mFwd() {
  if (menuIter == 0) {
    menuIter = 10;
  } else {
    integer len = llGetListLength(menu_items);
    if (menuIter + 9 > len) return;
    menuIter += 8;
  }
} 
 
mBwd() {
  if (menuIter == 0) return;
  if (menuIter == 10) {
    menuIter = 0;
  } else {
    menuIter -= 8;
  }
}


default {
  state_entry() {
    menuIter=0; 
    menuChannel = (integer) ("0x"+llGetSubString((string)llGetKey(),-5,-1));
    handle = -1;
    active = FALSE;
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != select_location) return;
    string seq;
    string n;
    GET_CONTROL_GLOBAL;
    text = "";
    
    llSetTimerEvent(0);
    agent = xyzzy;
    handle = llListen(menuChannel, "", agent, "");

    POP(text);
    string s;
    POP(s);
    locations = llParseString2List(s, ["~"], []);
    integer len = llGetListLength(locations);
    integer i;
    list line;
    for (i = 0; i < len; i += 2) {
      line += llGetSubString((string)((i / 2) + 1)+") "+(string)locations[i],0,11);
    }
    menuIter=0; 
    menu_items= line; 
    llDialog(agent, text, getDialogItems(), menuChannel);
    llSetTimerEvent(ActiveTime);
  }
  
  listen(integer channel, string name, key  id,  string msg) {
    if (channel != menuChannel) return;
    debug("listen: "+msg);
    switch (msg) {
    case Close:  break;
    case Forward: {
      llSetTimerEvent(0);
      mFwd(); 
      llDialog(agent, text, getDialogItems(), menuChannel);
      llSetTimerEvent(ActiveTime);
      break;
    }
    case Backward: {
      llSetTimerEvent(0);
      mBwd();
      llDialog(agent, text, getDialogItems(), menuChannel);
      llSetTimerEvent(ActiveTime);
      break;
    }
    default: {
      llSetTimerEvent(0);
      key xyzzy = agent;
      integer p =(((integer) llGetSubString(msg, 0, llSubStringIndex(msg, ")") - 1)) - 1) * 2;
      debug(p);
      debug(locations[p]);
      PUSH(locations[p + 1]);
      PUSH(locations[p]);
      debug(msg);
      llListenRemove(handle);
      handle = -1;
      NEXT_STATE;
    }
    }
  }
  timer() {
    llSetTimerEvent(0);
    llListenRemove(handle);
    handle = -1;
  }
}

