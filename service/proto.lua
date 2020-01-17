local skynet = require "skynet"

local pb = require("protobuf")

pb.register_file("./protos/service.pb")
skynet.error("注册service协议")

local proto = {}

function proto.encode_ReqRegService(t)
    return pb.encode("Tapi.ReqRegService", t)
end

function proto.decode_AckRegService(data)
    return pb.decode("Tapi.AckRegService", data)
end

function proto.decode_ReqServerConned(t)
    return pb.decode("Tapi.ReqServerConned", t)
end

function proto.decode_ReqServerClosed(data)
    return pb.decode("Tapi.ReqServerClosed", data)
end

return proto
