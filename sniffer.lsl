#include "include/server.h"

#define makeKey(base)  llSHA1String((string) (base))

#ifndef debug
#define debug(x)
#endif

integer serverHandle;
key httpKey;

string enigma(string in) {
  string a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  string b = DECODE;
  integer i = llSubStringIndex(in, " Resident");
  if (i != -1) in = llGetSubString(in, 0, i);
  i = llStringLength(in);
  integer j = 0;
  string out = "";
  for (j = 0; j < i; ++j) {
    integer k = llSubStringIndex(a, llGetSubString(in, j, j));
    if (k != -1) {
      out = out + llGetSubString(b, k, k);
    }
  }
  return out;
}

default {
  on_rez(integer foo) { llResetScript();  }
  link_message(integer from, integer num, string msg, key akey) {
    if (num == runCheck && msg == "RUNNING") state run;
  }
}

state run {
  state_entry() {
    serverHandle = llListen(serverSniffer, "", NULL_KEY, "");
  }

  listen(integer channel, string name, key xyzzy, string msg) {
    switch (channel) {
    case serverSniffer: {
      integer i = llSubStringIndex(msg, "|");
      if (i == -1) return;
      string uuid = llGetSubString(msg, 0, i-1);
      msg = llGetSubString(msg, i+1, -1);
      if ((key) uuid == NULL_KEY) return;
      if (msg == "0+0+0") return;
      debug("Parameters: "+msg);
      list lssl = llParseString2List(msg,["+"],[]);
      string name = llKey2Name((key) uuid);
      i = llSubStringIndex(name, "+Resident");
      string n = name;
      if (i != -1) n = llGetSubString(name, 0, i);
      
      string httprequest =  SERVER+ "evolve/update/"+
	llEscapeURL(uuid) + "/" +
	enigma(name) + "?" +
	"lvl=" + (string) lssl[2] + "&str=" + (string) lssl[0] + "&name=" + n + "&visit="+ (string) llGetUnixTime();
      debug(httprequest);
      httpKey = llHTTPRequest(httprequest, [], "");
      break;
    }
    default: break;
    }
  }

  http_response(key request_id, integer status, list metadata, string body) {
    if (request_id != httpKey) return;
    if (status == 200) {
      debug("updated");
    }
  }
 
  state_exit() {
    llListenRemove(serverHandle);
    llResetScript();
  }
}
