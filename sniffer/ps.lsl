#ifndef debug
#define debug(x)
#endif

// The SML wristband spans a channel with the following information

// UUID|LEVEL:80|STRENGTH:13800|PURE_STRENGTH:13800|BONUS_STRENGTH:102|CUR_STEMINA:420455|MAX_STEMINA:420455|DISP_STEMINA:420455|MONEY:2006599|MAX_FATIGUE:9600|CUR_FATIGUE:0|MAX_EXP:99999999|CUR_EXP:19925753|CUR_STAT:a7cac397-0803-8953-f56f-01f216f6a5a8|STRENGTH_EXP:222566|VERSION:22|HUD_KEY:52987

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

integer handle = -1;

#define makeKey(base)  llSHA1String((string) (base))

default {
  state_entry() {
    handle = llListen(SML_STATS_CHANNEL,"",NULL_KEY,"");
  }

  listen(integer channel, string name, key id, string message) {
    integer namePos= llSubStringIndex(message,"|");
    if (namePos > 0) {
      string k = llGetSubString(message,0,namePos-1);
      string name = llKey2Name(k);
      integer i = llSubStringIndex(name, " Resident");
      if (i != -1) name = llGetSubString(name, 0, i);
      debug(message + "|" + name + " " + k);
      llMessageLinked(LINK_THIS, 100, message + "|" + name, (key) k);
    }
  }
}
