#ifndef serverChannel
#define serverChannel ((integer)("0x"+llGetSubString((string)llGetKey(), -4, -1)))
#endif

#define flexChannel 1000

// key|lpeak|ON3|rpeak|ON3|ltric|OFF|rtric|OFF|back|ON2|rpec|ON2|...
#define flexOrder ["lpeak","rpeak","ltric","rtric","back","rpec","lpec","abs","trap","rthig","lthig","rcalf","lcalf","rhip","lhip","lhand","rhand" ]

#define cOffString "|lpeak|OFF|rpeak|OFF|ltric|OFF|rtric|OFF|back|OFF|rpec|OFF|lpec|ON2|abs|OFF|trap|OFF|rthig|OFF|lthig|OFF|rcalf|OFF|lcalf|OFF|rhip|OFF|lhip|OFF|lhand|RELAX|rhand|RELAX"

#define animateAvatar 2070
#define animatePose 2071
#define animateStand 2072
#define remoteAnimateAvatar 2073
#define remoteAnimatePose 2074
#define remoteAnimateStand 2075
#define remoteAnimate0 2076 // THE CHANNEL OF THE FIRST ANIMATION SCRIPT
#define remoteAnimate1 2077
#define remoteStop 2088
#define setPlayer 2089
