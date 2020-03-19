package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local conf = require("config.config")
require("common.export")

skynet.start(
    function()
        for i = 0, 100 do
            skynet.sleep(10)
            local client_id = skynet.newservice("ws_client")
            skynet.send(client_id, "lua", "start", "ws", "127.0.0.1:9948")
        end
        skynet.exit()
    end
)
