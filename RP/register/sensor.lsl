#ifndef debug
#define debug(x)
#endif


#define RESET 100
#define POWER_ON 103
#define POWER_OFF 104

#define DISTANCE 5

integer in_range = FALSE;

default {
  state_entry() {
    llSensorRepeat("", NULL_KEY, AGENT, DISTANCE, PI, 5);
    in_range = FALSE;
  }
  sensor(integer num) {
    if (in_range) return;
    in_range = TRUE;
    llMessageLinked(LINK_SET, POWER_OFF, "", NULL_KEY);
  }
  no_sensor() {
    if (in_range == FALSE) return;
    in_range = FALSE;
    llMessageLinked(LINK_SET, RESET, "", NULL_KEY);
  }
}
