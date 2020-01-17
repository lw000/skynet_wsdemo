local pb = require("protobuf")

pb.register_file("./protos/service.pb")
print("注册service.pb协议")

SVR_TYPE = {
    ServerType = 6 -- 服务类型
}

msgswitch = {
    [0x0000] = {
        [0x0000] = {
            name = "心跳消息",
            fn = function(conn, pk)
                print("心跳消息", os.date("%Y-%m-%d %H:%M:%S", os.time()))
            end
        }
    },
    [0x0001] = {
        [0x0001] = {
            name = "SUB_CORE_REGISTER",
            fn = function(conn, pk)
                local data = pb.decode("Tapi.AckRegService", pk:data())
                if data.result == 0 then
                    print(
                        "服务注册成功",
                        "result=" .. data.result .. ", serverId=" .. data.serverId .. ", errmsg=" .. data.errmsg
                    )
                end
            end
        },
        [0x0002] = {
            name = "SUB_CORE_SVRCONNED",
            fn = function(conn, pk)
                local data = pb.decode("Tapi.ReqServerConned", pk:data())
                print(
                    "服务器已连接",
                    "serverId=" ..
                        data.serverId ..
                            ", svrType=" .. data.svrType .. ", host=" .. data.host .. ", port=" .. data.port
                )
            end
        },
        [0x0003] = {
            name = "SUB_CORE_SVRCLOSED",
            fn = function(conn, pk)
                local data = pb.decode("Tapi.ReqServerClosed", pk:data())
                print("服务器已关闭", "serverId=" .. data.serverId .. ", svrType=" .. data.svrType)
            end
        }
    }
}

dump(msgswitch, "msgswitch")

-- return msgswitch
