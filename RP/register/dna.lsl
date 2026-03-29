#ifndef debug
#define debug(x)
#endif

#define RESET 100
#define EXTEND 101
#define DESCEND 102
#define POWER_ON 103
#define POWER_OFF 104
#define UPDATE_DB 105
#define SETUP 106
#define MENU 107

vector max_extend;
vector size;
vector tool_size;
vector current_pos;
float inc;

default {
  state_entry() {
    list params = llGetLinkPrimitiveParams(LINK_THIS,[PRIM_DESC]);
    params = llParseString2List((string) params[0], ["+"], []);
    current_pos = max_extend = (vector) (string) params[1];
    size = (vector)(string) params[3];
        integer objectPrimCount = llGetObjectPrimCount(llGetKey());
    integer currentLinkNumber = 0;
    integer tool = -1;
    while(tool == -1 && currentLinkNumber <= objectPrimCount) {
      list params = llGetLinkPrimitiveParams(currentLinkNumber,[PRIM_NAME]);
      switch((string) params[0]) {
      case "DNA Tool": {
	tool = currentLinkNumber;
	break;
      }
      default: break;
      }
      ++currentLinkNumber;
    }
    params = llGetLinkPrimitiveParams(tool,[PRIM_DESC]);
    params = llParseString2List((string) params[0], ["+"], []);
    tool_size = (vector) (string) params[4];
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch (chan) {
    case RESET: {
      llSetTimerEvent(0);
      msg = "";
    }
    case DESCEND: {
      if (msg != "" && msg != "dna") return;
      llTargetOmega(llRot2Up(llGetLocalRot()), PI, 0);      
      if (current_pos.z == (max_extend.z - (size.z + tool_size.z + 0.5))) return;
      inc = -0.05;
      llSetTimerEvent(0.1);
      break;
    }
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
    if (inc < 0 && current_pos.z < (max_extend.z - (size.z + tool_size.z + 0.5))) {
      current_pos.z = (max_extend.z - (size.z + tool_size.z + 0.5));
      llSetTimerEvent(0);
    } else if (inc > 0 && current_pos.z >= max_extend.z) {
      current_pos.z = max_extend.z;
      llTargetOmega(llRot2Up(llGetLocalRot()), PI, 1.0);
      llSetTimerEvent(0);
    }
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POS_LOCAL,  current_pos]);
  }
}
