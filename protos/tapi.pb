
Ä

tapi.protoTapi"œ
ReqLogin
loginAcc (	RloginAcc
addScore (RaddScore
orderId (	RorderId
gameId (RgameId
mobile (	Rmobile
isBind (RisBind
gender (Rgender
nickName (	RnickName
faceUrl	 (	RfaceUrl
canalId
 (RcanalId

deviceType (R
deviceType
	machineId (	R	machineId
clientIp (	RclientIp
agentId (RagentId
authType (RauthType"Ì
AckLogin
result (Rresult
errmsg (	Rerrmsg
code (Rcode
addScore (RaddScore
loginAcc (	RloginAcc
token (	Rtoken
gameId (RgameId
userId (RuserId"’

ReqUpScore
loginAcc (	RloginAcc
addScore (RaddScore
orderId (	RorderId
agentId (RagentId
canalId (RcanalId"¶

AckUpScore
result (Rresult
errmsg (	Rerrmsg
code (Rcode
loginAcc (	RloginAcc
addScore (RaddScore
score (Rscore
userId (RuserId"–
ReqDownScore
loginAcc (	RloginAcc
	takeScore (R	takeScore
orderId (	RorderId
agentId (RagentId
canalId (RcanalId"º
AckDownScore
result (Rresult
errmsg (	Rerrmsg
code (Rcode
loginAcc (	RloginAcc
	takeScore (R	takeScore
score (Rscore
userId (RuserId")
ReqQueryOrder
orderId (	RorderId"[
AckQueryOrder
code (Rcode
status (Rstatus

orderScore (R
orderScore"E
ReqUserStatus
loginAcc (	RloginAcc
canalId (RcanalId";
AckUserStatus
code (Rcode
status (Rstatus"D
ReqUserScore
loginAcc (	RloginAcc
canalId (RcanalId"n
AckUserScore
code (Rcode
score (Rscore
	takeScore (R	takeScore
status (Rstatus"I
ReqQueryDownScore
loginAcc (	RloginAcc
canalId (RcanalId"=
AckQueryDownScore
code (Rcode
score (Rscore"C
ReqKickUser
loginAcc (	RloginAcc
canalId (RcanalId"!
AckKickUser
code (Rcode"ö

GameRecord
loginAcc (	RloginAcc
recordId (	RrecordId
gameName (	RgameName 
changeScore (RchangeScore
revenue (Rrevenue 
jettonScore (RjettonScore
	startTime (	R	startTime
endTime (	RendTime"—
ReqGameRecord
loginAcc (	RloginAcc
agentId (RagentId
canalId (RcanalId
	startTime (	R	startTime
endTime (	RendTime"W
AckGameRecord
code (Rcode2
gameRecords (2.Tapi.GameRecordRgameRecords