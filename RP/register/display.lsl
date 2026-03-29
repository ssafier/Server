#define RESET 100

default {
  state_entry() {
  }

  link_message(integer from, integer chan, string msg, key alpha) {
    if (chan == RESET) {
      llSetLinkPrimitiveParamsFast(LINK_THIS,
				   [PRIM_TEXTURE, ALL_SIDES, TEXTURE_BLANK, <1,1,0>, ZERO_VECTOR, 0,
				    PRIM_COLOR, ALL_SIDES, <0,0,0>,1.0]);
      return;
    }
  }
}
