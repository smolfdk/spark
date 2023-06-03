window.addEventListener('message', event => {
    event = event.data
    if (event.type != "notify") return
    let element = $(`
        <div class="notification">
            <p class="text">${event.brow}</p>
        </div>
    `).appendTo('.notify')

    element.hide().fadeIn('slow').css({
        border: '3px solid ' + event.color
    })

    console.log("New notifiaction")
    setTimeout(() => element.fadeOut('slow', () => element.remove()), 3000)
})