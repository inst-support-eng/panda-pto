/**
 * loads modals for users_show_path
 */
$(document).on('turbolinks:load', () => {
    usersModal = () => {
        let requestModal = document.getElementById('add-request');
        let noCallModal = document.getElementById('add-no-call-show');
        let makeUpDayModal = document.getElementById('add-make-up-day');

        $('#add-request-btn').click(() => {
            requestModal.style.display = "block";
        })

        $('#add-no-call-show-btn').click(() => {
            noCallModal.style.display = "block";
        })

        $('#add-make-up-day-btn').click(() => {
            makeUpDayModal.style.display = "block";
        })

        $('.close').click(() => {
            requestModal.style.display = "none";
            noCallModal.style.display = "none";
            makeUpDayModal.style.display = "none";
        })
    }

    usersModal()
})