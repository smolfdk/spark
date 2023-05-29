window.addEventListener('message', event => {
    event = event.data
    if(event.type != "menu") return
    if(!event.index) return

    $('.menu').show()
    event.index -= 1

    let button = $('.menu .buttons #'+(event.index).toString())
    button.css({
        color: event.color
    })

    document.getElementById((event.index).toString()).scrollIntoView()

    let next = $('.menu .buttons #'+(event.index-1).toString())
    let down = $('.menu .buttons #'+(event.index+1).toString())
    let teleport = $('.menu .buttons #'+(event.oldIndex-1).toString())
    
    let data = {color: '#ffffff'}
    
    if (event.method == 'up') next.css(data)
    else if (event.method == 'down') down.css(data)
    else if (event.method == 'teleport') teleport.css(data)
})

window.addEventListener('message', event => {
    event = event.data
    if(event.type != "menu") return
    if(event.show == false) return $('.menu').css({
        display: 'none'
    })

    $('.menu').css({
        display: 'flex'
    })

    $('title').text(event.text).css({
        color: event.color
    })

    if (!event.list) return
    $('.buttons').empty()
    
    let index = event.list.length
    event.list.forEach(element => {
        index -= 1
        $('<div id="'+index.toString()+'" class="button">'+element+'</div>').appendTo('.buttons')
    })

    $('.menu .buttons #'+ (event.list.length-1).toString()).css({
        color: event.color
    })
})