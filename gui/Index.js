// Send a callback request back to Lua
async function Send(url, data) {
    return (
        await fetch(`https://${GetParentResourceName()}/${url}`, {
            method: "POST",
            headers: {
                "Content-Type": 'application/json; charset=UTF-8'
            },
            body: JSON.stringify(data) // Encode the data body into JSON
        })
    ).json() // Return the response in JSON format.
}