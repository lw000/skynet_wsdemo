package.path = ";./service/?.lua;" .. package.path
local skynet = require("skynet")
local conf = require("config.config")
require("common.export")

skynet.start(
    function()
        skynet.newservice("debug_console", conf.debugPort)
        -- local pack_little = string.pack("<I2", 259)
        -- local pack_bigger = string.pack(">I2", 259)
        -- print(
        --     "pack_little = " .. pack_little .. " byte1 = " .. pack_little:byte(1) .. " byte2 = " .. pack_little:byte(2)
        -- )
        -- print(
        --     "pack_bigger = " .. pack_bigger .. " byte1 = " .. pack_bigger:byte(1) .. " byte2 = " .. pack_bigger:byte(2)
        -- )

        local ws_server_id = skynet.newservice("ws_server")
        local ret, err = skynet.call(ws_server_id, "lua", "start", conf.listenPort)
        if ret ~= 0 then
            skynet.error(ret, err)
        end

        for i = 0, 100 do
            skynet.sleep(10)
            local client_id = skynet.newservice("ws_client")
            skynet.send(client_id, "lua", "start", "ws", "127.0.0.1:9948")
        end
        skynet.exit()
    end
)
