package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local conf = require("config.config")
require("common.export")

skynet.start(function()
        skynet.newservice("debug_console", conf.debugPort)

        local ws_server_id = skynet.uniqueservice("ws_server")
        local ret, err = skynet.call(ws_server_id, "lua", "start", conf.listenPort)
        if err then
            skynet.error(ret, err)
        end
        skynet.exit()
    end
)
