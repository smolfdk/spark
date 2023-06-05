let Prompt = (type, data) => Send(type, data).then(() => {
    $('.prompt').hide()
    $('.prompt .input').val('')
})

$(document).ready(() => {
    $('.cancel').click(() => Prompt('Prompt:Cancel', {}))
    $('.submit').click(() => Prompt('Prompt:Submit', {
        text: $('.prompt .input').val()
    }))
})

window.addEventListener('message', event => {
    let item = event.data
    let data = item.data
    if(item.type != "prompt" || item.action != "show") return

    $('.prompt').show()
    $('.prompt .title').text(data.text)
    $('.prompt .input').css({
        "font-size": data.size
    }).focus()
})