#define server ((integer)("0x"+llGetSubString("f21a04e2-791d-e58a-3209-f9c354549847", -4, -1)))
#define Corwin "c4814bb6-38d1-4e6b-9ccb-51a3b0ef0ded"
#define Q "f6148cf9-0ff1-415e-9249-61f58d9713cd"

default {
  touch_start(integer x) {
    llRegionSay(server,"rez-flight|"+Corwin+"|ignore|"+Q+"|123|1");
  }
}
