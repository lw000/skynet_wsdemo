package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/common/?.lua;"
package.path = package.path .. ";./service/net/?.lua;"

local skynet = require "skynet"
local ws = require("ws")
require "skynet.manager"
require("export")
require("proto_map")

proto_map.registerFiles("./protos/service.pb")

local client = ws:new()

local CMD = {}

local msgs_switch = {
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
                local data = proto_map.decode_AckRegService(pk:data())
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
                local data = proto_map.decode_ReqServerConned(pk:data())
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
                local data = proto_map.decode_ReqServerClosed(pk:data())
                print("服务器已关闭", "serverId=" .. data.serverId .. ", svrType=" .. data.svrType)
            end
        }
    }
}

function CMD.START(scheme, host)
    client:connect(scheme, host)
    client:handleMessage(
        function(conn, pk)
            local msgmap = msgs_switch[pk:mid()][pk:sid()]
            if msgmap then
                if msgmap.fn ~= nil then
                    skynet.fork(msgmap.fn, self, pk)
                -- msgmap.fn(self, pk)
                end
            else
                print("<: pk", "mid=" .. pk:mid() .. ", sid=" .. pk:sid() .. "命令未实现")
            end
        end
    )

    client:handleError(
        function(...)
            -- body
        end
    )

    CMD.registerService(0, 6)
end

function CMD.registerService(serverId, svrType)
    local reqRegService =
        proto_map.encode_ReqRegService(
        {
            serverId = serverId,
            svrType = svrType
        }
    )
    -- wsclient:registerService(0x0001, 0x0001, 0, content)

    client:registerService(
        0x0001,
        0x0001,
        0,
        reqRegService,
        function(conn, pk)
            local data = proto_map.decode_AckRegService(pk:data())
            dump(data, "AckRegService")
            if data.result == 0 then
                print("服务注册成功", "result=" .. data.result, "serverId=" .. data.serverId, "errmsg=" .. data.errmsg)
            end
        end
    )
end

function dispatcher()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            if cmd == "START" then
                local f = CMD[cmd]
                assert(f)
                skynet.ret(skynet.pack(f(...)))
            end
        end
    )
    skynet.register("ws_client")
end

skynet.start(dispatcher)
