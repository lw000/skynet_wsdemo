package.path = package.path .. ";./service/?.lua;"

local skynet = require("skynet")
local socket = require("skynet.socket")
local service = require("skynet.service")
require("skynet.manager")

local ws_server_id = -1

local agents = {}

local CMD = {}

function CMD.START(port)
    local protocol = "ws"
    ws_server_id = socket.listen("0.0.0.0", port)
    assert(ws_server_id ~= -1, "listten fail")

    skynet.error(string.format("Listen websocket port:" .. port .. " protocol:%s", protocol))

    socket.start(
        ws_server_id,
        function(id, addr)
            print(string.format("accept client socket_id: %s addr:%s", id, addr))

            local handle_server_id = skynet.newservice("ws_handle")
            agents[handle_server_id] = handle_server_id
            skynet.send(handle_server_id, "lua", id, protocol, addr)
        end
    )
    return 0, "websocket server start success"
end

function CMD.STOP()
    socket.close(ws_server_id)
    skynet.error("websocket exit")
end

skynet.start(
    function()
        skynet.dispatch(
            "lua",
            function(session, address, cmd, ...)
                cmd = cmd:upper()
                if cmd == "START" then
                    local f = CMD[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                else
                    skynet.error(string.format("Unknown command %s", tostring(cmd)))
                end
            end
        )
        skynet.register("ws_server")
    end
)
