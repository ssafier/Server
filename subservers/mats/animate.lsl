#include "include/subservers.h"

#define getAnimationFlex(anim) mkFlexCmd(llGetSubString(anim,0, llSubStringIndex(anim, "+") - 1))

#define ANIMATION_SLAVE_0 200

#ifndef debug
#define debug(x)
#endif

key currentAvatar = NULL_KEY;

#define ANIM_NAME 0
#define FLEX 1
#define TIME 2
list animation = [];
list animations = [];
integer count = 0;
integer index = 0;

// -------------------------
stopAllAnims(key avi) {
  list anims = llGetAnimationList(avi);
  integer len = llGetListLength(anims);
  integer i = 0;
  for (i=0; i<len; ++i) {
    llStopAnimation((key) anims[i]);
  }
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

// -------------------------
string getFlex() { 
  if (llGetListLength(animation) > 0 && (string) animation[FLEX] != "") {
    return (string) animation[FLEX];
  }
  return "00000000000000000+0";
}

// -------------------------
float getTime() { 
  if (llGetListLength(animation) > 1 && (string) animation[TIME] != "") {
    return (float) (string) animation[TIME];
  }
  return 0;
}
// -------------------------
list nextAnimation() {
  ++index;
  if (index >= count) index = 0;
  return llParseStringKeepNulls((string) animations[index], [":"],[]);
}

// ----------------------
default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != MyAnimate && chan != -(MyAnimate)) return;
    llSetTimerEvent(0);
    if (chan == -(MyAnimate)) {
      animations = animation = [];
      count = index = 0;
    } else {
      animations = llParseString2List(msg,["|"],[]);
      count = llGetListLength(animations);
      if (count == 0) { llOwnerSay("animation count is 0 " + msg); return; }
      animation = llParseStringKeepNulls((string) animations[index = 0], [":"],[]);
    }
    debug("animation "+llDumpList2String(animation,":"));
    llRequestExperiencePermissions(xyzzy, "");
  }

  experience_permissions(key avi) {
    stopAllAnims(currentAvatar = avi);
    if (animation == []) return;
    integer length = llGetListLength(animation);
    float t = 0.0;
    if (length > 0) {
      string c = getFlex();
      string f = (string) avi + getAnimationFlex(c);
      llRegionSayTo(avi, flexChannel, f);
      if (length > 1) t =(float)(string) animation[TIME];
    }
    llStartAnimation((string) animation[ANIM_NAME]);
    llSetTimerEvent(t);
  }
  
  timer() {
    llSetTimerEvent(0);
    animation = nextAnimation();
    debug("timer animation "+llDumpList2String(animation, " "));
    key avi = currentAvatar;
    integer length = llGetListLength(animation);
    float t = 0.0;
    if (length > 0) {
      string c = getFlex();
      string f = (string) avi + getAnimationFlex(c);
      llRegionSayTo(avi, flexChannel, f);
      if (length > 1) t =(float)(string) animation[TIME];
    }
    llStartAnimation((string) animation[ANIM_NAME]);
    llSetTimerEvent(t);
  }
}
