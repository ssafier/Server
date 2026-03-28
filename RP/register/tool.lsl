#ifndef debug
#define debug(x)
#endif

#define RESET 100
#define EXTEND 101
#define DESCEND 102
#define POWER_ON 103

vector max_extend;
vector size;
vector current_pos;
float inc;

default {
  state_entry() {
    list params = llGetLinkPrimitiveParams(LINK_THIS,[PRIM_DESC]);
    params = llParseString2List((string) params[0], ["+"], []);
    max_extend = (vector) (string) params[1];
    size = (vector)(string) params[3];
    current_pos = max_extend;
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POS_LOCAL,  current_pos]);
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch (chan) {
    case RESET: {
      llSetTimerEvent(0);
    }
    case DESCEND: {
      llTargetOmega(llRot2Up(llGetLocalRot()), PI, 0);
      if (current_pos.z == (max_extend.z - size.z)) return;
      inc = -0.05;
      llSetTimerEvent(0.1);
      break;
    }
    case POWER_ON:
    case EXTEND: {
      if (current_pos.z != max_extend.z) {
	inc = 0.05;
	llSetTimerEvent(0.1);
      }
      break;
    }
    default: break;
    }
  }
  timer() {
    current_pos.z += inc;
    if (inc < 0 && current_pos.z < (max_extend.z - size.z)) {
      current_pos.z = (max_extend.z - size.z);
      llSetTimerEvent(0);
    } else if (inc > 0 && current_pos.z >= max_extend.z) {
      current_pos.z = max_extend.z;
      llTargetOmega(llRot2Up(llGetLocalRot()), PI, 1.0);
      llSetTimerEvent(0);
    }
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POS_LOCAL,  current_pos]);
  }
}
