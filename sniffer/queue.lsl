// Queue events that take time to process
#ifndef debug
#define debug(x)
#endif

#define PUSH 100
#define UPDATE 101

list Q;
integer count = 0;

#define find(x) llListFindStrided(Q, [x], 0, -1, 2)

default {
  state_entry() {
    Q = [];
    count = 0;
    llSetTimerEvent(60);
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != PUSH) return;
    if (find(xyzzy) != -1) {
      debug("found "+(string) xyzzy);
      return; // keep original but can replace it
    }
    debug("added");
    Q = Q + [xyzzy, msg];
    count += 2;
  }

  timer() {
    debug("timer " + (string) count);
    if (Q == []) return;
    key avi = (key) Q[0];
    string msg = (string) Q[1];
    Q = llList2List(Q, 2, -1);
    if ((count = count - 2) == 0) Q = [];
    debug(msg + " " + (string) avi);
    llMessageLinked(LINK_THIS, UPDATE, msg, avi);
  }
}
