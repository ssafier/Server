#define RESET 100
#define DISPLAY 108

#ifndef StrCut
#define StrCut 2
#endif
#ifndef CombatCut
#define CombatCut 2
#endif
#ifndef IntCut
#define IntCut 2
#endif
#ifndef PowCut
#define PowCut 2
#endif
#ifndef SpeedCut
#define SpeedCut 2
#endif
#ifndef DurCut
#define DurCut 2
#endif

list displays;
integer index = 0;

default {
  link_message(integer from, integer chan, string msg, key alpha) {
    if (chan == RESET) {
      llSetTimerEvent(0);
      llSetLinkPrimitiveParamsFast(LINK_THIS,
				   [PRIM_TEXTURE, ALL_SIDES, TEXTURE_BLANK, <1,1,0>, ZERO_VECTOR, 0,
				    PRIM_COLOR, ALL_SIDES, <0,0,0>,1.0]);
      return;
    }
    if (chan != DISPLAY) return;

    list specs = llParseString2List(msg,["+"],[]);
    integer l = llGetListLength(specs);
    integer i;
    displays = [];
    for(i = 0; i < l; i += 2) {
      switch((string) specs[i]) {
      case "strength": {
	if ((integer)(string)specs[i+1] > StrCut) displays += ["strength-screen"];
	break;
      }
      case "speed": {
	if ((integer)(string)specs[i+1] > SpeedCut) displays += ["speed-screen"];
	break;
      }
      case "intelligence": {
	if ((integer)(string)specs[i+1] > IntCut) displays += ["intelligence-screen"];
	break;
      }
      case "durability": {
	if ((integer)(string)specs[i+1] > DurCut) displays += ["durability-screen"];
	break;
      }
      case "combat": {
	if ((integer)(string)specs[i+1] > CombatCut) displays += ["combat-screen"];
	break;
      }
      case "power": {
	if ((integer)(string)specs[i+1] > PowCut) displays += ["power-screen"];
	break;
      }	
      default: break;
      }
    }
    if (displays == []) {
      llSetLinkPrimitiveParamsFast(LINK_THIS,
				   [PRIM_TEXTURE, ALL_SIDES, "human-screen", <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD,
				    PRIM_COLOR, ALL_SIDES, <1,1,1>,1.0]);
    } else {
      llSetLinkPrimitiveParamsFast(LINK_THIS,
				   [PRIM_TEXTURE, ALL_SIDES, (string) displays[0], <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD,
				    PRIM_COLOR, ALL_SIDES, <1,1,1>,1.0]);
      if (llGetListLength(displays) > 1) {
	index = 1;
	llSetTimerEvent(3);
      }
    }
  }

  timer() {
    llSetLinkPrimitiveParamsFast(LINK_THIS,
				 [PRIM_TEXTURE, ALL_SIDES, (string) displays[index], <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD,
				  PRIM_COLOR, ALL_SIDES, <1,1,1>,1.0]);
    ++index;
    if (index >= llGetListLength(displays)) index = 0;
  }
}
