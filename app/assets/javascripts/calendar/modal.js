// !TECHDEBT rewrite this jibberish

$(document).on('turbolinks:load', function () {
    // when a post is clicked show a modal
    function renderModal() {
        $('body').on('click', '.calendar-date', async function (e) {
            const calendarDates = await getDates();

            let current_price = {}
            calendarDates.forEach(el => {
                if (el.date == e.target.id) {
                    if (el.current_price == null) {
                        el.current_price = 1
                    }
                    return current_price = el;
                }
            })

            let currentCost = current_price.current_price
            console.log(current_price)
            let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button >'

            $('.modal-header').html("New Request for " + e.target.id + closeButton)
            console.log(e.target.id)

            $('.request-total').html(`total: ${currentCost * 8}`)
            $('.calendarModal').modal('show');
            $('#pto_request_request_date').attr("value", e.target.id)
            $('#pto_request_cost').attr("value", currentCost * 8)
            $('.btn-default').click(function () {
                $('.calendarModal').modal('hide')
            })
        })
    }

    renderModal()
})