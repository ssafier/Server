#ifndef debug
#define debug(x)
#endif

#define RESET 100
#define EXTEND 101

vector max_extend;
vector size;
vector tool_size;
vector current_pos;

default {
  state_entry() {
    list params = llGetLinkPrimitiveParams(LINK_THIS,[PRIM_DESC]);
    params = llParseString2List((string) params[0], ["+"], []);
    max_extend = (vector) (string) params[1];
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
      vector temp = max_extend;    
      temp.z -= (size.z + tool_size.z + 0.5);
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POS_LOCAL,  current_pos = temp]);
      break;
    }
    case EXTEND: {
      llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POS_LOCAL,  current_pos = max_extend]);
      break;
    }
    default: break;
    }
  }
}
