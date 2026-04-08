// a special-purpose control for flying mats
#include "include/subservers.h"

#ifndef debug
#define debug(x)
#endif

#ifndef NOTECARD_NAME
#define NOTECARD_NAME ".animations"
#endif

#ifndef PAUSE_TIME
#define PAUSE_TIME 1.1
#endif

#ifndef MAX_SERVERS
#define MAX_SERVERS 1
#endif

#ifndef REZZERCMD
#define REZZERCMD llMessageLinked(LINK_THIS, rezTargetNew, obj + "|" + (string) m[3] + "|" + (string) m[4] + "|" + (string) m[5] + "|" + (string) m[2], requester)
#endif

#define ANIMATE 101

integer animator_1_prim;
integer animator_2_prim;

list poses;

integer handle;
key note_handle;

integer pausep;

integer find(string s, list l) {
  integer i = llGetListLength(l);
  while (i > 0) {
    --i;
    if (llList2String(l,i) == s) return TRUE;
  }
  return FALSE;
}

// when the mat is a balloon-like vehical and the animations allow flying
list translateAnimation(list data) {
  string a = (string) data[0];
  string dom_animation;
  string sub_animation;
  list return_value = [];
  string s = ""; // movement state
  string d = ""; // movement direction
  integer l = llGetListLength(data);
  if (l > 0) {
    s = (string) data[1];
    if (l > 1) d = (string) data[2];
  }
  
  switch(a) {
  case "Cuddle": {
    dom_animation = "Cuddle Carry";
    if (d == "Hover") {
      dom_animation = dom_animation + d + " - M";
    } else {
      dom_animation  = dom_animation + " " + s + " " + d + " - M";
    }
    sub_animation = "Cuddle Carry";
    if (d == "Forward") {
      sub_animation  = sub_animation + " " + s + " " + d + " - F";
    } else {
      sub_animation = sub_animation + " - F";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Drag Leg": {
    dom_animation = "Drag By Ankle ";
    sub_animation = "Drag By Ankle - ";
    if (d == "Hover") {
      dom_animation = dom_animation + d + " - M";
      sub_animation = sub_animation + d;
    } else {
      sub_animation  = sub_animation + s + " " + d + " - F";
      dom_animation  = dom_animation + "- " + s + " " + d + " - M";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Drag Hair": {
    dom_animation = "Drag By Hair - ";
    sub_animation = "Drag By Hair - ";
    if (d == "Hover") {
      dom_animation = dom_animation + d + " - M";
      sub_animation = sub_animation + d + " - F";
    } else {
      dom_animation  = dom_animation + s + " " + d + " - M";
      sub_animation  = sub_animation + s + " " + d + " - F";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Hang": {
    dom_animation = "Hang On Walk ";
    if (d == "Hover") {
      dom_animation = dom_animation + d + " - M";
      sub_animation = "Hang On Walk " + d + " - F";
    } else {
      dom_animation  = dom_animation + s + " " + d + " - M";
      sub_animation = "Hang On Walk " + s + " " + d + " - F";      
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Hug": {
    dom_animation  = "Hug ";
    if (d == "Hover") {
      dom_animation = dom_animation + d + " - M";
            sub_animation  = "Hug " + d + " - F";
    } else {
      dom_animation  = dom_animation + s + " " + d + " - M";
      sub_animation  = "Hug " + s + " " + d + " - F";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "In Arms": {
    dom_animation = "Carry In Arms -" + s + " " + d + " - M";
    if (d == "Forward")
      sub_animation = "Carry In Arms -" + s + " " + d + " - F";
    else
      sub_animation = "Carry In Arms - F";
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Piggyback": {
    if (d != "Forward") {
      sub_animation = "MultiWalker PiggyBack-" + s + " " + d + "-F";
      dom_animation = "MultiWalker PiggyBack-" + s + " " + d + " - M";
    } else{
      sub_animation = "MultiWalker PiggyBack-" + s + " " + d + " - F";
      dom_animation = "MultiWalker PiggyBack-" + s + " " + d + "-M";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Ride": {
    dom_animation  = "Ride on Back " + s + " " + d + " - M";
    if (d == "Hover")
      sub_animation = "Ride On Back Walk still - F";
    else
      sub_animation  = "Ride on Back " + s + " " + d + " - F";

    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Saddlebag": {
    if (d == "Hover") {
      dom_animation = "Carry On Shoulders - "  + d + " - M";
    } else {
      if (d == "Down")
	sub_animation = "Carry On Shoulders - "  + d + " -F";
      else
	sub_animation = "Carry on Shoulders - "  + s + " " + d + " - F";
       dom_animation ="Carry On Shoulders - "  + s + " " + d + " - M";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  case "Wheelbarrow" {
    if (d == "Hover") {
      dom_animation = "Wheelbarrow " + d + " - M";
      sub_animation = "Wheelbarrow " + d + " - F";
    } else{
      dom_animation = "Wheelbarrow " + s + " " + d + " - M";
      sub_animation = "Wheelbarrow " + s + " " + d + " - F";
    }
    return_value = [dom_animation, sub_animation];
    break;
  }
  default: {
    integer l = llGetListLength(poses);
    integer x = 0;
    //    debug("poses length "+(string) l);
    while (x < l) {
      //debug((string) poses[x] + " =? " + (string) data[0]);
      if ((string) poses[x] == (string) data[0]) return llList2List(poses, x+1, x+2);
      x += 3;
    }
  }
  }
  return return_value;
}

default {
  state_entry() {
    // my channel
    handle = llListen(serverChannel, "", NULL_KEY, "");

    // find the animators
    integer objectPrimCount = llGetObjectPrimCount(llGetKey());
    integer currentLinkNumber = 0;
    animator_1_prim = animator_2_prim = -1;
    while(currentLinkNumber <= objectPrimCount) {
      list params = llGetLinkPrimitiveParams(currentLinkNumber,
					     [PRIM_NAME, PRIM_DESC]);
      if ((string) params[0] == "Animator") {
	if (((integer)(string) params[1] ) == 1)
	  animator_1_prim = currentLinkNumber;
	else
	  animator_2_prim = currentLinkNumber;
      }
      ++currentLinkNumber;
    }
    if (animator_1_prim == -1 || animator_2_prim == -1) {
      llSay(0, "Error: cannot find animator prims");
    }
    llSay(0, "Reading animations file...");
    note_handle = llGetNumberOfNotecardLines(NOTECARD_NAME);
  }

  // pose|<sequence>|<sequence>
  // <sequence> = animation (?+flex(?: time))(? ~<sequence>)
  dataserver(key request, string data)  {
    if (request == note_handle) {
      note_handle = NULL_KEY;
      integer count = (integer)data;
      integer index;
            
      for (index = 0; index < (count+1); ++index) {
	string line = llGetNotecardLineSync(NOTECARD_NAME, index);
	if (line == NAK) {
	  llOwnerSay("Notecard line reading failed");
	} else if (line != EOF) {
	  if (line != "") {
	    list l = llParseString2List(line, ["|"], []);
	    switch(llToLower((string) l[0])) {
	    case "pose": {
	      list p = llList2List(l,1,-1);
	      if (llGetListLength(p) == 3) poses = poses + p;
	      break;
	    }
	    default: break;
	    }
	  }
	} else {
	  llSay(0,"...done.");
	}
      }
    }
  }

  timer() {
    llSetTimerEvent(0);
    pausep = FALSE;
  }
  
  listen(integer chan, string name, key xyzzy, string msg) {
    if (pausep == TRUE) return;
    list m = llParseString2List(msg,["|"],[]);
    switch ((string) m[0]) {
      // rez the mat
    case REZCMD: {
      //      debug("rez "+msg);

      integer subserver;
      key requester = (key) (string) m[1];
      key mTarget = (key)(string) m[2];
      
      // message others to stop their animations
      for (subserver = 0; subserver < MAX_SERVERS; ++subserver) {
	if (subserver != SUBSERVER_ME)
	  llSay(SUBSERVER_FORCE_DETACH + subserver,
		(string) requester + "|" + (string)mTarget);
      }

      integer mStr = (integer) (string) m[3];
      integer mClan = (integer)(string) m[4];
      llRegionSayTo(mTarget, 0, llGetDisplayName(requester) + " wants to capture you.");
      // assign animation scripts
      //      debug("setting players ");
      llMessageLinked(animator_1_prim, setPlayer, (string) requester, requester);
      llMessageLinked(animator_2_prim, setPlayer, (string)mTarget, mTarget);      

      list avatarDetails = llGetObjectDetails(requester, [OBJECT_POS]);
      vector pos =(vector) avatarDetails[0];
            integer bar = llSubStringIndex(msg, "|");
      llRezObjectWithParams(OBJECT,
			    [REZ_PARAM, serverChannel,
			     REZ_POS, llGetPos()+<0.5,0.5,0>, FALSE, FALSE,
			     REZ_VEL, ZERO_VECTOR, FALSE, FALSE,
			     REZ_ROT, ZERO_ROTATION, FALSE,
			     REZ_PARAM_STRING,
			     (string) pos + "|" +
			     llGetSubString(msg, bar+1,-1)]);

      break;
    }
    case DIECMD : {
      //      debug("die "+msg);
      llMessageLinked(LINK_ALL_OTHERS,
		      killPlayer,
		      (string) m[1] + "|" + (string) m[2],
		      NULL_KEY);
      break;
    }
      // when the mat is warped, the integer param to the object is the server channel
      // (passed inside the mat on link channel -3031963)
      // the allows the mat to send animation messages
    case "animate": {
      debug("animate "+msg);
      // translated this into 1 and 2 then pass to the prim to execute
      list translation = translateAnimation(llList2List(m,3,-1));
      if (msg == "" || (string) translation[0] == "" || (string) translation[1] == "") {
	llOwnerSay("Animation not found "+msg);
	return;
      }
      debug("translate "+llDumpList2String(translation, " "));
      // should handle animation sequences in animators
      llMessageLinked(animator_1_prim, ANIMATE, (string) translation[0], (key) m[1]);
      llMessageLinked(animator_2_prim, ANIMATE, (string) translation[1], (key) m[2]);
      break;
    }

    default: break;
    }
  }
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != killAndPause) return;
    llSetTimerEvent(0);
    pausep = TRUE;
    llSetTimerEvent(PAUSE_TIME);
  }
  changed(integer f) {
    if (f & CHANGED_INVENTORY) {
      poses = [];
      llSay(0, "Reading animations file...");
      note_handle = llGetNumberOfNotecardLines(NOTECARD_NAME);
    }
  }
}

