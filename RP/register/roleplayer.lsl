#include "include/controlstack.h"
#include "include/mpg.h"

#ifndef debug
#define debug(x)
#endif

#define MAX_PROTOTYPES 50

#define RESET 100
#define EXTEND 101
#define DESCEND 102
#define POWER_ON 103
#define POWER_OFF 104
#define UPDATE_DB 105
#define SETUP 106
#define MENU 107
#define DISPLAY 108

#define CONSOLE_1 1
#define CONSOLE_2 2
#define CONSOLE_3 3
#define CONSOLE_4 4
#define CONTROL_B_R 5
#define CONTROL_B_L 6
#define CONTROL_S_R 7
#define CONTROL_S_L 8

string heros;
key player;
string protohero;
list mpg;

integer display1;
integer display2;
integer display3;
integer display4;

default {
  state_entry() {
    integer objectPrimCount = llGetObjectPrimCount(llGetKey());
    integer currentLinkNumber = 0;
    while(currentLinkNumber <= objectPrimCount) {
      debug(currentLinkNumber);
      list params = llGetLinkPrimitiveParams(currentLinkNumber,[PRIM_NAME, PRIM_DESC]);
      switch((string) params[0]) {
      case "display": {
	switch((string) params[1]) {
	case "1": {
	  display1 = currentLinkNumber;
	  break;
	}
	case "2": {
	  display2 = currentLinkNumber;
	  break;
	}
	case "3": {
	  display3 = currentLinkNumber;
	  break;
	}
	case "4": {
	  display4 = currentLinkNumber;
	  break;
	}
	default: break;
	}
      }
      default: break;
      }
      ++currentLinkNumber;
    }
    heros = llDumpList2String(
			      llListSort(llLinksetDataListKeys(0, MAX_PROTOTYPES), 1, TRUE),
			      "+") + "+Cancel";
    state waiting;
  }
}

state waiting {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != SETUP) return;
    GET_CONTROL;
    string answer;
    POP(answer);
    llSay(0, (string) display2 + " " + (string) xyzzy);
    llMessageLinked(display2, DISPLAY,"", xyzzy);
    switch (answer) {
    case "Custom": {
      llSay(0, "Not supported yet.");
      break;
    }
    case "MPG Hero": {
      player = xyzzy;
      state mpg_hero;
    }
    default: break;
    }
  }
}

state mpg_hero {
  state_entry() {
    llSay(0,"DNA Resequencing...  Analyzing "+llGetDisplayName(player) +"'s DNA");
    llMessageLinked(LINK_THIS,
		    MENU,
		    (string) SETUP + "|Choose hero|" + heros,
		    player);
  }

  link_message(integer from, integer chan, string msg, key xyzyy) {
    if (chan == RESET) state waiting;
    if (chan != SETUP) return;
    GET_CONTROL;
    string answer;
    POP(answer);
    switch (answer) {
    case "[time out]":
    case "Cancel": {
      state waiting;
      break;
    }
    default: {
      string data = llLinksetDataRead(answer);
      if (data == "") state waiting;
      mpg = llParseString2List(data,["|"],[]);
      protohero = answer;
      state check_hero;
    }
    }
  }
}

state check_hero {
  state_entry() {
    llMessageLinked(LINK_SET, EXTEND, "", NULL_KEY);
    llSay(0,"DNA Resequencing...  Preparing "+protohero);
    list strength = StrengthText;
    list combat = CombatText;
    list speed = SpeedText;
    list energy = EnergyText;
    list durability = DurabilityText;
    list intelligence = IntelligenceText;
    list alignment = AlignmentText;

    llRegionSayTo(player, 0, protohero + " characteristics:");
    llRegionSayTo(player, 0, "Strength: "+(string) strength[(integer)(string)mpg[0 ] - 1]);
    llRegionSayTo(player, 0, "Intelligence: "+(string) intelligence[(integer)(string)mpg[1 ] - 1]);
    llRegionSayTo(player, 0, "Speed: "+(string) speed[(integer)(string)mpg[2 ] - 1]);      
    llRegionSayTo(player, 0, "Combat: "+(string) combat[(integer)(string)mpg[5 ] - 1]);
    llRegionSayTo(player, 0, "Energy Projection: "+(string) energy[(integer)(string)mpg[4 ] - 1]);
    llRegionSayTo(player, 0, "Durability: "+(string) durability[(integer)(string)mpg[3 ] - 1]);
    llRegionSayTo(player, 0, "Alignment: "+(string) alignment[(integer)(string)mpg[6 ] - 1]);
  }

  link_message(integer from, integer chan, string msg, key xyzyy) {
    if (chan == RESET) state waiting;
    if (chan < 9) {
      if (msg == "0") state waiting;
      switch(chan) {
      case CONTROL_B_R:
      case CONTROL_S_R: {
	llMessageLinked(LINK_SET, DESCEND, "dna", NULL_KEY);
	llSay(0, "Resetting DNA specification...");
	state mpg_hero;
	break;
      }
      case CONTROL_B_L:
      case CONTROL_S_L: {
	llSay(0, "save");
	break;
      }
      default: break;
      }
    }
  }
}

