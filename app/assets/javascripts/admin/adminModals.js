/**
 * displays modals on admin_path
 */
$(document).on('turbolinks:load', () => {
  adminModal = () => {
    let modal = document.getElementById('upload-users');
    let modal2 = document.getElementById('upload-values');
    let modal3 = document.getElementById('upload-requests');
    let modal4 = document.getElementById('adjust-calendar-cost')

    let span = document.getElementsByClassName("close2")[0];
    let span2 = document.getElementsByClassName("close2")[1];
    let span3 = document.getElementsByClassName("close2")[2];
    let span4 = document.getElementsByClassName("close2")[3];

    $("#users-csv").click(() => {
      modal.style.display = "block";
    })

    $("#values-csv").click(() => {
      modal2.style.display = "block";
    })

    $("#pto-csv").click(() => {
      modal3.style.display = "block";
    })

    $("#adjust-calendar-cost-btn").click(() => {
      modal4.style.display = "block";
    })

    $(span).click(() => {
      modal.style.display = "none"
    })
    $(span2).click(() => {
      modal2.style.display = "none";
    })
    $(span3).click(() => {
      modal3.style.display = "none";
    })
    $(span4).click(() => {
      modal4.style.display = "none";
    })

    window.onclick = function (event) {
      if (event.target == modal) {
        modal.style.display = "none";
      } else if (event.target == modal2) {
        modal2.style.display = "none";
      } else if (event.target == modal3) {
        modal3.style.display = "none";
      } else if (event.target == modal4) {
        modal4.style.display = "none";
      }
    }
  }

  adminModal();
})