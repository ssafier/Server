#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != lightning) return;
    GET_CONTROL;
    string target;
    POP(target);
    debug("lightning");
    llParticleSystem([
		      PSYS_PART_FLAGS,( 0 
					|PSYS_PART_INTERP_COLOR_MASK
					|PSYS_PART_INTERP_SCALE_MASK
					|PSYS_PART_FOLLOW_SRC_MASK
					|PSYS_PART_FOLLOW_VELOCITY_MASK
					|PSYS_PART_EMISSIVE_MASK ), 
		      PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE ,
		      PSYS_PART_START_ALPHA,1,
		      PSYS_PART_END_ALPHA,0,
		      PSYS_PART_START_COLOR,<1,1,1> ,
		      PSYS_PART_END_COLOR,<1,1,1> ,
		      PSYS_PART_START_SCALE,<9,9,0>,
		      PSYS_PART_END_SCALE,<9,9,0>,
		      PSYS_PART_MAX_AGE,0.398438,
		      PSYS_SRC_MAX_AGE,0,
		      PSYS_SRC_ACCEL,<0,0,0>,
		      PSYS_SRC_BURST_PART_COUNT,1,
		      PSYS_SRC_BURST_RADIUS,0,
		      PSYS_SRC_BURST_RATE,0.1,
		      PSYS_SRC_BURST_SPEED_MIN,0.0078125,
		      PSYS_SRC_BURST_SPEED_MAX,0,
		      PSYS_SRC_ANGLE_BEGIN,3.125,
		      PSYS_SRC_ANGLE_END,0,
		      PSYS_SRC_OMEGA,<0,0,0>,
		      PSYS_SRC_TEXTURE, (key)"c8344005-8062-cd94-0f3d-cba9a02e0e13",
		      PSYS_SRC_TARGET_KEY, (key) target
		      ]);
    llTriggerSound("Lightning_Bolt-Strike", 1.0);
    llSetTimerEvent(3);
  }
  timer() {
    llSetTimerEvent(0);
    llParticleSystem([]);
  }
}

