// !TECHDEBT rewrite this jibberish

$(document).on('turbolinks:load', function () {
    // when a post is clicked show a modal
    function renderModal() {
        $('body').on('click', '.calendar-date', async function (e) {
            const calendarDates = await getDates();
            const currUser = await currentUser();

            let current_price = {}
            calendarDates.forEach(el => {
                if (el.date == e.target.id) {
                    if (el.current_price == null) {
                        el.current_price = 1
                    }
                    return current_price = el;
                }
            })

            // prevents old dates from being selectable
            requestDate = new Date(e.target.id)
            requestDate.setHours(0)
            requestDate.setMinutes(00)
            requestDate.setSeconds(00)
            requestDate.setDate(requestDate.getDate()+1)

            currentDate = new Date()
            currentDate.setHours(0)
            currentDate.setMinutes(00)
            currentDate.setSeconds(00)

            console.log(requestDate > currentDate)
            
            if(requestDate.toDateString() == currentDate.toDateString()) {                
                $('.dayOfModal').modal('show');
            }

            if (requestDate > currentDate && requestDate.getMonth()-currentDate.getMonth() <= 9 && !isNaN(current_price.current_price)) {
                $('.calendarModal').modal('show');
                let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button >'
                let displayCost = current_price.current_price * 8;
                if (currUser.ten_hour_shift) {
                    displayCost = current_price.current_price * 10;
                }

                $('.modal-header').html("New Request for " + e.target.id + closeButton)
                $('.request-total').html(`total: ${displayCost}`)
                $('#pto_request_request_date').attr("value", e.target.id)
                $('#pto_request_cost').attr("value", displayCost)
            }
  
            $('.btn-default').click(function () {
                $('.calendarModal').modal('hide')
                $('.dayOfModal').modal('hide')
            })
        })
    }

    renderModal()
})
