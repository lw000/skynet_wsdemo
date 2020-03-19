package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/ws_server/?.lua;"
local skynet = require("skynet")
local socket = require("skynet.socket")
local service = require("skynet.service")
require("skynet.manager")

local command = {
    socketid = -1,
    port = 8080,
    agents = {}
}

function command.START(port)
    command.port = port

    command.run()

    return 0
end

function command.STOP()
    socket.close(command.socketid)
    skynet.error("websocket exit")
end

function command.run()
    local protocol = "ws"
    command.socketid = socket.listen("0.0.0.0", command.port)
    assert(command.socketid ~= -1, "listten fail")

    skynet.error(string.format("Listen websocket port: " .. command.port .. " protocol:%s", protocol))

    socket.start(command.socketid, function(id, addr)
            skynet.error(string.format("accept client socket_id: %s addr:%s", id, addr))
            local agent_id = skynet.newservice("agent")
            command.agents[agent_id] = agent_id
            skynet.send(agent_id, "lua", id, protocol, addr)
        end
    )
end

local function dispatch()
    skynet.dispatch(
            "lua",
            function(session, address, cmd, ...)
                cmd = cmd:upper()
                local f = command[cmd]
                assert(f)
                if f then
                    skynet.ret(skynet.pack(f(...)))
                else
                    skynet.error(string.format("unknown command %s", tostring(cmd)))
                end
            end
        )
        skynet.register(".ws_server")
end

skynet.start(dispatch)
