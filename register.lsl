#include "evolve/server.h"

integer WELCOMEcard = 0;

key httpKey;
key newbie = NULL_KEY;

integer lnum;
key notekey;
list announcement;

#define debug(x)

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

///////////////////////////////
 default {
   on_rez(integer foo) { llResetScript();  }

   state_entry() {
     lnum = 0;
     announcement = [];
     notekey = llGetNotecardLine("Announcement", lnum);
   }

   dataserver(key id, string data) {
     if (id != notekey) return;
     if (data == EOF) state waiting;
     announcement = [data] + announcement; // reverse order below
     lnum++;
     notekey = llGetNotecardLine("Announcement", lnum);
   }
 }

state waiting {
  changed(integer c) {
    if (c & CHANGED_INVENTORY) state default;
  }
  
  link_message(integer from, integer channel, string n, key akey) {
    if (channel == regionEnter) {
      list plist = llGetObjectDetails(newbie = akey, [OBJECT_POS]);
      if (plist == []) return;
      vector loc = (vector) plist[0];
      string json = "{\"id\": \""+ (string) akey + "\", "+
	"\"x\": " + (string) loc.x + ", " +
	"\"y\": " + (string) loc.y + ", " +
	"\"z\": " + (string) loc.z + "}";

      httpKey = llHTTPRequest(SERVER+"region/enter",
			      [HTTP_MIMETYPE, "application/json",
			       HTTP_METHOD, "POST"],
			      json);
    }
  }

  http_response(key request_id, integer status, list metadata, string body) {
    if (request_id != httpKey) return;
    if (status == 200) { debug("register");
      string  check = (string) llJsonGetValue(body, ["recognized"]);
      if (check == "false") {
	llRegionSayTo(newbie, 0, "Welcome to Evolution!");
	llRegionSayTo(newbie, 0, "Please read the note card for more information.");
	llGiveInventory(newbie, llGetInventoryName(INVENTORY_NOTECARD, WELCOMEcard));
      } else if (check == "true") {
	integer i = llGetListLength(announcement);
	llRegionSayTo(newbie, 0,
		      "Welcome " + llGetDisplayName(newbie) + " to Evolution!");
	while (i > 0) {
	  i--; 
	  llRegionSayTo(newbie, 0, (string) announcement[i]);
	}
      }
      string index = (string) llJsonGetValue(body,["index"]);
      integer success = llLinksetDataWrite((string) newbie, index);
      if (success != 0) {
	llSay(0,(string) success);
      }
    }
    llMessageLinked(LINK_THIS,  registerAck, "", NULL_KEY);
  }
}
