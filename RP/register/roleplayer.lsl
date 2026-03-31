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
#define SAVE_SEQUENCE 110
#define SAVE_CHAR 111
#define SPARK 112
#define BATTERY 113

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

integer label1;
integer label2;
integer label3;
integer label4;

integer seat;
integer top;
integer bottom;

default {
  state_entry() {
    integer objectPrimCount = llGetObjectPrimCount(llGetKey());
    integer currentLinkNumber = 0;
    display1 = display2 = display3 = display4 =
      label1 = label2 = label3 = label4 = seat = -1;
    while(currentLinkNumber <= objectPrimCount) {
      debug(currentLinkNumber);
      list params = llGetLinkPrimitiveParams(currentLinkNumber,[PRIM_NAME, PRIM_DESC]);
      switch((string) params[0]) {
      case "seat": {
	seat = currentLinkNumber;
	break;
      }
      case "Cooling Top": {
	top = currentLinkNumber;
	break;
      }
      case "Cooling Bottom": {
	bottom = currentLinkNumber;
	break;
      }
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
	break;
      }
      case "label": {
	switch((string) params[1]) {
	case "1": {
	  label1 = currentLinkNumber;
	  break;
	}
	case "2": {
	  label2 = currentLinkNumber;
	  break;
	}
	case "3": {
	  label3 = currentLinkNumber;
	  break;
	}
	case "4": {
	  label4 = currentLinkNumber;
	  break;
	}
	default: break;
	}
	break;
      }
      default: break;
      }
      ++currentLinkNumber;
    }
    if (display1 == -1 || display2 == -1 || display3 == -1 || display4 == -1 ||
	label1 == -1 || label2 == -1 || label3 == -1 || label4 == -1)
      llSay(0,"Can't find prims.");

    heros = llDumpList2String(
			      llListSort(llLinksetDataListKeys(0, MAX_PROTOTYPES), 1, TRUE),
			      "+") + "+Cancel";
    state waiting;
  }
}

#define reset_label(x) llSetLinkPrimitiveParamsFast(x, [PRIM_TEXTURE, ALL_SIDES, TEXTURE_BLANK, <1,1,0>, ZERO_VECTOR, 0,  PRIM_NORMAL, ALL_SIDES, NULL_KEY, <1,1,0>, ZERO_VECTOR, 0, PRIM_SPECULAR, ALL_SIDES, NULL_KEY, <1,1,0>, ZERO_VECTOR, 0, <1,0.5,0>, 60, 15, PRIM_COLOR, ALL_SIDES, <0,0,0>,1.0])
#define set_label(l,t,c) llSetLinkPrimitiveParamsFast(l, [PRIM_TEXTURE, ALL_SIDES, t, <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD, PRIM_NORMAL, ALL_SIDES, t + "-norm", <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD, PRIM_SPECULAR, ALL_SIDES, t + "-spec", <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD, <1,0.5,0>, 60, 15, PRIM_COLOR, ALL_SIDES, c,1.0])

state waiting {
  state_entry() {
    reset_label(label1);
    reset_label(label2);
    reset_label(label3);
    reset_label(label4);
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != SETUP) return;
    GET_CONTROL;
    string character;
    POP(character);
    string answer;
    POP(answer);
    llMessageLinked(display1, DISPLAY, character, xyzzy);
    llMessageLinked(display2, DISPLAY,"", xyzzy);
    llMessageLinked(top, BATTERY, "on", (key) "<1,0.6,0>");
    llMessageLinked(bottom, BATTERY, "on", (key) "<0,1,1>");
    switch (answer) {
    case "[time out]": {
      llSay(0, "Time out.   Powering down.");
      llMessageLinked(LINK_THIS, RESET, "", NULL_KEY);
      break;
    }
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
    if (chan == CONTROL_S_L) {
      llMessageLinked(LINK_THIS,
		      MENU,
		      (string) SETUP + "|Choose hero|" + heros,
		      player);
      return;
    }
    if (chan != SETUP) return;
    GET_CONTROL;
    string answer;
    POP(answer);
    switch (answer) {
    case "[time out]": {
      llSay(0, "Menu has timed out.");
      vector c = <0,1,1>;
      set_label(label3, "menu", c);
      break;
    }
    case "Cancel": {
      state waiting;
      break;
    }
    default: {
      string data = llLinksetDataRead(answer);
      if (data == "") state waiting;
      mpg = llParseString2List(data,["|"],[]);
      protohero = answer;
      llMessageLinked(display3, DISPLAY, protohero, player);
      llMessageLinked(display4, DISPLAY,
		      "strength+"+(string)mpg[0]+"+intelligence+"+(string)mpg[1]+
		      "+speed+"+(string)mpg[2]+"+durability+"+(string)mpg[3]+
		      "+power+"+(string)mpg[4]+"+combat+"+(string)mpg[5]+
		      "+alignment+"+(string)mpg[6]+"+tier+"+(string)mpg[7],
		      player);
      state check_hero;
    }
    }
  }
}

state check_hero {
  state_entry() {
    vector c = <0,1,0>;
    set_label(label2, "accept", c);
    c = <1,0,0>;
    set_label(label1, "reject", c);
    reset_label(label3);
    reset_label(label4);
    llMessageLinked(LINK_SET, EXTEND, protohero, NULL_KEY);
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
	llMessageLinked(display3, RESET, "", NULL_KEY);
	llMessageLinked(display4, RESET, "", NULL_KEY);
	state mpg_hero;
	break;
      }
      case CONTROL_B_L:
      case CONTROL_S_L: {
	llMessageLinked(top, BATTERY, "up", (key) "<1,0.6,0>");
	llMessageLinked(bottom, BATTERY, "up", (key) "<0,1,1>");
	llMessageLinked(seat, SAVE_SEQUENCE, "", player);
	break;
      }
      default: break;
      }
    }
  }
}

