// NOTE: This file is duplicated N (n = 10 in my case) times, once for each
//  player to animation.  A player is assigned to a version of this script, which gets
//  the experience permission to animate the avatar.

#include "include/controlstack.h"
#include "include/subservers.h"

#define ANIM 1
#define FLEXES 2
#define oSTRIDE 3

list poses = [  ];

#ifndef STAND
#define STAND "SE-Man_03"
#endif

#ifndef debug
#define debug(x)
#endif

key currentAvatar = NULL_KEY;
string animation = "";
string flex;
#include "src/server/subservers/animation/alist.lsl"

stopAllAnims(key avi) {
  list anims = llGetAnimationList(avi);
  integer len = llGetListLength(anims);
  integer i = 0;
  for (i=0; i<len; ++i) {
    llStopAnimation((key) anims[i]);
  }
}

string getFlex(string anim, list f) { // poses or flexes
  integer i = 0;
  integer l = llGetListLength(f);
  while (i < l) {
    if ((string) f[i + ANIM] == anim) {
      return (string) f[i+FLEXES];
    }
    i = i + oSTRIDE;
  }
  return "00000000000000000+0";
}

string findAnimation(string anim, list f) {
  integer i = 0;
  integer l = llGetListLength(f);
  while (i < l) {
    if ((string) f[i] == anim) {
      return (string) f[i+ANIM];
    }
    i = i + oSTRIDE;
  }
  debug("animation not found");
  return STAND;
}

float getTime(string anim) {
  debug("time "+ anim + " " + llGetSubString(anim,llSubStringIndex(anim, "+") + 1, -1));
  return (float) llGetSubString(anim,llSubStringIndex(anim, "+") + 1, -1);
}

string mkFlexCmd(string encoding) {
  integer len = llStringLength(encoding);
  if (llStringLength(encoding) != 17) return cOffString;
  integer i;
  string out = "";
  string n = "";
  string name = "";
  list fo = flexOrder;
  for (i = 0; i < len; ++i) {
    name = (string) fo[i];
    n = llGetSubString(encoding,i,i);
    if (i < 15) {
      if (n == "0") {
	out = out + "|" + name + "|OFF";
      } else {
	out = out + "|" + name  + "|ON" + n;
      }
    } else {
      string o;
      switch(n) {
      case "0": { o = "RELAX"; break;}
      case "1": { o = "FIST"; break; }
      case "2": { o = "FLAT"; break; }
      case "3": { o = "GRAP"; break; }
      case "4": { o = "HORN"; break; }
      case "5": { o = "OK"; break; }
      case "6": { o = "POINT"; break; }
      case "7": { o = "THUMB"; break; }
      case "8": { o = "VICTORY"; break; }
      default: { o = "RELAX"; break; }
      }
      out = out + "|" + name  + "|" + o;
    }
  }
  return out;
}

string getAnimationFlex(string anim) {
  debug("flex is "+mkFlexCmd(llGetSubString(anim,0, llSubStringIndex(anim, "+") - 1)));
  return mkFlexCmd(llGetSubString(anim,0, llSubStringIndex(anim, "+") - 1));
}

string currentFlex(string f) {
  integer x = llSubStringIndex(f, "|");
  if (x > 0)
    return llGetSubString(f,0, x - 1);
  return f;
}

string nextFlexes(string f) {
  integer x = llSubStringIndex(f, "|");
  if (x > 0)
    return llGetSubString(f,x + 1, -1);
  return "";
}

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (xyzzy == NULL_KEY) return;
    switch(chan) {
    case remoteStop: {
      animation = "[STOP]";
      flex = "00000000000000000+0";
      llRequestExperiencePermissions(xyzzy, "");
      break;
    }
    case remoteAnimateStand: 
    case animateStand: {
      debug("stand");
      animation = STAND;
      flex = "00000000000000000+0";
      llRequestExperiencePermissions(xyzzy, "");
      break;
    }
    case remoteAnimateAvatar:
      msg = llGetSubString(msg,1,-1);
    case animateAvatar: {
      animation = "";
      if (msg != "") {
	animation = findAnimation(msg, flexes);
	flex = getFlex(animation, flexes);
	debug("flex flexes "+msg+" "+flex + " " + animation+" "+(string)xyzzy);
	llRequestExperiencePermissions(xyzzy, "");
      }
      break;
    }
    case remoteAnimatePose:
      msg = llGetSubString(msg,1,-1);
    case animatePose: {
      animation = "";
      if (msg != "") {
	animation = findAnimation(msg, poses);
	debug("animation "+animation);
	flex = getFlex(animation, poses);
	debug("flex pose "+flex+" "+animation+" "+msg);
	llRequestExperiencePermissions(xyzzy, "");
      }
      break;
    }
    /* case floaterDie: {
      stopAllAnims(currentAvatar);
      currentAvatar = NULL_KEY;
      break;
      }*/
    default: break;
    }
  }
  
  experience_permissions(key avi) {
    stopAllAnims(currentAvatar = avi);
    if (animation != "[STOP]") {
      string c = currentFlex(flex);
      flex = nextFlexes(flex);
      llStartAnimation(animation);
      llRegionSayTo(avi, flexChannel, (string) avi + getAnimationFlex(c));
      debug("starting "+animation + " "+(string)avi + " " + (string) getTime(c));
      llSetTimerEvent(getTime(c));
    } else {
      llSetTimerEvent(0);
      llRegionSayTo(avi, flexChannel, (string) avi + cOffString);
      llStartAnimation("stand");
    }
  }
  
  timer() {
    llSetTimerEvent(0);
    string c = currentFlex(flex);
    key avi = currentAvatar;
    flex = nextFlexes(flex);

    debug("timer c = "+c);
    if (c != "") {
      llRegionSayTo(avi, flexChannel, (string) avi + getAnimationFlex(c));
      debug(getTime(c));
      llSetTimerEvent(getTime(c));
    } else {
      stopAllAnims(currentAvatar);
      if (llAvatarOnSitTarget() == NULL_KEY) {
	llStartAnimation("stand");
      } else {
	llStartAnimation(STAND);
      }
      llRegionSayTo(avi, flexChannel, (string) avi + cOffString);
      currentAvatar = NULL_KEY;
    }
  }
}


