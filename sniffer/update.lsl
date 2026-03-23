// Store the SML data on my server

// c4814bb6-38d1-4e6b-9ccb-51a3b0ef0ded|LEVEL:80|STRENGTH:13800|PURE_STRENGTH:13800|BONUS_STRENGTH:102|CUR_STEMINA:420455|MAX_STEMINA:420455|DISP_STEMINA:420455|MONEY:2006599|MAX_FATIGUE:9600|CUR_FATIGUE:0|MAX_EXP:99999999|CUR_EXP:19925753|CUR_STAT:a7cac397-0803-8953-f56f-01f216f6a5a8|STRENGTH_EXP:222566|VERSION:22|HUD_KEY:52987|name

#define UUID 0
#define level 1
#define str 2
#define pure 3
#define bonus 4
#define STA 5
#define maxsta 6
#define disp 7
#define money 8
#define maxfat 9
#define curfat 10
#define maxexp 11
#define curexp 12
#define stat 13
#define strexp 14
#define version 15
#define hudkey 16
#define NAME 17

#ifndef debug
#define debug(x)
#endif

#define statValue(s) llList2String(llParseString2List(s,[":"],[]),1)

key me;
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

  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan != 101) return;
    list sml = llParseString2List(msg,["|"],[]);
    string name = (string) sml[NAME];

    string httprequest =  SERVER + "evolve/update/"+
      llEscapeURL((string) sml[UUID]) + "/" +
      enigma(name) + "?" +
      "lvl=" + statValue((string) sml[level]) + 
      "&str=" + statValue((string) sml[pure]) +
      "&bonusStr=" + statValue((string) sml[str]) +
      "&curSta=" + statValue((string) sml[STA]) +
      "&maxSta=" + statValue((string) sml[maxsta]) +
      "&gold=" + statValue((string) sml[money]) +
      "&maxFat=" + statValue((string) sml[maxfat]) +
      "&curFat=" + statValue((string) sml[curfat]) +
      "&maxExp=" + statValue((string) sml[maxexp]) +
      "&curExp=" + statValue((string) sml[curexp]) +
      "&stat=" + llEscapeURL(statValue((string) sml[stat])) +
      "&strexp=" + statValue((string) sml[strexp]) +
      "&version=" + statValue((string) sml[version]) +
      "&hc=" + llEscapeURL(statValue((string) sml[hudkey])) +
      "&name="+ llEscapeURL(name) +
      "&visit="+ (string) llGetUnixTime();
    debug(httprequest);
    httpKey = llHTTPRequest(httprequest, [], "");
  }
 
 http_response(key request_id, integer status, list metadata, string body) {
    if (request_id != httpKey) return;
    if (status == 200) {
      debug("updated");
    }
  }
}


