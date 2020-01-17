package.path = package.path .. ";./service/?.lua;./service/common/?.lua;"
require("export")
require("msgswitch")
require("proto_map")
local skynet = require "skynet"
local service = require "skynet.service"
local ws = require("ws")
local wsclient = ws:new()

dump(proto_map, "proto_map")

proto_map.registerFiles("./protos/service.pb", "./protos/tapi.pb")

-- local msgswitch000 = {}

-- function addswitch(mid, sid, fn)
--     local mids = msgswitch000[mid]
--     if mids == nil then
--         mids = {}
--         msgswitch000[mid] = mids
--     end
--     -- dump(mids)

--     local sids = mids[sid]
--     if sids == nil then
--         sids = {}
--     end
--     sids.fn = fn

--     mids[sid] = sids

--     -- dump(mids)
-- end

function main(...)
    -- ws:connect("ws", "192.168.0.102:8830")
    wsclient:connect("ws", "47.97.66.156:8850")
    wsclient:onMessage(
        function(ws, pk)
            local msgmap = msgswitch[pk:mid()][pk:sid()]
            if msgmap then
                skynet.fork(msgmap.fn, self, pk)
            else
                skynet.error("<: pk", "mid=" .. pk:mid() .. ", sid=" .. pk:sid() .. "命令未实现")
            end
        end
    )

    if wsclient:open() then
        local content =
            proto_map.encode_ReqRegService(
            {
                serverId = 0,
                svrType = 6
            }
        )
        -- wsclient:registerService(
        --     0x0001,
        --     0x0001,
        --     0,
        --     content,
        --     function(conn, pk)
        --         local data = proto_map.decode_AckRegService(pk:data())
        --         dump(data, "AckRegService")
        --         if data.result == 0 then
        --             skynet.error(
        --                 "服务注册成功",
        --                 "result=" .. data.result .. ", serverId=" .. data.serverId .. ", errmsg=" .. data.errmsg
        --             )
        --         end
        --     end
        -- )

        wsclient:registerService(0x0001, 0x0001, 0, content)
    end
end

skynet.start(
    function()
        -- local pack_little = string.pack("<I2", 259)
        -- local pack_bigger = string.pack(">I2", 259)
        -- print(
        --     "pack_little = " .. pack_little .. " byte1 = " .. pack_little:byte(1) .. " byte2 = " .. pack_little:byte(2)
        -- )
        -- print(
        --     "pack_bigger = " .. pack_bigger .. " byte1 = " .. pack_bigger:byte(1) .. " byte2 = " .. pack_bigger:byte(2)
        -- )
        -- for i = 1, 5 do
        --     for j = 1, 5 do
        --         addswitch(
        --             i,
        --             j,
        --             function(mid, sid)
        --                 print(mid, sid)
        --             end
        --         )
        --     end
        -- end
        -- dump(msgswitch000)
        -- local fn = msgswitch000[5][5]
        -- dump(fn)
        -- if fn then
        --     fn.fn(5, 5)
        -- end

        main()
    end
)
