#ifndef debug
#define debug(x)
#endif

#define RESET 100
#define EXTEND 101
#define DESCEND 102
#define POWER_ON 103
#define POWER_OFF 104
#define UPDATE_DB 105
#define SETUP 106
#define MENU 107
#define DISPLAY 108
#define CORA 109
#define SAVE_SEQUENCE 110
#define SAVE_CHAR 111
#define SPARK 112
#define BATTERY 113

integer strand;
integer tool;

default {
  state_entry() {
    integer objectPrimCount = llGetObjectPrimCount(llGetKey());
    integer currentLinkNumber = 0;
    while(currentLinkNumber <= objectPrimCount) {
      debug(currentLinkNumber);
      list params = llGetLinkPrimitiveParams(currentLinkNumber,[PRIM_NAME]);
      switch((string) params[0]) {
      case "dna": {
	strand = currentLinkNumber;
	break;
      }
      case "DNA Tool": {
	tool = currentLinkNumber;
	break;
      }
      default: break;
      }
      ++currentLinkNumber;
    }
    llMessageLinked(LINK_SET, RESET, "", NULL_KEY);
  }

  link_message(integer from, integer chan, string msg, key xyzzy) {
    if (chan > 0 && chan < 9) {
      // buttons
      if (msg == "0") {
	llSetText("", <1,1,1>,1);
	llMessageLinked(LINK_SET, POWER_ON, "", xyzzy);
	llMessageLinked(LINK_THIS,
			MENU, (string) CORA + "+" + (string) SETUP +
			"|Setup your character|MPG Hero", xyzzy);
      }    
    }
  }
}
