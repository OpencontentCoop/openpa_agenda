<?php /* #?ini charset="utf-8"?

[bitly]
login=netgenpush
apikey=R_b998711fcd083546dc615b95194f5057

[PushNodeSettings]
# Do not add http://
SiteURL=your.site.com

# URL of the folder that contains the redirect.php script. It is called by Twitter and Facebook, so it must be publicly accessible.
ConnectURL=push.opencontent.it

Blocks[]
Blocks[]=tcu
#Blocks[]=twitter
#Blocks[]=facebook
ActiveBlocks[]
ActiveBlocks[]=tcu
#ActiveBlocks[]=twitter
#ActiveBlocks[]=facebook

[tcu]
Name=Trentino Cultura
Type=tcu

[twitter]
Name=Twitter
Type=twitter
ConsumerKey=fzGUD0qBB4jIBTXmCTxUEA
ConsumerSecret=nU9n1jf5U2TCE6CR9GexFhuG2Yob65NPKjDzMJH3d8

# Access tokens are optional. If they are defined, NGPush will not request them with oAuth
AccessToken=
AccessTokenSecret=

# Mapping between Twitter and eZ Publish content classes/attributes.
# attrId_status[<CLASS_NAME>]=<ATTRIBUTE_NAME>

attrId_status[]
attrId_status[article]=title

[facebook]
Name=Facebook
Type=facebook_feed
Id=YOUR_FACEBOOK_PAGE_ID_GOES_HERE
EntityType=page

AppId=287710204681096
AppAPIKey=287710204681096
AppSecret=b66935117a6ed510ce6d471d842cced1

# Optional. If it is defined, NGPush will not request it with oAuth`
# Access token can be found calling : https://graph.facebook.com/oauth/authorize?type=user_agent&client_id=<APP_ID>&redirect_uri=<REDIRECT_URI>&scope=<COMMA_SEPARATED_PERMS>
AccessToken=

# Mapping between Facebook fields and eZ Publish content classes/attributes.
# attrId_name[<CLASS_NAME>]=<ATTRIBUTE_NAME>

attrId_name[]
attrId_name[article]=title
attrId_description[]
attrId_description[article]=intro
attrId_message[]
attrId_message[article]=body
attrId_picture[]
attrId_picture[article]=image
*/?>
