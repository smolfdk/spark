const { createPool } = require('mysql2')

// Export the Connect function, this can be ran from Lua
global.exports('Connect', (options, response) => {
    let connection = createPool(options)
    let invoke = (cb, ...args) => setImmediate(() => cb(...args))

    // Get the connection
    connection.getConnection((err, con) => {
        if (err) return invoke(response, err.code)

        // Return the "execute query" function back to lua
        invoke(response, (sql, params) => {
            return new Promise((res, rej) => con.query(sql, params, (error, result) => {
                if (error) return rej(error)
                res(result) 
            }))
        }, (sql, params) => {
            return new Promise((res, rej) => con.execute(sql, params, (error, result, fields) => {
                if (error) return rej(error)

                res({
                    result: result,
                    fields: fields
                })
            }))
        })
        
        // Release the connection
        con.release()
    })
})