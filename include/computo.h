#include "include/server.h"

#define computoChannel 20200629

#define DISTANCE 45

// states
#define doMenu 2
#define warp 3
#define Position 4
#define Circle 5
#define Welcome 6
#define getLocations 8
#define teleport 9
#define select_location 10
#define targetNearby 11
#define selectAvi 12
#define rezFlyMat 13
#define rezVampireMat 14
#define poseAvatar 15
#define avatarPose 16
#define scanRolePlayer 17

#define s_doMenu "2"
#define s_warp "3"
#define s_Position "4"
#define s_Circle "5"
#define s_Welcome "6"
#define s_getLocations "8"
#define s_teleport "9"
#define s_select_location "10"
#define s_targetNearby "11"
#define s_selectAvi "12"
#define s_rezFlyMat "13"
#define s_rezVampireMat "14"
#define s_poseAvatar "15"
#define s_avatarPose "16"

// deprecated... use experiences instead
#define rlvRelayTest 300
#define s_rlvRelayTest "300"
#define checkRelay 301
#define s_checkRelay "301"

// cora is 500
#include "include/cora.h"

#define waitTime 2
#define PING_MAX 5

#define OFFSET <-1,0,0>
#define toUp <0,-90,0>
#define toFront <90,0,0>
#define rotUp llEuler2Rot(toUp * DEG_TO_RAD)
#define rotFront llEuler2Rot(toFront * DEG_TO_RAD)
#define ROTATION ZERO_ROTATION

#define cTimer  0.01
#define radius  1 //in meters out from the start
#define zIncrement -1 // positive = counterclockwise
#define xIncrement 0.4
#define HEIGHT <0,0,1>
#define UP  llEuler2Rot(<0, 90, 0>)
#define JERK < llFrand(0.5) - 0.25, llFrand(0.75) - 0.4, 0>

#define AXIS <1, 0, 0>

#define FRONT 2.5

#define SMALLER 1.0
#define SMALL 1.25
#define MEDIUM 1.5
#define BIG 1.75


