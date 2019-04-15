$(document).on('turbolinks:load', () => {
    let usersModal = () => {

        let modal = document.getElementById('add-request');

        $('#add-request-btn').click(() => {
            $('#add-request').modal('show')
        })

        $('.close').click(() => {
            modal.style.display = "none";
        })
    }

    usersModal()
})