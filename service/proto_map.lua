local pb = require("protobuf")

proto_map = proto_map or
    {
        [0x0001] = {
            name = "MDM_CORE", -- 注册服务主命令
            [0x0001] = {name = "SUB_CORE_REGISTER", req = "Tapi.ReqRegService", ack = "Tapi.AckRegService", dest = "注册服务器"},
            [0x0002] = {name = "SUB_CORE_SVRCONNED", req = "", ack = "Tapi.ReqServerConned", dest = "服务器已连接"},
            [0x0003] = {name = "SUB_CORE_SVRCLOSED", req = "", ack = "Tapi.ReqServerClosed", dest = "服务器已关闭"}
        }
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

function proto_map.decode_AckRegService(data)
    return pb.decode("Tapi.AckRegService", data)
end

function proto_map.decode_ReqServerConned(t)
    return pb.decode("Tapi.ReqServerConned", t)
end

function proto_map.decode_ReqServerClosed(data)
    return pb.decode("Tapi.ReqServerClosed", data)
end
