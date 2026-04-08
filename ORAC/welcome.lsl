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

integer JsonCheck(string json, list ks) {
  integer l = llGetListLength(ks);
  while (ks != []) {
    string k = (string) ks[0];
    string v = llJsonGetValue(json, [k]);
    if (v == JSON_INVALID || v == JSON_NULL)  return FALSE;
    if (l > 1) {
      --l;
      ks = llList2List(ks, 1, -1);
    } else {
      ks = [];
      l = 0;
    }
  }
  return TRUE;
}    

teleportEffect(key avi) {
  llParticleSystem(ATOM);
}

integer getMPG(string attr) {
  integer i = llListFindStrided(character_rp, [attr], 0, -1, 2);
  if (i == -1) return -1;
  return (integer) character_rp[i + 1] - 1;
}

printMPG(list char, key avi) {
  list strength = StrengthText;
  list combat = CombatText;
  list energy = EnergyText;
  list durability = DurabilityText;
  list intelligence = IntelligenceText;
  list alignment = AlignmentText;
  list speed = SpeedText;

  llRegionSayTo(avi, 0, "Strength: "+(string) strength[getMPG("strength")]);
  llRegionSayTo(avi, 0, "Intelligence: "+(string) intelligence[getMPG("intelligence")]);
  llRegionSayTo(avi, 0, "Speed: "+(string) speed[getMPG("speed")]);
  llRegionSayTo(avi, 0, "Combat: "+(string) combat[getMPG("combat")]);
  llRegionSayTo(avi, 0, "Energy Projection: "+(string) energy[getMPG("power")]);
  llRegionSayTo(avi, 0, "Durability: "+(string) durability[getMPG("durability")]);
  llRegionSayTo(avi, 0, "Alignment: "+(string) alignment[getMPG("alignment")]);
}

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != Welcome &&
	chan != getCharacter &&
	chan != updateCharacter) return;
    GET_CONTROL;
    switch (chan) {
    case Welcome: {
      string roleplay;
      POP(roleplay);
      integer rp_check = JsonCheck(roleplay,["strength","speed", "intelligence","combat","power","durability","alignment","tier"]);
      character_rp = [];
      character_enabled = FALSE;
      if (rp_check != FALSE) {
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
    case updateCharacter: {
      msg = llGetSubString(msg, 1,-1);
      integer rp_check = JsonCheck(msg,["strength","speed", "intelligence","combat","power","durability","alignment","tier"]);
      if (rp_check  == TRUE) {
	character_rp = llJson2List(msg);
	integer index = llListFindStrided(character_rp, ["enabled"], 0, -1, 2);
	string value = (string) character_rp[index + 1];
	if (value == "true") character_enabled = TRUE;
	llRegionSayTo(xyzzy, 0, "I have received an update to your roleplay character.");
      } else llOwnerSay("Json check failed.");
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
      if (character_rp == [] || character_enabled == FALSE)
	llRegionSayTo(xyzzy, 0, "teleport -- choose a location to visit");
      llRegionSayTo(xyzzy, 0, "flymat -- a couple's flying pose mat");
      if (llAgentInExperience(xyzzy)) {
	llRegionSayTo(xyzzy, 0, "pose -- various bodybuilder poses");
	if (character_rp != []) {
	  if (character_enabled) {
	    llRegionSayTo(xyzzy, 0, "rp disable -- stop roleplaying");
	    if (getMPG("power") > 0)
	      llRegionSayTo(xyzzy, 0, "scan -- find other players nearby");
	    if (getMPG("speed") > 2 || getMPG("power") > 2)
	      llRegionSayTo(xyzzy, 0, "teleport -- choose a location to visit");
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
      if (character_rp == [] ||
	  character_enabled == FALSE ||
	  getMPG("speed") > 2 ||
	  getMPG("power") > 2) {
	teleportEffect(xyzzy);
	llMessageLinked(LINK_THIS, getLocations, "|", xyzzy);
	llSetTimerEvent(30);
      }
      break;
    }
    case "scan": {
      integer power = getMPG("power");
      if (power > 0)
	llMessageLinked(LINK_THIS, scanRolePlayer, "|" + (string) power, xyzzy);
      break;
    }
    case "rp": {
      if (character_rp == []) {
	return;
      }
      switch ((string) tokens[1]) {
      case "me": {
	llRegionSayTo(xyzzy,0,"----");
	llRegionSayTo(xyzzy,0,"You: ");
	printMPG(character_rp, xyzzy);
	break;
      }
      case "enable": {
	character_enabled = TRUE;
	llRegionSayTo(xyzzy, 0, "RP enabled.");
	break;
      }
      case "disable": {
	character_enabled = FALSE;
	llRegionSayTo(xyzzy, 0, "RP disabled.");
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
