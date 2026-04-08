#include "include/subservers.h"

#ifndef debug
#define debug(x)
#endif

#ifndef NOTECARD_NAME
#define NOTECARD_NAME ".animations"
#endif

#ifndef PAUSE_TIME
#define PAUSE_TIME 3
#endif

#ifndef REZZERCMD
#define REZZERCMD llMessageLinked(LINK_THIS, rezTargetNew, obj + "|" + (string) m[3] + "|" + (string) m[4] + "|" + (string) m[5] + "|" + (string) m[2], requester)
#endif

#define ANIMATE 101

#define rezTargetNew -412

integer animator_1_prim;
integer animator_2_prim;

list poses;

integer handle;
integer dhandle;
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

list translateAnimation(list data) {
  integer l = llGetListLength(poses);
  integer x = 0;
  while (x < l) {
    if ((string) poses[x] == (string) data[0]) return llList2List(poses, x+1, x+2);
	x += 3;
  }
  return [];
}

default {
  state_entry() {
    // my channel
    handle = llListen(serverChannel, "", NULL_KEY, "");
    // it an avatar is seated and someone wants to grab him for detach
    dhandle = llListen(SUBSERVER_FORCE_DETACH + SUBSERVER_ME,
		       "",
		       NULL_KEY, "");

    // find the animators
    integer objectPrimCount = llGetObjectPrimCount(llGetKey());
    integer currentLinkNumber = 0;
    animator_1_prim = animator_2_prim = -1;
    debug(objectPrimCount);
    while(currentLinkNumber <= objectPrimCount) {
      debug(currentLinkNumber);
      list params = llGetLinkPrimitiveParams(currentLinkNumber,
					     [PRIM_NAME, PRIM_DESC]);
      debug((string) params[0] + " " + (string) params[1]);
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
	  llOwnerSay("Notecare line reading failed");
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
	}
      }
    }
  }

  timer() {
    llSetTimerEvent(0);
    pausep = FALSE;
  }
  
  listen(integer chan, string name, key xyzzy, string msg) {
    if (chan == (SUBSERVER_FORCE_DETACH + SUBSERVER_ME)) {
      llSetTimerEvent(0);
      llMessageLinked(LINK_THIS, killPlayer, msg, NULL_KEY);
      pausep = TRUE;
      llSetTimerEvent(PAUSE_TIME);
      return;
    }
    if (pausep == TRUE) return;
    list m = llParseString2List(msg,["|"],[]);
    switch ((string) m[0]) {
      // rez the mat
    case REZCMD: {
      debug(msg);

      integer subserver;
      key requester = (key) (string) m[1];
      key mTarget = (key)(string) m[3];
      
      // message others to stop their animations
      for (subserver = 0; subserver < MAX_SERVERS; ++subserver) {
	if (subserver != SUBSERVER_ME)
	  llSay(SUBSERVER_FORCE_DETACH + subserver,
		(string) requester + "|" + (string)mTarget);
      }

      string obj = OBJECT;
      string mAnimation = (string) m[2];
      integer mStr = (integer) (string) m[4];
      integer mClan = (integer)(string) m[5];
      llRegionSayTo(mTarget, 0, llGetDisplayName(requester) + " wants to capture you.");
      // assign animation scripts
      llMessageLinked(animator_1_prim, setPlayer, (string) requester, requester);
      llMessageLinked(animator_2_prim, setPlayer, (string)mTarget, mTarget);      
      REZZERCMD;
      break;
    }
    case DIECMD : {
      debug("die "+msg);
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
      debug(msg);
      // translated this into 1 and 2 then pass to the prim to execute
      list translation = translateAnimation(llList2List(m,1,-1));
      // should handle animation sequences in animators
      llMessageLinked(animator_1_prim, ANIMATE, (string) translation[0], (key) m[2]);
      llMessageLinked(animator_2_prim, ANIMATE, (string) translation[1], (key) m[3]);
      break;
    }

    default: break;
    }
  }
}
