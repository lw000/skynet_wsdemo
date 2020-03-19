# skynet_wsdemo
skyent websocket 测试

# 概要
    1. main.lua 程序入口
    2. ws_server websocket服务
    3. ws_client 模拟客户端
    
# 代码结构
#### .
#### ├── common
#### │   ├── core.lua
#### │   ├── dump.lua
#### │   ├── export.lua
#### │   ├── function.lua
#### │   ├── trackback.lua
#### │   └── utils.lua
#### ├── config
#### │   └── config.lua
#### ├── main.lua
#### ├── network
#### │   ├── packet.lua
#### │   └── ws.lua
#### ├── proto_map
#### │   └── proto_map.lua
#### ├── testpk.lua
#### ├── ws_client
#### │   └── ws_client.lua
#### └── ws_server
####     ├── agent.lua
####     └── ws_server.lua
#### 