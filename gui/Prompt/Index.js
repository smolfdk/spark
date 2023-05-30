let Open = false
let Prompt = (type, data) => Send(type, data).then(() => {
    $('.prompt').hide()
    $('.prompt .input').val('')
})

$(document).ready(() => {
    $('.cancel').click(() => Prompt('cancel', {}))
    $('.submit').click(() => Prompt('submit', {
        text: $('.prompt .input').val()
    }))

    $(document).keyup(e => {
        if(!Open) return
        let type = "cancel", data = {}
        if (e.key != "Enter" && e.key != "Escape") return
        if (e.key == "Enter") {
            type = "submit", data = {
                text: $('.prompt .input').val()
            }
        } 

        Prompt(type, data)
    })
})

window.addEventListener('message', event => {
    event = event.data
    if(event.type != "prompt") return
    if(event.show == false) {
        Open = false
        return $('.prompt').css({
            display: 'none'
        })
    }

    Open = true
    $('.prompt').show()
    $('.prompt .title').text(event.text)
    $('.prompt .input').css({
        "font-size": event.size
    }).focus()
    console.log("Init prompt")
})