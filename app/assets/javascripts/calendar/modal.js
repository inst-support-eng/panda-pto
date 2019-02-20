$(document).on('turbolinks:load', function () {
    // when a post is clicked show a modal
    $('body').on('click', '.calendar-date', function (e) {
        let closeButton = '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button >'
        $('.modal-header').html("New Request for " + e.target.id + closeButton)
        console.log(e.target.id)
        $('.calendarModal').modal('show');

        $('.btn-default').click(function () {
            $('.calendarModal').modal('hide')
        })
    })
})


