package.path = package.path .. ";./service/?.lua;"

local skynet = require("skynet")
local service = require("skynet.service")
local ws = require("network.ws")
require("skynet.manager")
require("common.export")
require("proto_map")

local command = {
    running = false,
    client = ws:new()
}

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

function command.START(scheme, host)
    command.client:handleMessage(command.onMessage)
    command.client:handleError(command.onError)
    local ok, err = command.client:connect(scheme, host)
    if err then
        return 1, "网络服务启动失败"
    end
    command.registerService(6)
    command.running = true
    command.alive()
    return 0, "网络服务启动成功" 
end

function command.registerService(svrType)
    local reqRegService =
        proto_map.encode_ReqRegService(
        {
            serverId = command.client:serverId(),
            svrType = svrType
        }
    )
    -- wsclient:registerService(0x0001, 0x0001, 0, content)

    command.client:registerService(
        0x0001,
        0x0001,
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

function command.alive()
    skynet.fork(
        function()
            while command.running do
                local checking = command.client:open()
                if not checking then
                    skynet.error("断线重连")
                    command.client:connect(
                        "ws",
                        string.format("%s:%d", command.sysconf["ws"].ip, command.sysconf["ws"].port),
                        ""
                    )
                    command.registerService(SVR_TYPE.ServerType)
                end
                skynet.sleep(100 * 3)
            end
        end
    )
end

function command.onMessage(conn, pk)
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

function command.onError(err)
    skynet.error(err)
end

skynet.init(
    function()
        skynet.error("ws_client init success......")
    end
)

local function dispatch()
    skynet.dispatch(
        "lua",
        function(session, address, cmd, ...)
            cmd = cmd:upper()
            if cmd == "START" then
                local f = command[cmd]
                assert(f)
                skynet.ret(skynet.pack(f(...)))
            else
                skynet.error(string.format("unknown command %s", tostring(cmd)))
            end
        end
    )
    skynet.register(".ws_client")
    proto_map.registerFiles("./protos/service.pb")
end

skynet.start(dispatch)
