package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/common/?.lua;"
package.path = package.path .. ";./service/net/?.lua;"

local skynet = require "skynet"
local socket = require "skynet.socket"
local service = require "skynet.service"
local queue = require "skynet.queue"
require "skynet.manager" -- import skynet.register
require "export"

local cs = queue() --获取一个执行队列

local cache = {
    version = "1.0.0",
    store = {}
}

local CMD = {}

function CMD.START()
    return 0
end

function CMD.SET(key, value)
    cache.store[key] = value
end

function CMD.GET(key)
    local v = cache.store[key]
    if v ~= nil then
        return v
    end
    return nil
end

function CMD.RESET()
    cache.store = {}
end

function CMD.DUMP()
    dump(cache, "cache")
end

skynet.start(
    function()
        skynet.dispatch(
            "lua",
            function(session, address, cmd, ...)
                cmd = cmd:upper()
                if cmd == "SET" then
                    local f = CMD[cmd]
                    assert(f)
                    skynet.ret(skynet.pack(cs(f, ...)))
                else
                    local f = CMD[cmd]
                    assert(f)
                    if f then
                        skynet.ret(skynet.pack(f(...)))
                    else
                        skynet.error(string.format("Unknown command %s", tostring(cmd)))
                    end
                end
            end
        )
        skynet.register("mydb")
    end
)
