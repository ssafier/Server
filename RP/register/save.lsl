// Uses an experience.  Steps through multiple animation states
#ifndef debug
#define debug(x)
#endif

#define RESET 100
#define SAVE_SEQUENCE 110
#define SAVE_CHAR 111
#define SPARK 112

#define SIT_TIME 4 // 3.21 + .8
#define ELECTROCUTE 10.1 // 10.12 + .82
#define EXPLODE_1 2
#define EXPLODE_2 1.4 // 3.48 // 3.48 + .82
#define RECOVER 5.5 // 4.88 + .82

#define explodeSTARTColor <0.00000, 1.00000, 1.00000>
#define explodeENDColor <1.00000, 0.00000, 0.00000>

key player;

vector target = <0,0,1>;
rotation target_rot = ZERO_ROTATION;
vector local;
// precompute parameters to update sit position
integer link_num;
float fAdjust;

// -----------------------------------------------
updateSitTarget(vector pos, rotation rot) {
  llLinkSitTarget(LINK_THIS, pos, rot);
  llSetLinkPrimitiveParamsFast(link_num,
			       [PRIM_POS_LOCAL, (pos + <0.0, 0.0, 0.4> - (llRot2Up(rot) * fAdjust)) ,
				PRIM_ROT_LOCAL, rot]);
}

// -----------------------------------------------
checkUpdateSitTarget(vector t, rotation r) {
  if (t != target || r != target_rot) updateSitTarget(target = t, target_rot = r);
}

default {
  state_entry() {
    llSetLinkPrimitiveParamsFast(LINK_THIS,
				 [PRIM_SIT_FLAGS,
				  // SIT_FLAG_ALLOW_UNSIT |
				  SIT_FLAG_SCRIPTED_ONLY]);
    list l = llGetLinkPrimitiveParams(LINK_THIS, [PRIM_POS_LOCAL]);
    target = (local = (vector) l[0]) + <0,0,1.25>;
    llSitTarget(target,target_rot = ZERO_ROTATION);
  }
  
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != SAVE_SEQUENCE) return;
    llRequestExperiencePermissions(xyzzy, "");
  }
  experience_permissions(key avi) {
    integer sitTest = llSitOnLink(avi, LINK_THIS);
    if (sitTest != 1)  return;
    vector size = llGetAgentSize(avi);
    fAdjust = ((((0.008906 * size.z) + -0.049831) * size.z) + 0.088967) * size.z;
    integer linkNum = llGetNumberOfPrims();
    link_num = -1;
    while(linkNum && link_num == -1) {
      if (avi == llGetLinkKey(linkNum))
	link_num = linkNum;
      else
	--linkNum;
    }
    llSetLinkPrimitiveParamsFast(link_num,
				 [PRIM_POS_LOCAL, (target + <0.0, 0.0, 0.4> - (llRot2Up(target_rot) * fAdjust))]);
    llMessageLinked(LINK_ALL_OTHERS, SPARK, "start", player);
    player = avi;
    list anims = llGetAnimationList(avi);
    integer len = llGetListLength(anims);
    while(len) {
      --len;
      llStopAnimation((key) anims[len]);
    }
    llStartAnimation("one");
    llSetTimerEvent(SIT_TIME);
  }
  experience_permissions_denied(key avi, integer reason) {
    llSay(0, "You must be in the EVOLUTION experience to access this roleplay system.");
    llMessageLinked(LINK_SET, RESET, "", NULL_KEY);
  }
  timer() {
    llSetTimerEvent(0);
    state transfer_dna;
  }
}

state transfer_dna {
  state_entry() {
    llMessageLinked(LINK_ALL_OTHERS, SPARK, "on", player);
    llRequestExperiencePermissions(player, "");
  }
  experience_permissions(key avi) {
    llStopAnimation("one");
    llStartAnimation("two");
    llSetTimerEvent(ELECTROCUTE);
  }
  timer() {
    llSetTimerEvent(0);
    llMessageLinked(LINK_ALL_OTHERS, SPARK, "off", player);
    state explode;
  }
}

state explode {
  state_entry() {
    llMessageLinked(LINK_ROOT, SAVE_CHAR, "", player);
    checkUpdateSitTarget(local + <0,0,0.25>,ZERO_ROTATION);
    llParticleSystem([
		      PSYS_PART_FLAGS,(0
				       | PSYS_PART_EMISSIVE_MASK 
				       | PSYS_PART_INTERP_COLOR_MASK 
				       | PSYS_PART_INTERP_SCALE_MASK 
				       | PSYS_PART_FOLLOW_SRC_MASK 
				       | PSYS_PART_FOLLOW_VELOCITY_MASK 
				       | PSYS_PART_TARGET_POS_MASK 
				       ),
		      PSYS_SRC_TARGET_KEY, player,
		      PSYS_PART_START_COLOR,explodeSTARTColor,
		      PSYS_PART_END_COLOR,explodeENDColor,
		      PSYS_PART_START_ALPHA,0.150000,
		      PSYS_PART_END_ALPHA,0.000000,
		      PSYS_PART_START_SCALE,<1.00000, 1.50000, 0.00000>,
		      PSYS_PART_END_SCALE,<3.00000, 3.00000, 0.00000>,
		      PSYS_PART_MAX_AGE,4.000000,
		      PSYS_SRC_ACCEL,<0.00000, 0.00000, 0.00000>,
		      PSYS_SRC_PATTERN,2,
		      PSYS_SRC_TEXTURE,"fb6cbc26-d46a-1ae6-6127-f322ed6ebca6",
		      PSYS_SRC_BURST_RATE,0.250000,
		      PSYS_SRC_BURST_PART_COUNT,40,
		      PSYS_SRC_BURST_RADIUS,0.720000,
		      PSYS_SRC_BURST_SPEED_MIN,1.500000,
		      PSYS_SRC_BURST_SPEED_MAX,3.000000,
		      PSYS_SRC_MAX_AGE,0.000000,
		      PSYS_SRC_OMEGA,<1.95000, 1.95000, 1.95000>,
		      PSYS_SRC_ANGLE_BEGIN,0.471239*PI,
		      PSYS_SRC_ANGLE_END,1.099557*PI]);
    llRequestExperiencePermissions(player, "");
  }

  experience_permissions(key avi) {
    llStopAnimation("two");
    llStartAnimation("three");
    llSetTimerEvent(EXPLODE_1);
  }
  
  timer() {
    llSetTimerEvent(0);
    llParticleSystem([]);
    state explode2;
  }
}

state explode2 {
  state_entry() { llSetTimerEvent(EXPLODE_2); }
  
  timer() {
    llSetTimerEvent(0);
    state accept_power;
  }
}

state accept_power {
  state_entry() {
    checkUpdateSitTarget(local + <0,0,1.25>,ZERO_ROTATION);
    llRequestExperiencePermissions(player, "");
  }
  experience_permissions(key avi) {
    llStopAnimation("three");
    llStartAnimation("four");
    llSetTimerEvent(RECOVER);
  }
  timer() {
    llSetTimerEvent(0);
    llUnSit(player);
    state default;
  }
}


