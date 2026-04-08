#include "include/subservers.h"

#define ANIMATE 101
#define AnimateScriptBase 2076

#ifndef debug
#define debug(x)
#endif

#ifndef COLOR
#define COLOR <1,0,0>
#endif

list players;
integer index;

add_player(key p) {
  integer len = llGetListLength(players);
  if (len < MaxPlayers) {
    players = players + [p];
    debug("adding player as "+(string)index);
    index++;
    return;
  }
  if (index >= len) index = 0;
  debug("replacing player as "+(string)index);
  players = llListReplaceList(players, [p], index, index);
  index++;
}

integer find_player(key p) {
  integer len = llGetListLength(players);
  integer i;
  for (i = 0; i < len; ++i) if ((key) players[i] == p) return i;
  return -1;
}

integer remove_player(key p) { // bug,we need to move player
  integer len = llGetListLength(players);
  integer i;
  if (len == 1) {
    players = [];
    return 0;
  }
  for (i = 0; i < len; ++i)
    if ((key) players[i] == p) {
      if (i == 0) {
	players = llList2List(players, 1, -1);
      } else if (i == len - 1) {
	players = llList2List(players, 0, i - 1);
      } else {
	players = llList2List(players, 0, i - 1) + llList2List(players, i + 1, -1);
      }
      return i;
    }
  return -1;
}

default {
  state_entry() {
    players = [];
    index = 0;
    llListen(SubServerChannel, "", NULL_KEY, "");
    llListen(regionEmptyChan, "", NULL_KEY, "");
    llSetTimerEvent(60);
  }

  listen(integer chan, string name, key xyzzy, string msg) {
    if (chan == regionEmptyChan) {
      if (msg == "EMPTY") {
	players = [];
	return;
      }
      key p = (key) msg;
      remove_player(p);
      return;
    }
    key p = (key) msg;
    if (p == NULL_KEY) return;
    integer f = find_player(p);
    if (f != -1) llMessageLinked(LINK_THIS, 0 - (AnimateScriptBase + f), (string) p, p);
  }
  
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case setPlayer: {
      debug("set player " + msg);
      list ps = llParseString2List(msg,["|"], []);
      integer i = 0;
      integer len = llGetListLength(ps);
      while (i < len) {
	key p = (key)ps[i];
	integer f = find_player(p);
	if (f == -1) {
	  debug("adding player "+(string)p);		
	  add_player(p);
	} else {
	  if (f == index) {
	    index++;
	    if (index >= llGetListLength(players)) index = 0;
	  }
	}
	++i;
      }
      break;
    }
    case killAndPause:
    case killPlayer: {
      debug("kill player " + msg);
      list ps = llParseString2List(msg,["|"],[]);
      integer i;
      integer l = llGetListLength(ps);
      integer len = llGetListLength(players);
      for(i = 0; i < l; ++i) {
	key p = (key)(string)ps[i];
	integer f = find_player(p);
	if (f != -1) {
	  debug("sending stand for "+(string) p);
	  llMessageLinked(LINK_THIS, 0 - (AnimateScriptBase + f), "stand", p);
	  if (len == 1) {
	    players = [];
	  } else if (f == 0) {
	    players = llList2List(players, 1,-1);
	  } else if (f == (len - 1)) {
	    players = llList2List(players, 0, -2);
	  } else {
	    players = llList2List(players, 0, f - 1) + llList2List(players, f+1, -1);
	  }
	  --len;
	} 
      }
      break;
    }
    case ANIMATE: {
      integer x = find_player(xyzzy);
      if (x == -1) { debug("player not found "+(string) xyzzy); return; }
      debug("animate command server "+(string)x + " " + msg);
      llMessageLinked(LINK_THIS, AnimateScriptBase + x, msg, xyzzy);
      break;
    }
    default: break;
    }
  }

  timer() {
    if (players == []) llSetText("", COLOR, 1);
    string p = "";
    integer l = llGetListLength(players);
    while(--l >= 0) {
      p = p + llGetDisplayName((key) players[l]);
      if (l) p = p + " ";
    }
    llSetText(p, COLOR, 1);
  }
}
