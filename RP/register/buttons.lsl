#ifndef debug
#define debug(x)
#endif

#define CONSOLE_1 1
#define CONSOLE_2 2
#define CONSOLE_3 3
#define CONSOLE_4 4
#define CONTROL_B_R 5
#define CONTROL_B_L 6
#define CONTROL_S_R 7
#define CONTROL_S_L 8

#define RESET 100
#define POWER_ON 103
#define POWER_OFF 104

float alpha;
float inc;
string running;

default {
  state_entry() {
    llSetClickAction(CLICK_ACTION_TOUCH);
    running = "0";
  }
  touch_start(integer x) {
    debug((string) llDetectedTouchFace(0) + " " + (string) (llGetRootPosition() - llDetectedTouchPos(0)));
    vector pos = llGetRootPosition() - llDetectedTouchPos(0);
    switch (llDetectedTouchFace(0)) {
    case 0: { // small buttons
      if (pos.x < 0) {
	// right button
	llMessageLinked(LINK_ROOT, CONTROL_S_R, running, llDetectedKey(0));
      } else {
	// left button
	llMessageLinked(LINK_ROOT, CONTROL_S_L, running, llDetectedKey(0));
      }
      break;
    }
    case 1: { // big buttons
      if (pos.x < 0) {
	// right button
	llMessageLinked(LINK_ROOT, CONTROL_B_R, running, llDetectedKey(0));
      } else {
	// left button
	llMessageLinked(LINK_ROOT, CONTROL_B_L, running, llDetectedKey(0));
      }
      break;
    }
    case 2: { // front panel
      if (pos.x < 0) {
	// right button
	if (pos.x > 1.08) {
	  llMessageLinked(LINK_ROOT, CONSOLE_4, running, llDetectedKey(0));
	} else {
	  llMessageLinked(LINK_ROOT, CONSOLE_3, running, llDetectedKey(0));
	}
      } else {
	// left button
	if (pos.x > 1.08) {
	  llMessageLinked(LINK_ROOT, CONSOLE_1, running, llDetectedKey(0));
	} else {
	  llMessageLinked(LINK_ROOT, CONSOLE_2, running, llDetectedKey(0));
	}
      }
      break;
    }
    default: break;
    }
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case RESET: {
      llSetTimerEvent(0);
      running = "0";
      llSetLinkColor(LINK_THIS, <1,1,1>, ALL_SIDES);
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, alpha = 0]);
      break;
    }
    case POWER_OFF: {
      running = "0";
      llSetLinkColor(LINK_THIS, <1,0,0>, ALL_SIDES);
      alpha = 0.0;
      inc = 0.1;
      llSetTimerEvent(0.1);
      break;
    }
    case POWER_ON: {
      running = "1";
      alpha = 0;
      inc = 0.1;
      llSetLinkColor(LINK_THIS, <0,1,0>, ALL_SIDES);
      llSetTimerEvent(0);
      break;
    }
    default: break;
  }
  }

  timer() {
    alpha += inc;
    if (inc > 0 && alpha >= 0.49) inc = -0.1;
    if (inc < 0 && alpha <= 0.09) inc = 0.1;
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, alpha]);
  }
}
