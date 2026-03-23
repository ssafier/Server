#include "include/server.h"




#ifndef debug
#define debug(x)
#endif

integer handle;

#define STRIDE 2
#define SERVER_NAME 0
#define SERVER_KEY 1

//subservers

list servers = [
		"animate", "48805eef-1d50-87b9-0212-0b41086dbc33",
		"animate-menu", "48805eef-1d50-87b9-0212-0b41086dbc33",
		"crawl", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"get-rezzables", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"get-targetables", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"get-combat", "567adf12-087d-5e63-301d-10b5d5981a89",
		"get-workout", "ac091694-ace2-a800-9780-292c6f7f81d4",
		"get-worship", "03606b3e-794f-3e8d-52c6-fb3a5cafa625",
		"get-erotic", "3d7fd2c8-a239-0312-8709-fc2d654b7920",
		"get-power", "4cd2de0f-a99e-3413-537d-aa9b97766791",
		"get-vampire", "1854c1d8-78b5-2bf9-b496-3eefe257c6c2",
		"get-wrestle", "ee9aaa33-60cb-6604-fd52-e03e46bb1102",

		"kill-combat", "567adf12-087d-5e63-301d-10b5d5981a89",
		"kill-workout", "ac091694-ace2-a800-9780-292c6f7f81d4",
		"kill-worship", "03606b3e-794f-3e8d-52c6-fb3a5cafa625",
		"kill-erotic", "3d7fd2c8-a239-0312-8709-fc2d654b7920", 
		"kill-power", "4cd2de0f-a99e-3413-537d-aa9b97766791",
		"kill-vampire", "1854c1d8-78b5-2bf9-b496-3eefe257c6c2",
		"kill-wrestle", "ee9aaa33-60cb-6604-fd52-e03e46bb1102",
		"kill-flight", "f21a04e2-791d-e58a-3209-f9c354549847",

		"rez-combat", "567adf12-087d-5e63-301d-10b5d5981a89",
		"rez-workout", "ac091694-ace2-a800-9780-292c6f7f81d4",
		"rez-worship", "03606b3e-794f-3e8d-52c6-fb3a5cafa625",
		"rez-erotic", "3d7fd2c8-a239-0312-8709-fc2d654b7920",
		"rez-power", "4cd2de0f-a99e-3413-537d-aa9b97766791",
		"rez-throwable", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"rez-object", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"rez-object-new", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"rez-lift-n-carry", "31bd4ae7-156f-5813-252f-27a6d774cb21",				
		"rez-target", "31bd4ae7-156f-5813-252f-27a6d774cb21",		
		"rez-weapon", "31bd4ae7-156f-5813-252f-27a6d774cb21",
		"rez-attachment", "31bd4ae7-156f-5813-252f-27a6d774cb21",		
		"rez-vampire", "1854c1d8-78b5-2bf9-b496-3eefe257c6c2",
		"rez-wrestle", "ee9aaa33-60cb-6604-fd52-e03e46bb1102",
		"rez-flight", "f21a04e2-791d-e58a-3209-f9c354549847",
		
		"target-weapon", "31bd4ae7-156f-5813-252f-27a6d774cb21",

		"region-players", "a424ada4-551b-dc57-da3d-8c35354b5373",
		"register-player", "a424ada4-551b-dc57-da3d-8c35354b5373",
		// implemented in region.lsl as part of departring
		//		"check-region", "a424ada4-551b-dc57-da3d-8c35354b5373",
		"give-hud", "a424ada4-551b-dc57-da3d-8c35354b5373"
];

#define getChan(x) (integer)("0x"+llGetSubString(x, -4, -1))
default {
  state_entry() {
    handle = llListen(evolveServerChannel, "", NULL_KEY, "");
  }
  
  listen(integer chan, string name, key xyzzy, string msg) {
    list m = llParseString2List(msg,["|"],[]);
    string server =(string) m[0];
    integer s;
    if ((s = llListFindStrided(servers, [server],0,-1, STRIDE) == -1)) {
      return;
    }
    // send message to subserver
    string subserver = (string) servers[s + SERVER_KEY];
    llRegionSayTo((key) subserver, getChan(subserver), msg);
  }
}

