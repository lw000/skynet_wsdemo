package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/common/?.lua;"
package.path = package.path .. ";./service/net/?.lua;"

local skynet = require "skynet"
local socket = require "skynet.socket"
local service = require "skynet.service"
require "skynet.manager"

local cache = {}

local CMD = {}

function CMD.START()
    return 0
end

function CMD.SET(key, value)
    cache[key] = value
end

function CMD.GET(key)
    local v = cache[key]
    if v ~= nil then
        return v
    end
    return nil
end

function CMD.RESET()
    cache = {}
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
                elseif cmd == "STOP" then
                    local f = CMD[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                elseif cmd == "GET" then
                    local f = CMD[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                elseif cmd == "SET" then
                    local f = CMD[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                elseif cmd == "RESET" then
                    local f = CMD[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(f(...)))
                else
                    skynet.error(string.format("Unknown command %s", tostring(cmd)))
                end
            end
        )
        skynet.register("mydb")
    end
)
