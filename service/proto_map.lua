local pb = require("protobuf")

proto_map = proto_map or {}

local pbfiles = {
    "protos/service.pb"
}

function proto_map.registerFiles(...)
    local args = {...}
    for i = 1, #args do
        pb.register_file(args[i])
        print("注册" .. args[i] .. "协议")
    end
end

function proto_map.encode_ReqRegService(t)
    return pb.encode("Tapi.ReqRegService", t)
end

function proto_map.decode_ReqRegService(data)
    return pb.decode("Tapi.ReqRegService", data)
end

function proto_map.encode_AckRegService(t)
    return pb.encode("Tapi.AckRegService", t)
end

function proto_map.decode_AckRegService(data)
    return pb.decode("Tapi.AckRegService", data)
end

function proto_map.encode_ReqServerConned(t)
    return pb.encode("Tapi.ReqServerConned", t)
end

function proto_map.decode_ReqServerConned(data)
    return pb.decode("Tapi.ReqServerConned", data)
end

function proto_map.encode_ReqServerClosed(t)
    return pb.encode("Tapi.ReqServerClosed", t)
end

function proto_map.decode_ReqServerClosed(data)
    return pb.decode("Tapi.ReqServerClosed", data)
end

local function init()
    for i, c in pairs(pbfiles) do
        proto_map.registerFiles(c)
    end
end

init()
