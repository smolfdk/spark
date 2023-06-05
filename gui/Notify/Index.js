window.addEventListener('message', event => {
    let item = event.data
    let data = item.data
    if(item.type != "notify" || item.action != "new") return

    let element = $(`
        <div class="notification">
            <p class="text">${data.text}</p>
        </div>
    `).appendTo('.notify')

    element.hide().fadeIn('slow').css({
        border: '3px solid ' + data.color
    })

    setTimeout(() => element.fadeOut('slow', () => element.remove()), 3000)
})