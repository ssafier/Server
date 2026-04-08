#define serverChannel ((integer)("0x"+llGetSubString((string)llGetKey(), -4, -1)))
#define SUBSERVER_FORCE_DETACH -20240202
#define SubServerChannel 20230929
#define regionEmptyChan 20231027

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

#define clearPlayer 20222
#define getPlayer1 20223
#define getPlayer2 20224
#define updatePlayer1 20225
#define updatePlayer2 20226
#define computeFight 20227
#define takeMenu1 20228
#define takeMenu2 20229
#define killPlayer 20230
#define killAndPause 20231

#define s_clearPlayer "20222"
#define s_getPlayer1 "20223"
#define s_getPlayer2 "20224"
#define s_updatePlayer1 "20225"
#define s_updatePlayer2 "20226"
#define s_computeFight "20227"
#define s_takeMenu1 "20228"
#define s_takeMenu2 "20229"
