#ifndef debug
#define debug(x)
#endif

#define RESET 100
#define EXTEND 101
#define DESCEND 102
#define POWER_ON 103
#define POWER_OFF 104
#define UPDATE_DB 105

integer count;
key http_key;

default {
  state_entry() {
    if (llLinksetDataCountKeys() == 0) state update;
    llResetOtherScript("roleplayer");
    llSay(0, "Database loaded.");
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch (chan) {
    case UPDATE_DB: {
      state update;
      break;
    }
    default: break;
    }
  }
}

state update {
  state_entry() {
    llLinksetDataReset();
    count = 0;
    http_key = llHTTPRequest(SERVER + "RP/prototype/0", [], "");
    llSay(0, "Loading character database...");
  }

  http_response(key request_id, integer status, list metadata, string body) {
    if (request_id != http_key) return;
    if (status != 200) return;
    string name = llJsonGetValue(body, ["name"]);
    if (name == "" || name == JSON_NULL || name == JSON_INVALID) return;
    integer remaining = (integer) llJsonGetValue(body, ["remaining"]);
    string json = llJsonGetValue(body, ["json"]);
    llLinksetDataWrite(name,
		       llJsonGetValue(json,["strength"]) + "|" +
		       llJsonGetValue(json,["intelligence"]) + "|" +
		       llJsonGetValue(json,["speed"]) + "|" +
		       llJsonGetValue(json,["durability"]) + "|" +
		       llJsonGetValue(json,["power"]) + "|" +
		       llJsonGetValue(json,["combat"]) + "|" +
		       llJsonGetValue(json,["alignment"]) + "|" +
		       llJsonGetValue(json,["tier"]));
    if (remaining < 1) state default;
    ++count;
    llSleep(1); // throttle
    http_key = llHTTPRequest(SERVER + "RP/prototype/" + (string) count, [], "");
  }
}
