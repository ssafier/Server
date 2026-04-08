// Scanning is a varient of telepathy.
// level 7, region and location
// level 6, region, parcel location
// level 5, parcel and location
// level 4, parcel
// level 3, 96 meters
// level 2, llSay range

#include "include/controlstack.h"
#include "include/computo.h"
#include "include/mpg.h"

#ifdef LOCATION
#define INC 1
#else
#define INC 2
#endif

integer mychan;
integer handle;
key player;
list agents;
key agent;
integer length;

GLOBAL_DATA;

integer getMPG(string attr, list character_rp) {
  integer i = llListFindStrided(character_rp, [attr], 0, -1, 2);
  if (i == -1) return -1;
  return (integer) character_rp[i + 1] - 1;
}

advance() {
  agent = (key)(string)agents[0];
  if (length > 1) {
    agents = llList2List(agents, 1, -1);
    --length;
  } else {
    length = 0;
    agents = [];
  }
}

// -------------------
default {
  state_entry() {
    mychan = (integer)("0x"+llGetSubString((string) llGetKey(), -4, -1)) + INC;
    handle = llListen(mychan, "ORAC", NULL_KEY, "");
    llListenControl(handle, FALSE);
  }
  link_message(integer from, integer chan, string msg, key xyzzy) {
#ifdef LOCATION
    if (chan != scanPlayerLocation) return;
#else
    if (chan != scanPlayer) return;
#endif
    GET_CONTROL_GLOBAL;
    llListenControl(handle, TRUE);
    player = xyzzy;
    string s;
    POP(s);
    agents = llParseString2List(s, ["+"], []);
    length = llGetListLength(agents);
    do { advance(); } while (agent == player && length > 0);
    if (agent == player) {
      llRegionSayTo(player, 0, "No one around.");
      NEXT_STATE;
      return;
    }
    llSetTimerEvent(1.5);
    llRegionSay(321,"502+999|" + (string) agent + "|" + (string)llGetKey() + "|" + (string) mychan);
  }

  listen(integer chan, string name, key xyzzy, string msg) {
    list params = llParseString2List(msg, ["|"], []);
    if (llGetKey() != (key)(string)params[0]) return;
    llSetTimerEvent(0);
    llRegionSayTo(player, 0, "-----");
    llRegionSayTo(player, 0, llGetDisplayName(agent));
#ifdef LOCATION
    list vals = llGetObjectDetails(agent, [OBJECT_POS]);
    vector v = (vector) vals[0];
    vals = llGetObjectDetails(player, [OBJECT_POS]);
    float d = llVecDist((vector) vals[0], v);
#endif
    if ((string)params[1] == "-1") {
#ifdef LOCATION
      llRegionSayTo(player, 0, "   Distance: " + (string) d + " meters.");
      llRegionSayTo(player, 0, "   Location: " + (string) v);
      llRegionSayTo(player, 0, "   Not a roleplayer.");
#else
      llRegionSayTo(player, 0, "   Not a roleplayer.");
#endif
    } else {
#ifdef LOCATION
      llRegionSayTo(player, 0, "   Distance: " + (string) d + " meters.");
      llRegionSayTo(player, 0, "   Location: " + (string) v);
#endif
      list strength = StrengthText;
      list combat = CombatText;
      list energy = EnergyText;
      list durability = DurabilityText;
      list intelligence = IntelligenceText;
      list alignment = AlignmentText;
      list speed = SpeedText;
      list rp = llJson2List((string) params[1]);
      integer index = llListFindStrided(rp, ["enabled"], 0, -1, 2);
      string value = (string) rp[index + 1];
      if (value != "true") {
	llRegionSayTo(player, 0, " Their powers are not enabled.");
      }
      llRegionSayTo(player, 0, "   Strength: "+(string) strength[getMPG("strength", rp)]);
      llRegionSayTo(player, 0, "   Intelligence: "+(string) intelligence[getMPG("intelligence", rp)]);
      llRegionSayTo(player, 0, "   Speed: "+(string) speed[getMPG("speed", rp)]);
      llRegionSayTo(player, 0, "   Combat: "+(string) combat[getMPG("combat", rp)]);
      llRegionSayTo(player, 0, "   Energy Projection: "+(string) energy[getMPG("power", rp)]);
      llRegionSayTo(player, 0, "   Durability: "+(string) durability[getMPG("durability", rp)]);
      llRegionSayTo(player, 0, "   Alignment: "+(string) alignment[getMPG("alignment", rp)]);
    }
    if (length > 0) {
      do { advance(); } while (agent == player && length > 0);
      if (agent == player) {
	xyzzy = player;
	llRegionSayTo(player, 0, "-----");
	llRegionSayTo(player, 0, "scan is done.");
	NEXT_STATE;
      }
      llSetTimerEvent(1.5);
      llRegionSay(321,"502+999|" + (string) agent + "|" + (string)llGetKey() + "|" + (string) mychan);
    } else {
      xyzzy = player;
      llRegionSayTo(player, 0, "-----");
      llRegionSayTo(player, 0, "scan is done.");
      NEXT_STATE;
    }
  }

  timer() {
    llSetTimerEvent(0);
    if (llGetAgentSize(agent) != ZERO_VECTOR) {
#ifdef LOCATION
      list vals = llGetObjectDetails(agent, [OBJECT_POS]);
      llRegionSayTo(player, 0, "-----");
      vector v = (vector) vals[0];
      vals = llGetObjectDetails(player, [OBJECT_POS]);
      float d = llVecDist((vector) vals[0], v);
      llRegionSayTo(player, 0, llGetDisplayName(agent) + " at a distance of " + (string) d + " meters ("+(string) v+")"+" is not responding.");
#else
      llRegionSayTo(player, 0, llGetDisplayName(agent) + " is not responding.");
#endif
    }    
    if (length > 0) {
      do { advance(); } while (agent == player && length > 0);
      if (agent == player) {
	key xyzzy = player;
	llRegionSayTo(player, 0, "-----");
	llRegionSayTo(player, 0, "scan is done.");
	NEXT_STATE;
	return;
      }
      llSetTimerEvent(1.5);
      llRegionSay(321,"502+999|" + (string) agent + "|" + (string)llGetKey() + "|" + (string) mychan);
    } else {
      key xyzzy = player;
      llRegionSayTo(player, 0, "-----");
      llRegionSayTo(player, 0, "scan is done.");
      NEXT_STATE;
    }
  }
}
    
