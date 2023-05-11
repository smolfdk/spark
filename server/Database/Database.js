const { createPool } = require('mysql2')

global.exports('Connection', (options, response) => {
    let connection = createPool(options)
    let invoke = (cb, args) => setImmediate(() => cb(args))

    connection.getConnection((err, con) => {
        if (err) return invoke(response, err.code)
        
        invoke(response, (sql, params, cb) => {
            return new Promise((res, rej) => con.query(sql, params, (error, result) => {
                if (error) return rej(error)
                res(result) 
            }))
        })
        
        con.release()
    })
})