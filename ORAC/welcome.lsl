#include "include/controlstack.h"
#include "include/computo.h"

#define portalTarget avi
#include "include/particles/atom.h"

#ifndef debug
#define debug(x)
#endif

integer handle;
key request;

teleportEffect(key avi) {
  llParticleSystem(ATOM);
}

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != Welcome) return;
    GET_CONTROL;
    switch (chan) {
    case Welcome: {
      string a;
      PEEK(a);
      key avi = (key) a;
      debug(a);
      handle = llListen(123, "",  avi, "");
      llRegionSayTo(avi, 0, "Welcome " + llGetDisplayName(avi) +".  I am you personal interface to this region.");
      llRegionSayTo(avi, 0, "type '/123 help' for more information.");
      llMessageLinked(LINK_THIS, coraCommand, (string) avi, avi);
      break;
    }
    default: break;
    }
    NEXT_STATE;
  }
  
  listen(integer chan, string name, key xyzzy, string msg) {
    msg = llToLower(msg);
    list tokens = llParseString2List(msg, [" "],[]);
    switch ((string) tokens[0]) {
    case "help": {
      llRegionSayTo(xyzzy, 0, "help -- this message");
      llRegionSayTo(xyzzy, 0, "teleport -- choose a location to visit");
      llRegionSayTo(xyzzy, 0, "flymat -- a couple's flying pose mat");
      if (llAgentInExperience(xyzzy)) {
	llRegionSayTo(xyzzy, 0, "pose -- various bodybuilder poses");
      } else {
	llRegionSayTo(xyzzy, 0, "experience -- Join the Evolution experience to access more options.");
      }
      break;
    }
    case "pose": {
      llMessageLinked(LINK_THIS, poseAvatar, "|" + (string) xyzzy, xyzzy);
      break;
    }
    case "experience": {
      llRequestExperiencePermissions(xyzzy, "");
      break;
    }
    case "teleport": {
      teleportEffect(xyzzy);
      llMessageLinked(LINK_THIS, getLocations, "|", xyzzy);
      llSetTimerEvent(30);
      break;
    }
    case "flymat": {
      llMessageLinked(LINK_THIS, targetNearby, s_rezFlyMat + "|", xyzzy);
      break;
    }
    case "vampire": {
      llMessageLinked(LINK_THIS, targetNearby, s_rezVampireMat + "|", xyzzy);
      break;
    }
    default: {
      llRegionSayTo(xyzzy, 0, "Unknown command "+msg+".  Type HELP for instructions.");
      break;
    }
    }
  }

  experience_permissions(key avi) {
    llRegionSayTo(avi, 0, "Welcome.  Evolution options unlocked.");
  }

  experience_permissions_denied(key avi, integer reason) {
    llRegionSayTo(avi, 0, "OK.  Evolution opions remain locked.");
  }
  
  timer() {
    llSetTimerEvent(0);
    llParticleSystem([]);
  }
}
