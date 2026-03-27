#include "include/controlstack.h"
#include "include/computo.h"

// Where am I?

#ifndef debug
#define debug(x)
#endif

float scale(float h) {
  if (h < 1) return SMALLER;
  if (h < 2) return SMALL;
  if (h < 3) return MEDIUM;
  return BIG;
}

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != Position) return;
    GET_CONTROL;
    string temp;
    POP(temp);
    vector a = (vector) temp;
    list l = llGetObjectDetails(xyzzy, [OBJECT_POS]);
    if (l == []) llDie(); // not in region
    vector pos = (vector) l[0] + <0, 0, a.z * 1.125 * scale(a.z)>;
    debug(pos);
    PUSH((string) pos);
    PUSH((string) xyzzy);
    NEXT_STATE;
  }
}
