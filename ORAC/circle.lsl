#include "include/controlstack.h"
#include "include/computo.h"

#ifndef debug
#define debug(x)
#endif

vector origin;

integer RUNNING = 0;

vector axis;
rotation r;
key agent;
integer position;

default {
  state_entry() {
    r = llEuler2Rot(<0,0,zIncrement> * DEG_TO_RAD) *
      llEuler2Rot(<xIncrement,0,0>*DEG_TO_RAD);
    axis = AXIS;
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != Circle) return;
    GET_CONTROL;
    string popped;
      
    POP(popped);
    agent = (key) popped;
    POP(popped);
    origin = (vector) popped;

    if (agent == NULL_KEY) llDie();
    float dist = llFrand(5.0) + 2.5;
    rotation r2 = llEuler2Rot(llRot2Euler(r) * dist);
    axis = axis * r2;
    list l = llGetObjectDetails(agent, [OBJECT_POS]);

    if (l == []) llDie();

    vector myPos = (vector) l[0];
    if (llVecDist(myPos, llGetPos()) > 10) {
      myPos += <xIncrement, 0, zIncrement>;
      llMessageLinked(LINK_THIS, warp,  s_Position + "+" + s_Circle + "|" +
		      (string)  myPos + "|" + (string) agent, agent);
      return;
    }
    debug(axis * radius + (origin + JERK));
    llSetLinkPrimitiveParamsFast(LINK_SET,
				 [PRIM_POSITION,  axis * radius + (origin + JERK)]);
    llRotLookAt( 
		llRotBetween( <0.0, 0.0, -1.0>,
			      llVecNorm(myPos - llGetPos() ) ), 
		1.0, 0.4 );
    
    llSetTimerEvent(cTimer);      
    NEXT_STATE;
  }
  
  timer() {
    vector a = llGetAgentSize(agent);
    if (a == ZERO_VECTOR) llDie(); // die if not in region
    llMessageLinked(LINK_THIS, Position, s_Circle + "|" + (string) a + "|" + (string) agent, agent);
  }
} 
