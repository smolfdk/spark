const ws = require('ws')

// Export the Socket function, so that it can be ran from Lua
global.exports('Socket', (url, open, message, error, close) => {
    let client = new ws(url) // Create a new websocket

    client.on('open', () => open((data) => client.send(data), () => client.close()))
    client.on('message', (msg) => message(msg.toString()))
    client.on('error', error)
    client.on('close', close)
})