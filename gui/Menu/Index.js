console.log("LOAD JS")

window.addEventListener('message', event => {
    event = event.data
    if(!event.index) return

    $('.menu').show()
    event.index -= 1

    let button = $('.menu .buttons #'+(item.index).toString())
    button.css({
        color: item.color
    })

    $('#'+(item.index).toString()).scrollIntoView()

    let next = $('.menu .buttons #'+(item.index-1).toString())
    let down = $('.menu .buttons #'+(item.index+1).toString())
    let teleport = $('.menu .buttons #'+(item.oldIndex-1).toString())
    
    let data = {color: '#ffffff'}
    
    if (item.method == 'up') next.css(data)
    else if (item.method == 'down') down.css(data)
    else if (item.method == 'teleport') teleport.css(data)
})

window.addEventListener('message', event => {
    console.log("HEJ")
    event = event.data
    if(event.type != "menu") return console.log("NO MENU")
    if(!event.show) return $('.menu').css({
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