$(document).on('turbolinks:load', () => {
    usersModal = () => {
        let requestModal = document.getElementById('add-request');
        let noCallModal = document.getElementById('add-no-call-show');

        $('#add-request-btn').click(() => {
            requestModal.style.display = "block";
        })

        $('#add-no-call-show-btn').click(() => {
            noCallModal.style.display = "block";
        })

        $('.close').click(() => {
            requestModal.style.display = "none";
            noCallModal.style.display = "none";
        })
    }

    usersModal()
})