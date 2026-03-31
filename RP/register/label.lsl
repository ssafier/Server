// because people will inevitably click the label

#define RESET 100
#define POWER_ON 103

string power;
default {
  state_entry() {
    llSetClickAction(CLICK_ACTION_TOUCH);
    power = "0";
  }
  touch_state() {
    llMesssageLinked(LINK_ROOT, BUTTON, power, llDetectedKey(0));
  }
  link_message(integer from, integer chan, string msg, key xyzzy) {
    switch(chan) {
    case RESET: {
      power = "0";
      break;
    }
    case POWER_ON: {
      power = "1";
      break;
    }
    default: break;
  }
}
