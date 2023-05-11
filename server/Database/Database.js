const { createPool } = require('mysql2')

global.exports('Connection', (options, response) => {
    let connection = createPool(options)
    let invoke = (cb, args) => setImmediate(() => cb(args))

    connection.getConnection((err, con) => {
        if (err) invoke(response, err)
        
        invoke(response, (sql, params) => {
            return new Promise((res, rej) => con.query(sql, params, (error, result) => {
                if (error) return rej(error)
                res(result) 
            }))
        })
        
        connection.releaseConnection(con)
    })
})