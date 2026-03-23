#include "include/server.h"
// loop through departing 


#ifndef debug
#define debug(a, b)
#endif

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan == regionExit) {
      // Add something to do on exit here.
      llMessageLinked(LINK_THIS, departAck, "", NULL_KEY);
    }
  }
}
