/**
 * displays reset password modal from users profile
 */
$(document).on('turbolinks:load', () => {
    let editPassword = () => {
        var modal = document.getElementById('update-password');
        var span = document.getElementsByClassName("close2")[0];
        
        $('#reset-password-button').click(() => {
            modal.style.display = "block";
        })

        $(span).click(() => {
          modal.style.display = "none";
        })

        window.onclick = function(event) {
          if (event.target == modal) {
            modal.style.display = "none";
          }
        }
    }

    editPassword()
})