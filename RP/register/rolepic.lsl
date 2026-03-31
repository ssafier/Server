#define RESET 100
#define POWER_OFF 104
#define renderImage  108
#define cFace ALL_SIDES

key http_key;
list sides;
list deftextures;

string profile_key_prefix = "<meta name=\"imageid\" content=\"";
string profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
integer profile_key_prefix_length; // calculated from profile_key_prefix in state_entry()
integer profile_img_prefix_length; // calculated from profile_key_prefix in state_entry()
 
default {
  state_entry() {
    profile_key_prefix_length = llStringLength(profile_key_prefix);
    profile_img_prefix_length = llStringLength(profile_img_prefix);
  }

  link_message(integer from, integer chan, string msg, key alpha) {
    if (chan == RESET || chan == POWER_OFF) {
      llSetLinkPrimitiveParamsFast(LINK_THIS,
				   [PRIM_TEXTURE, ALL_SIDES, TEXTURE_BLANK, <1,1,0>, ZERO_VECTOR, 0,
				    PRIM_COLOR, ALL_SIDES, <0,0,0>,1.0]);
      return;
    }
    if (chan == renderImage) {
      string URL_RESIDENT = "http://world.secondlife.com/resident/" + (string) alpha;
      http_key = llHTTPRequest( URL_RESIDENT, [HTTP_METHOD,"GET"],"");
    }
  }
  
  http_response(key req,integer stat, list met, string body) {
    if (req != http_key) return;
    integer s1 = llSubStringIndex(body, profile_key_prefix);
    integer s1l = profile_key_prefix_length;
    if(s1 == -1) { // second try
      s1 = llSubStringIndex(body, profile_img_prefix);
      s1l = profile_img_prefix_length;
    }
    
    if(s1 != -1)  {
      s1 += s1l;
      key UUID=llGetSubString(body, s1, s1 + 35);
      if (UUID == NULL_KEY) {
	llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXTURE, ALL_SIDES, TEXTURE_TRANSPARENT, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0]);
      } else {
	llSetLinkPrimitiveParamsFast(LINK_THIS,
				     [PRIM_TEXTURE, ALL_SIDES, UUID, <1.0, 1.0, 0.0>, ZERO_VECTOR, 270 * DEG_TO_RAD,
				      PRIM_COLOR, ALL_SIDES, <1,1,1>,1.0]);
      }
    }
  }
}
