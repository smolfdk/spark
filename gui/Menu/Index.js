window.addEventListener('message', event => {
    let item = event.data
    let data = item.data
    if(item.type != "menu" || item.action != "open") return

    $('.menu').css({
        display: 'flex'
    })

    $('.title').text(data.text).css({
        color: data.color
    })

    $('.buttons').empty()
    let index = 0
    data.data.forEach(element => {
        index += 1

        $(`
            <div id="${index.toString()}" class="button">${element}</div>
        `).appendTo('.buttons')
    })

    $(`.menu .button:first-child`).css({
        "color": data.color,
        "margin-top": '30px'
    })
})

window.addEventListener('message', event => {
    let item = event.data
    if(item.type != "menu" || item.action != "close") return

    $('.menu').css({
        display: 'none'
    })
})

window.addEventListener('message', event => {
    let item = event.data
    let data = item.data
    if(item.type != "menu" || item.action != "update") return

    $('.buttons .button').each(function (index, element) {
        $(element).css({
            color: '#ffffff'
        })
    })

    $('.buttons #'+data.index.toString()).css({
        color: data.color
    })
})