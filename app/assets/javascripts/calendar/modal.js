/**
 * loads / displays modals on calendar
 */
$(document).on('turbolinks:load', () => {
    // when a post is clicked show a modal
    renderModal = () => {
        $('body').on('click', '.calendar-date', async (e) => {
            const calendarDates = await getDates()
            const currUser = await currentUser()
            let userDates = currUser.pto_requests

            userDates.sort((a, b) => (a.request_date > b.request_date) ? 1 : -1)

            // check to see if the user has the days off
            let hasOff = userDates.filter(date => {
                return date.request_date == e.target.id
            })

            // get modals from calendar partial
            const hasOffModal = document.getElementById('hasOffModal')
            const pipModal = document.getElementById('pipModal')
            const calendarModal = document.getElementById('calendarModal')
            const dayOfModal = document.getElementById('dayOfModal')
            const notEnoughCreditsModal = document.getElementById('notEnoughCreditsModal')

            let current_price = {}
            calendarDates.forEach(el => {
                if (el.date == e.target.id) {
                    if (el.current_price == null) {
                        el.current_price = 1
                    }
                    return current_price = el
                }
            })

            // prevents old dates from being selectable
            requestDate = new Date(e.target.id)
            requestDate.setHours(0)
            requestDate.setMinutes(00)
            requestDate.setSeconds(00)
            requestDate.setDate(requestDate.getDate() + 1)

            currentDate = new Date()
            currentDate.setHours(0)
            currentDate.setMinutes(00)
            currentDate.setSeconds(00)

            if (requestDate.toDateString() == currentDate.toDateString()) {
                if (currUser.on_pip == true) {
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'
                    $('.modal-header').html(closeButton)
                    pipModal.style.display = "block"
                } else if (hasOff.length == 1) {
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'
                    $('.modal-header').html(closeButton)
                    hasOffModal.style.display = "block"
                } else {
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'
                    $('.modal-header').html(closeButton)
                    dayOfModal.style.display = "block"
                }
            }

            if (requestDate > currentDate && requestDate.getMonth() - currentDate.getMonth() <= 7 && !isNaN(current_price.current_price)) {
                let requestQuarter = document.getElementById(getQuarter(requestDate)).innerHTML

                let displayCost = current_price.current_price * 8
                if (currUser.ten_hour_shift) {
                    displayCost = current_price.current_price * 10
                }

                if (currUser.on_pip == true) {
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'
                    $('.modal-header').html(closeButton)
                    pipModal.style.display = "block"
                } else if (hasOff.length == 1) {
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'
                    $('.modal-header').html(closeButton)
                    hasOffModal.style.display = "block"
                } else if(requestQuarter - displayCost  < 0) {
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'
                    $('.modal-header').html(closeButton)
                    notEnoughCreditsModal.style.display = "block"
                } else {
                    calendarModal.style.display = "block"
                    let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times</span></button >'

                    $('.modal-header').html("New Request for " + e.target.id + closeButton)

                    $('.request-total').html(`Request Total: ${displayCost}`)
                    $('.bank-total').html(`Quarter Bank Total : ${requestQuarter}`)
                    $('#pto_request_request_date').attr("value", e.target.id)
                    $('#pto_request_cost').attr("value", displayCost)
                }
            }

            $('.close').click(() => {
                hasOffModal.style.display = "none"
                pipModal.style.display = "none"
                calendarModal.style.display = "none"
                dayOfModal.style.display = "none"
                notEnoughCreditsModal.style.display = "none"
            })
        })
    }

    renderModal()
})