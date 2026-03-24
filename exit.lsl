#include "include/server.h"
// loop through departing 


#ifndef debug
#define debug(a, b)
#endif

key httpKey;
key felicia;

default {
  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan == regionExit) {
      string index = llLinksetDataRead((string) (felicia = xyzzy));
      if (index == "") {
	llMessageLinked(LINK_THIS, departAck, "", NULL_KEY);
	return;
      }
      string json = "{\"index\": "+ index + "}";
      httpKey = llHTTPRequest(SERVER+"region/leave",
			      [HTTP_MIMETYPE, "application/json",
			       HTTP_METHOD, "POST"],
			      json);

    }
  }

  http_response(key request_id, integer status, list metadata, string body) {
    if (request_id != httpKey) return;
    if (status == 200) {
      llLinksetDataDelete((string) felicia);
    }
    llMessageLinked(LINK_THIS, departAck, "", NULL_KEY);
  }
}
