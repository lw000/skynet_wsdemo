local skynet = require("skynet")
local service = require("skynet.service")
local packet = require("network.packet")

local WSClient = class("WSClient")

function WSClient:ctor()
    self._websocket = require "http.websocket"
    self._scheme = ""
    self._host = ""
    self._path = ""
    self._heartbeattime = 10
    self._timeout = 10
    self._serverId = 0
    self._msgswitch = {}
    self._onMessage = nil
    self._onError = nil
    self:reset()
end

function WSClient:connect(scheme, host, path, heartbeattime)
    assert(type(scheme) == "string", "scheme must is string")
    assert(type(host) == "string", "host must is string")

    path = path or ""
    assert(type(path) == "string", "path must is string")

    heartbeattime = heartbeattime or 10
    assert(type(heartbeattime) == "number", "heartbeattime must is string")

    self._scheme = scheme
    self._host = host
    self._path = path

    if self._heartbeattime ~= heartbeattime then
        self._heartbeattime = heartbeattime
    end

    local url = string.format("%s://%s/%s", self._scheme, self._host, self._path)
    skynet.error("connect to ", url)

    self._wsid = self._websocket.connect(url, nil, self._timeout)
    skynet.error(">: self._wsid=" .. self._wsid)

    self._open = true

    skynet.fork(
        function(...)
            while self._open do
                skynet.sleep(100)
                local now = os.date("*t")
                -- dump(now, "当前时间")
                -- print("当前时间", os.date("%Y-%m-%d %H:%M:%S", os.time(now)))

                if math.fmod(now.sec, self._heartbeattime) == 0 then
                    self:send(
                        0x0000,
                        0x0000,
                        nil,
                        function(conn, data)
                            print("心跳", os.date("%Y-%m-%d %H:%M:%S", os.time()))
                        end
                    )
                -- self:send(0x0000, 0x0000, nil)
                end
            end
        end
    )

    skynet.fork(
        function(...)
            self:run()
        end
    )
end

function WSClient:registerService(mid, sid, serverId, content, fn)
    if not self._open then
        skynet.error("websocket is closed")
        return 1
    end
    self._serverId = serverId
    self:send(mid, sid, content, fn)
end

function WSClient:send(mid, sid, content, fn)
    if not self._open then
        skynet.error("websocket is closed")
        return 1
    end

    if fn then
        local mids = self._msgswitch[mid]
        if mids == nil then
            mids = {}
            self._msgswitch[mid] = mids
        end

        local sids = mids[sid]
        if sids == nil then
            sids = {}
        end
        sids.fn = fn
        mids[sid] = sids
    end

    local pk = packet:new()
    pk:pack(mid, sid, self._wsid, content)
    if pk:data() == nil then
        skynet.error("data is nil")
        return 1
    end

    self._websocket.write(self._wsid, pk:data(), "binary", 0x02)

    return 0
end

function WSClient:open()
    return self._open
end

function WSClient:reset()
    self._open = false
    self._wsid = -1
end

function WSClient:handleMessage(fn)
    if not self._open then
        skynet.error("websocket is closed")
        return 1
    end
    self._onMessage = fn or function(conn, pk)
            skynet.error("<: ", "mid=" .. pk:mid(), "sid=" .. pk:sid(), "clientId=" .. pk:clientId(), "默认·消息·函数")
        end
    return 0
end

function WSClient:handleError(fn)
    if not self._open then
        return 1
    end
    self._onError = fn or function(err)
            skynet.error(err, "默认·错误处理·函数")
        end
    return 0
end

function WSClient:run()
    skynet.error("websocket running")

    while self._open do
        local resp, close_reason = self._websocket.read(self._wsid)
        skynet.error("<:", (resp and resp or "[Close] " .. close_reason))
        if not resp then
            skynet.error("server close")
            break
        end

        local pk = packet:new()
        pk:unpack(resp)

        skynet.error(
            "<: client",
            "ver=" .. pk:ver(),
            "mid=" .. pk:mid(),
            "sid=" .. pk:sid(),
            "checkCode=" .. pk:checkCode(),
            "clientId=" .. pk:clientId(),
            "dataLen=" .. string.len(pk:data())
        )

        local mids = self._msgswitch[pk:mid()]
        if mids then
            local sids = mids[pk:sid()]
            if sids then
                skynet.fork(sids.fn, self, pk)
            else
                if self._onMessage then
                    skynet.fork(self._onMessage, self, pk)
                end
            end
        else
            if self._onMessage then
                skynet.fork(self._onMessage, self, pk)
            end
        end
    end

    self:reset()

    skynet.error("websocket exit")
end

function WSClient:close()
    self._websocket.close(self._wsid)
    self:reset()
end

return WSClient
