#include "include/controlstack.h"
#include "include/subservers.h"

#define SubServerChannel 20230929
#define regionEmptyChan 20231027

#define ANIM 1
#define FLEXES 2
#define oSTRIDE 3

#define killPlayer 20230
list poses = [ ];

#ifndef debug
#define debug(x)
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

integer remove_player(key p) {
  integer len = llGetListLength(players);
  integer i;
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
    if (f != -1) {
      llMessageLinked(LINK_THIS, 0 - (remoteAnimate0 + f), (string) p, p);
    }
  }
  
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case setPlayer: {
      debug("set player " + msg);
      list ps = llParseString2List(msg,["|"],[]);
      integer i;
      integer l = llGetListLength(ps);
      integer len = llGetListLength(players);
      for(i = 0; i < l; ++i) {
	key p = (key)(string)ps[i];
	integer f = find_player(p);
	if (f == -1) {
	  debug("adding player "+(string)ps[i]);		
	  add_player(p);
	} else {
	  if (f == index) {
	    index++;
	    if (index >= len) index = 0;
	  }
	}
      }
      break;
    }
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
	  llMessageLinked(LINK_THIS, 0 - (remoteAnimate0 + f), "Stand", p);
	} else { debug("player not found "+(string) xyzzy); }
      }
      break;
    }
    case remoteAnimateAvatar:
      msg = llGetSubString(msg,1,-1);
    case animateAvatar: {
      if (msg != "" && llSubStringIndex(msg,"|") == -1)  {
	integer x = find_player(xyzzy);
	if (x == -1) { debug("player not found "+(string) xyzzy); return; }
	debug("server "+(string)x + " " + msg);
	llMessageLinked(LINK_THIS, remoteAnimate0 + x, msg, xyzzy);
      }
      break;
    }
    default: break;
    }
  }
}


