#include "include/controlstack.h"
#include "include/computo.h"

// talks to the animation subserver for the region
// this subserver allows the region to share a
// set of animations (including no-copy, no-transfer) with
// people in the experience.

#ifndef debug
#define debug(x)
#endif

integer handle;
string channel;
key master;

default {
  state_entry() {
    integer chan = (integer)("0x"+llGetSubString((string) llGetKey(), -5, -1));
    handle = llListen(chan, "", NULL_KEY, "");
    channel = (string) chan;
    llListenControl(handle, FALSE);
  }
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != poseAvatar && chan != avatarPose) return;
    switch (chan) {
    case poseAvatar: {
      llListenControl(handle, TRUE);
      llSetTimerEvent(5);
      master = xyzzy;
      llRegionSay(evolveServerChannel,
		  "animate-menu|" + (string) llGetKey() + "|"  + channel);
      break;
    }
    case avatarPose: {
      GET_CONTROL;
      string animation;
      POP(animation);
      llRegionSay(evolveServerChannel, "animate|" + (string) master + "|" + animation);
      break;
    }
    default: break;
    }
  }
  listen(integer chan, string name, key xyzzy, string msg) {
    llSetTimerEvent(0);
    llListenControl(handle, FALSE);
    debug(msg);
    llMessageLinked(LINK_THIS, doMenu, s_avatarPose + "|Select pose|"+msg, master);
  }
  timer() {
    llSetTimerEvent(0);
    llListenControl(handle, FALSE);
  }
}
