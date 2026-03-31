#define RESET 100
#define POWER_OFF 104
#define BATTERY 113
float alpha;
float inc;
float max;
float update;

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan == RESET || chan == POWER_OFF) {
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1.0,
					       PRIM_GLOW, ALL_SIDES, alpha = 0]);
      llSetTimerEvent(0);
      return;
    }
    if (chan != BATTERY) return;
    string color = (string) xyzzy;
    switch(msg) {
    case "on": {
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, (vector) color, 1.0]);
      alpha = 0;
      max = 0.25;
      inc = update = 0.01;
      llSetTimerEvent(0.2);
      break;
    }
    case "up": {
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, (vector) color, 1.0]);
      alpha = 0.1;
      max = 0.5;
      inc = update = 0.1;
      llSetTimerEvent(0.1);
      break;
    }
    case "off": {
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1.0,
					       PRIM_GLOW, ALL_SIDES, alpha = 0]);
      llSetTimerEvent(0);
      break;
    }
    default: break;
    }
  }
  timer() {
    alpha += inc;
    if (inc > 0 && alpha >= max) inc = -update;
    if (inc < 0 && alpha <= 0.009) inc = update;
    if (alpha < 0) alpha = 0;
    if (alpha > max) alpha = max;
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, alpha]);
  }

}
