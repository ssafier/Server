#define RESET 100
#define POWER_OFF 104
#define DISPLAY 108

default {
  state_entry() {
  }

  link_message(integer from, integer chan, string msg, key alpha) {
    if (chan != DISPLAY && chan != RESET || chan != POWER_OFF) return;
      llSetLinkPrimitiveParamsFast(LINK_THIS,
				   [PRIM_TEXTURE, ALL_SIDES, TEXTURE_BLANK, <1,1,0>, ZERO_VECTOR, 0,
				    PRIM_COLOR, ALL_SIDES, <0,0,0>,1.0]);
    if (chan == RESET || chan == POWER_OFF) {
      return;
    }
    string texture = "";
    switch(msg) {
    case "The Hulk": {
      texture = "Hulk";
      break;
    }
    case "Abomination": {
      texture = "Abomination";
      break;
    }
    case "Hercules": {
      texture = "Hercules";
      break;
    }
    case "Superman": {
      texture = "Superman";
      break;
    }
    case "The Flash":
    case "Reverse-Flash": {
      texture = "Flash";
      break;
    }
    default: break;
    }
    if (texture == "") return;
    llSetLinkPrimitiveParamsFast(LINK_THIS,
				 [PRIM_TEXTURE, ALL_SIDES, texture, <1,1,0>, ZERO_VECTOR, 270 * DEG_TO_RAD,
				  PRIM_COLOR, ALL_SIDES, <1,1,1>,1.0]);
  }
}
