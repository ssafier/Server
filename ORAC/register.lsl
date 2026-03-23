#include "controlstack.h"
#include "evolve/game.h"
#include "evolve/computo.h"

#ifndef debug
#define debug(x)
#endif

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan < 200 || chan > 299) return;
    GET_CONTROL;
    switch (chan) {
    case REGISTER: {
      llMessageLinked(LINK_THIS, doMenu,s_REGISTERtest + "|Confirm registration|Yes+No", xyzzy);
     break;
    }
    case REGISTERtest: {
      string message;
      POP(message);
      debug("test "+message);
      if (message != "Yes") return;
      integer clan = HUMAN;
      message = "http://scott-safier.com/evolution/update/" +
	(string) xyzzy +
	"?base_clan=" + (string) clan +
	"&name=" + llEscapeURL(llGetDisplayName(xyzzy));
      message = message + "&clan=Human";
      llHTTPRequest(message, [], "");
      llSleep(1);
      UPDATE_NEXT(giveHERO);
      break;
    }
    default: break;
    }
    NEXT_STATE;
  }
}
