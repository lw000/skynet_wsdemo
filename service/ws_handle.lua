package.path = package.path .. ";./service/?.lua;"

local skynet = require("skynet")
local websocket = require("http.websocket")
local packet = require("network.packet")
require("proto_map")

local handle = {}

local msgs_switch = {
    [0x0000] = {
        [0x0000] = {
            name = "",
            dest = "心跳",
            fn = function(id, pk)
                skynet.error("心跳", os.date("%Y-%m-%d %H:%M:%S", os.time()))
            end
        }
    },
    [0x0001] = {
        [0x0001] = {
            name = "SUB_CORE_REGISTER",
            dest = "心跳",
            fn = function(id, pk)
                local reqRegService = proto_map.decode_ReqRegService(pk:data())
                dump(reqRegService, "service recv, ReqRegService")

                local ackRegService =
                    proto_map.encode_AckRegService(
                    {
                        result = 0,
                        serverId = 10000,
                        errmsg = "客户端注册成功"
                    }
                )
                handle.send(id, pk:mid(), pk:sid(), pk:clientId(), ackRegService)

                local reqServerConned =
                    proto_map.encode_ReqServerConned(
                    {
                        serverId = 1, -- 服务器ID
                        svrType = 2, -- 服务器类型
                        host = "192.168.0.105", -- 服务器地址
                        port = 9090 -- 服务器类型
                    }
                )
                handle.send(id, pk:mid(), 0x0002, pk:clientId(), reqServerConned)
            end
        },
        [0x0002] = {
            name = "SUB_CORE_SVRCONNED",
            dest = "服务连接",
            fn = function(id, pk)
            end
        },
        [0x0003] = {
            name = "SUB_CORE_SVRCLOSED",
            dest = "服务断开",
            fn = function(id, pk)
            end
        }
    }
}

function handle.connect(id)
    skynet.error("ws connect from: " .. tostring(id))
end

function handle.handshake(id, header, url)
    local addr = websocket.addrinfo(id)
    skynet.error("ws handshake from: " .. tostring(id), "url=" .. url, "addr=" .. addr)
    skynet.error("----header-----")
    for k, v in pairs(header) do
        skynet.error(k, v)
    end
    skynet.error("--------------")
end

function handle.message(id, msg)
    local pk = packet:new()
    pk:unpack(msg)

    skynet.error(
        "<: handle",
        "id=" .. id,
        "ver=" .. pk:ver(),
        "mid=" .. pk:mid(),
        "sid=" .. pk:sid(),
        "checkCode=" .. pk:checkCode(),
        "clientId=" .. pk:clientId(),
        "dataLen=" .. string.len(pk:data())
    )

    local msgmap = msgs_switch[pk:mid()][pk:sid()]
    if msgmap then
        if msgmap.fn ~= nil then
            skynet.fork(msgmap.fn, id, pk)
        end
    else
        skynet.error("<: pk", "mid=" .. pk:mid() .. ", sid=" .. pk:sid() .. "命令未实现")
    end
end

function handle.ping(id)
    skynet.error("ws ping from: " .. tostring(id) .. "\n")
end

function handle.pong(id)
    skynet.error("ws pong from: " .. tostring(id))
end

function handle.close(id, code, reason)
    skynet.error("ws close from: " .. tostring(id), code, reason)
end

function handle.error(id)
    skynet.error("ws error from: " .. tostring(id))
end

function handle.send(wsid, mid, sid, clientid, content)
    local pk = packet:new()
    pk:pack(mid, sid, clientid, content)
    if pk:data() == nil then
        skynet.error("packet create error")
        return 0, "packet create error"
    end
    websocket.write(wsid, pk:data(), "binary", 0x02)
    return 1, nil
end

skynet.start(
    function()
        skynet.dispatch(
            "lua",
            function(session, address, sock_id, protocol, addr)
                skynet.error(
                    "accept",
                    "session=" .. session,
                    "address=" .. skynet.address(address),
                    "sock_id=" .. sock_id,
                    "protocol=" .. protocol,
                    "addr=" .. addr
                )
                local ok, err = websocket.accept(sock_id, handle, protocol, addr)
                if not ok then
                    skynet.error(err)
                end
            end
        )

        proto_map.registerFiles("./protos/service.pb")

        -- skynet.register("ws_handle")
    end
)
