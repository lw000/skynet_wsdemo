package.path = package.path .. ";./service/?.lua;"

local skynet = require("skynet")
local socket = require("skynet.socket")
local service = require("skynet.service")
require("skynet.manager")

local ws_server_id = -1

local agents = {}

local command = {
    server_id = -1
}

function command.START(port)
    local protocol = "ws"
    command.server_id = socket.listen("0.0.0.0", port)
    assert(server_id ~= -1, "listten fail")

    skynet.error(string.format("Listen websocket port:" .. port .. " protocol:%s", protocol))

    socket.start(
        command.server_id,
        function(id, addr)
            print(string.format("accept client socket_id: %s addr:%s", id, addr))

            local handle_id = skynet.newservice("ws_agent")
            agents[handle_id] = handle_id
            skynet.send(handle_id, "lua", id, protocol, addr)
        end
    )

    return 0, "websocket server start success"
end

function command.STOP()
    socket.close(command.server_id)
    skynet.error("websocket exit")
end

skynet.start(
    function()
        skynet.dispatch(
            "lua",
            function(session, address, cmd, ...)
                cmd = cmd:upper()
                if cmd == "START" then
                    local f = command[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                elseif cmd == "STOP" then
                    local f = command[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                else
                    skynet.error(string.format("unknown command %s", tostring(cmd)))
                end
            end
        )
        skynet.register(".ws_server")
    end
)
