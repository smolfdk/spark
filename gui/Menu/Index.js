let Menu = false
let Data = ["0", "1", "2", "3", "4"]
let Index = 0
let Color = '#EF5064'
let Last

let Update = () => {
    let string = Index.toString()
    document.getElementById(string).scrollIntoView()
    let button = $('.menu .buttons #'+string)
    button.css({
        color: Color
    })

    if (Last) {
        Last.css({
            color: '#ffffff'
        })
    } else {
        $('.menu .button:first-child').css({
            color: '#ffffff'
        })
    }

    Last = button
}

$(document).ready(() => {
    $(document).keyup(e => {
        console.log(e.key)
        if (e.key == "ArrowUp") {
            if (Index == 0) {
                Index = Data.length-1
            } else {
                Index -= 1
            }
            Update()
        } else if (e.key == "ArrowDown") {
            if (Index == Data.length-1) {
                Index = 0
            } else {
                Index += 1
            }
            Update()
        } else if (e.key == "Backspace") {
            console.log("CLOSE")
        } else if (e.key == "Enter") {
            //Send('click', {
            //    button: Data[index]
            //})
            console.log("CLICK ON BUTTON "+Data[Index])
        }
    })
})


window.addEventListener('message', event => {
    event = event.data
    if(event.type != "menu") return
    if(event.show == false) {
        Menu = false
        return $('.menu').css({
            display: 'none'
        })
    }

    $('.menu').css({
        display: 'flex'
    })

    $('title').text(event.text).css({
        color: event.color
    })

    if (!event.list) return
    $('.buttons').empty()
    
    let index = event.list.length
    Data = event.list
    event.list.forEach(element => {
        index -= 1
        $('<div id="'+index.toString()+'" class="button">'+element+'</div>').appendTo('.buttons')
    })

    $('.menu .buttons #'+ (event.list.length-1).toString()).css({
        color: event.color
    })
})