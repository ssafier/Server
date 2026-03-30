#include "include/controlstack.h"
#include "include/computo.h"
#include "include/mpg.h"

#define portalTarget avi
#include "include/particles/atom.h"

#ifndef debug
#define debug(x)
#endif

integer handle;
key request;

// support roleplay
list character_rp;
integer character_enabled;

teleportEffect(key avi) {
  llParticleSystem(ATOM);
}

integer getMPG(string attr, list char) {
  integer i = llListFindStrided(char, [attr], 0, -1, 2);
  if (i != -1) return -1;
  return (integer) char[i + 1] - 1;
}

printMPG(list char, key avi) {
  list strength = StrengthText;
  list combat = CombatText;
  list energy = EnergyText;
  list durability = DurabilityText;
  list intelligence = IntelligenceText;
  list alignment = AlignmentText;
  list speed = SpeedText;
  
  llRegionSayTo(avi, 0, "Strength: "+(string) strength[getMPG("strength", strength)]);
  llRegionSayTo(avi, 0, "Intelligence: "+(string) intelligence[getMPG("intelligence", intelligence)]);
  llRegionSayTo(avi, 0, "Speed: "+(string) speed[getMPG("speed", speed)]);
  llRegionSayTo(avi, 0, "Combat: "+(string) combat[getMPG("combat", combat)]);
  llRegionSayTo(avi, 0, "Energy Projection: "+(string) energy[getMPG("energy", energy)]);
  llRegionSayTo(avi, 0, "Durability: "+(string) durability[getMPG("durability", durability)]);
  llRegionSayTo(avi, 0, "Alignment: "+(string) alignment[getMPG("alignment", alignment)]);
}

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != Welcome &&
	chan != getCharacter) return;
    GET_CONTROL;
    switch (chan) {
    case Welcome: {
      string roleplay;
      POP(roleplay);
      string rp_check = llJsonGetValue(roleplay,["strength","intelligence","combat","power","durability","alignment","tier"]);
      character_rp = [];
      character_enabled = FALSE;
      if (rp_check != JSON_INVALID &&
	  rp_check != JSON_NULL) {
	character_rp = llJson2List(roleplay);
	integer index = llListFindStrided(character_rp, ["enabled"], 0, -1, 2);
	string value = (string) character_rp[index + 1];
	if (value == "true") character_enabled = TRUE;
      }

      string a;
      PEEK(a);
      key avi = (key) a;
      debug(a);
      vector size = llGetAgentSize(avi);
      if (size == ZERO_VECTOR) return;
      PUSH(size);
      handle = llListen(123, "",  avi, "");
      llRegionSayTo(avi, 0, "Welcome " + llGetDisplayName(avi) +".  I am you personal interface to this region.");
      if (character_rp != []) {
	llRegionSayTo(avi, 0, "I have loaded your roleplay character.");
      }
      llRegionSayTo(avi, 0, "type '/123 help' for more information.");
      llMessageLinked(LINK_THIS, coraCommand, (string) avi, avi);
      break;
    }
    case getCharacter: {
      if (character_enabled) {
	PUSH(llDumpList2String(character_rp, "+"));
      } else {
	PUSH("-1");
      }
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
	if (character_rp != []) {
	  if (character_enabled) {
	    llRegionSayTo(xyzzy, 0, "rp disable -- stop roleplaying");
	    llRegionSayTo(xyzzy, 0, "scan -- find other players nearby");
	  } else {
	    llRegionSayTo(xyzzy, 0, "rp enable -- start roleplaying");
	  }
	  llRegionSayTo(xyzzy, 0, "rp me -- describe your character");
	} else {
	  llRegionSayTo(xyzzy, 0, "rp -- create a Marvel Power Grid character to roleplay");
	}
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
    case "scan": {
      llMessageLinked(LINK_THIS, scanRolePlayer, "|", xyzzy);
      break;
    }
    case "rp": {
      if (character_rp == []) {
	return;
      }
      switch ((string) tokens[1]) {
      case "me": {
	printMPG(character_rp, xyzzy);
	break;
      }
      case "enable": {
	character_enabled = TRUE;
	break;
      }
      case "disable": {
	character_enabled = FALSE;
	break;
      }
      default: break;
      }
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
