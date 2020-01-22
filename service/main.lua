package.path = package.path .. ";./service/?.lua;"
package.path = package.path .. ";./service/common/?.lua;"
package.path = package.path .. ";./service/net/?.lua;"

local skynet = require "skynet"
local service = require "skynet.service"
local ws = require("ws")

require("export")
-- require("proto_map")

-- proto_map.registerFiles("./protos/service.pb")

-- local WSService = {}
-- function WSService.call(cmd, ...)
--     local ret = skynet.call(WSService.service, "lua", cmd, ...)
--     skynet.error("ret", ret)
-- end

-- function WSService.send(cmd, ...)
--     skynet.send(WSService.service, "lua", cmd, ...)
-- end

-- local msgs_switch = {
--     [0x0000] = {
--         [0x0000] = {
--             name = "心跳消息",
--             fn = function(conn, pk)
--                 print("心跳消息", os.date("%Y-%m-%d %H:%M:%S", os.time()))
--             end
--         }
--     },
--     [0x0001] = {
--         [0x0001] = {
--             name = "SUB_CORE_REGISTER",
--             fn = function(conn, pk)
--                 local data = proto_map.decode_AckRegService(pk:data())
--                 if data.result == 0 then
--                     print(
--                         "服务注册成功",
--                         "result=" .. data.result .. ", serverId=" .. data.serverId .. ", errmsg=" .. data.errmsg
--                     )
--                 end
--             end
--         },
--         [0x0002] = {
--             name = "SUB_CORE_SVRCONNED",
--             fn = function(conn, pk)
--                 local data = proto_map.decode_ReqServerConned(pk:data())
--                 dump(data, "ReqServerConned")
--             end
--         },
--         [0x0003] = {
--             name = "SUB_CORE_SVRCLOSED",
--             fn = function(conn, pk)
--                 local data = proto_map.decode_ReqServerClosed(pk:data())
--                 dump(data, "ReqServerClosed")
--             end
--         }
--     }
-- }

-- function test_ws_client(scheme, host)
--     local client = ws:new()

--     client:connect(scheme, host, "")
--     client:handleMessage(
--         function(conn, pk)
--             local msgmap = msgs_switch[pk:mid()][pk:sid()]
--             if msgmap then
--                 if msgmap.fn ~= nil then
--                     skynet.fork(msgmap.fn, self, pk)
--                 end
--             else
--                 print("<: pk", "mid=" .. pk:mid() .. ", sid=" .. pk:sid() .. "命令未实现")
--             end
--         end
--     )

--     client:handleError(
--         function(err)
--             skynet.error(err)
--         end
--     )

--     local content =
--         proto_map.encode_ReqRegService(
--         {
--             serverId = 0,
--             svrType = 6
--         }
--     )

--     client:registerService(
--         0x0001,
--         0x0001,
--         0,
--         content,
--         function(conn, pk)
--             local data = proto_map.decode_AckRegService(pk:data())
--             dump(data, "AckRegService")
--             if data.result == 0 then
--                 print("服务注册成功", "result=" .. data.result, "serverId=" .. data.serverId, "errmsg=" .. data.errmsg)
--             end
--         end
--     )
-- end

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

        local db = skynet.newservice("mydb")
        local ret = skynet.call(db, "lua", "start")
        if ret ~= 0 then
            skynet.error("mydb server init fail")
            return
        end

        local wsserve = skynet.newservice("ws_server")
        local ret, err = skynet.call(wsserve, "lua", "start", 9948)
        print(ret, err or "success")
        if ret == 0 then
            -- WSService.service = skynet.newservice("ws_client")
            -- WSService.send("start", "ws", "192.168.0.105:9948")
            -- WSService.send("start", "ws", "47.97.66.156:8850")
            
            for i = 0, 1 do
                skynet.sleep(10)
                -- skynet.fork(test_ws_client, "ws", "192.168.0.105:9948")

                local c = skynet.newservice("ws_client")
                skynet.send(c, "lua", "start", "ws", "192.168.0.105:9948")
            end
        end
    end
)