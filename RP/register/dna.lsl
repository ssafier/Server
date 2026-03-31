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
#define SPARK 112

vector max_extend;
vector size;
vector tool_size;
vector current_pos;
float inc;

string protohero;

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
    case POWER_OFF:
    case RESET: {
      llSetTimerEvent(0);
      msg = "";
    }
    case DESCEND: {
      if (msg != "" && msg != "dna") return;
      llSetText("", <1,1,1>, 0);
      llTargetOmega(llRot2Up(llGetLocalRot()), PI, 0);      
      if (current_pos.z == (max_extend.z - (size.z + tool_size.z + 0.5))) return;
      inc = -0.05;
      llSetTimerEvent(0.1);
      break;
    }
    case EXTEND: {
      protohero = msg;
      if (current_pos.z != max_extend.z) {
	inc = 0.05;
	llSetTimerEvent(0.1);
      }
      break;
    }
    case SPARK: {
      if (msg == "start") {
	llParticleSystem([
			  PSYS_PART_FLAGS,(0
					   | PSYS_PART_EMISSIVE_MASK 
					   | PSYS_PART_INTERP_COLOR_MASK 
					   | PSYS_PART_INTERP_SCALE_MASK 
					   | PSYS_PART_FOLLOW_VELOCITY_MASK 
					   ),
			  PSYS_PART_START_COLOR,<1.00000, 1.00000, 1.00000>,
			  PSYS_PART_END_COLOR,<1.00000, 1.00000, 1.00000>,
			  PSYS_PART_START_ALPHA,1.000000,
			  PSYS_PART_END_ALPHA,1.000000,
			  PSYS_PART_START_SCALE,<0.04000, 0.04000, 0.00000>,
			  PSYS_PART_END_SCALE,<0.17500, 0.17500, 0.00000>,
			  PSYS_PART_MAX_AGE,5.000000,
			  PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.10000>,
			  PSYS_SRC_PATTERN,2,
			  PSYS_SRC_TEXTURE,"e51dd951-0067-487f-f663-ae21871a71d0",
			  PSYS_SRC_BURST_RATE,0.100000,
			  PSYS_SRC_BURST_PART_COUNT,5,
			  PSYS_SRC_BURST_RADIUS,0.000000,
			  PSYS_SRC_BURST_SPEED_MIN,0.150000,
			  PSYS_SRC_BURST_SPEED_MAX,0.250000,
			  PSYS_SRC_MAX_AGE,0.000000,
			  PSYS_SRC_OMEGA,<0.00000, 0.00000, 0.00000>,
			  PSYS_SRC_ANGLE_BEGIN,0.030000*PI,
			  PSYS_SRC_ANGLE_END,0.000000*PI]);
      } else if (msg == "on") {
	llParticleSystem([
			  PSYS_PART_FLAGS,(0
					   | PSYS_PART_EMISSIVE_MASK 
					   | PSYS_PART_INTERP_COLOR_MASK 
					   | PSYS_PART_INTERP_SCALE_MASK 
					   | PSYS_PART_FOLLOW_SRC_MASK
					   | PSYS_PART_TARGET_LINEAR_MASK
					   | PSYS_PART_FOLLOW_VELOCITY_MASK
					   ),
			  PSYS_PART_START_COLOR,<1.00000, 1.00000, 1.00000>,
			  PSYS_PART_END_COLOR,<0.60000, 0.70000, 0.90000>,
			  PSYS_PART_START_ALPHA,1.000000,
			  PSYS_PART_END_ALPHA,0.000000,
			  PSYS_PART_START_SCALE,<0.70000, 4.00000, 0.00000>,
			  PSYS_PART_END_SCALE,<0.70000, 4.00000, 0.00000>,
			  PSYS_PART_MAX_AGE,0.400000,
			  PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.00000>,
			  PSYS_SRC_PATTERN,2,
			  PSYS_SRC_TEXTURE,"a41f533a-b0d3-ce00-1f4c-8f5f2c7ddfe6",
			  PSYS_SRC_BURST_RATE,0.200000,
			  PSYS_SRC_BURST_PART_COUNT,1,
			  PSYS_SRC_BURST_RADIUS,0.000000,
			  PSYS_SRC_BURST_SPEED_MIN,0.000000,
			  PSYS_SRC_BURST_SPEED_MAX,0.000000,
			  PSYS_SRC_MAX_AGE,0.000000,
			  PSYS_SRC_OMEGA,<0.00000, 0.00000, 0.00000>,
			  PSYS_SRC_ANGLE_BEGIN,0.000000*PI,
			  PSYS_SRC_ANGLE_END,0.000000*PI,
			  PSYS_SRC_TARGET_KEY, xyzzy
			  ]);
      } else {
	llParticleSystem([]);
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
      if (protohero != "") llSetText(protohero + "'s DNA", <1,0,0>, 1);
      llTargetOmega(llRot2Up(llGetLocalRot()), PI, 1.0);
      llSetTimerEvent(0);
    }
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_POS_LOCAL,  current_pos]);
  }
}
