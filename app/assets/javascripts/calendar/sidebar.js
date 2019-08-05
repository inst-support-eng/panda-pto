openYear = (event, year) => {
    let tabContent = document.getElementsByClassName('tabContent')
    let yearButtons = document.getElementsByClassName('yearButtons')
    let nextYearButton = document.getElementById('nextYearButton')
    let currentYearButton = document.getElementById('currentYearButton')

    for (let i = 0; i < tabContent.length; i++) {
      tabContent[i].style.display = 'none'
    }

    for (let i = 0; i < yearButtons.length; i++) {
      yearButtons[i].className = yearButtons[i].className.replace(' active', '')
    }

    year.style.display = 'block'
    event.currentTarget.className += ' active'
    if (year.id == 'nextYearTable') {
      let month = document.getElementById('month-name').innerText.split(' ')[0]
      createCalendar(new Date().getFullYear() + 1, 0)
      currentYearButton.style.background = 'inherit'
      nextYearButton.style.background = '#222629'

    }
    if (year.id == 'currentYearTable') {
      let today = new Date()
      createCalendar(today.getFullYear(), today.getMonth())
      nextYearButton.style.background = 'inherit'
      currentYearButton.style.background = '#222629'
    }
  }
