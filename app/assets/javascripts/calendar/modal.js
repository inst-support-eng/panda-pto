// !TECHDEBT rewrite this jibberish

$(document).on('turbolinks:load', function () {
    // when a post is clicked show a modal
    function renderModal() {
        $('body').on('click', '.calendar-date', async function (e) {
            const calendarDates = await getDates();

            let current_price = {}
            calendarDates.forEach(el => {
                if (el.date == e.target.id) {
                    return current_price = el;
                }
            })
            console.log(current_price)
            let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button >'

            $('.modal-header').html("New Request for " + e.target.id + closeButton)
            console.log(e.target.id)

            $('.request-total').html(`total: ${current_price.current_price * 8}`)
            $('.calendarModal').modal('show');
            $('#pto_request_request_date').attr("value", e.target.id)
            $('.btn-default').click(function () {
                $('.calendarModal').modal('hide')
            })
        })
    }

    renderModal()
})