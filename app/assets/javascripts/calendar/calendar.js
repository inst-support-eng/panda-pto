/**
 * This js loads the calendar for users to request time off with
 */

createCalendar = async (year, month) => {

  let selectYear = document.getElementById("year")
  let selectMonth = document.getElementById("month")

  let monthAndYear = document.getElementById("month-name")

  let calendarDates = await getDates()
  let currUser = await currentUser()

  // get and sort requested dates for users
  let userDates = currUser.pto_requests
  userDates.sort((a, b) => (a.request_date > b.request_date) ? 1 : -1)

  // this will be used for if / when we use the app for different positions PTO
  // switch (currUser.position) {
  //     case "L1":
  //         calendarDates = await getDates()
  //         break
  //     case "L2":
  //         calendarDates = await getL2Dates()
  //         break
  //     case "L3":
  //         calendarDates = await getL3Dates()
  //         break
  //     case "Sup":
  //         calendarDates = await getSupDates()
  //         break
  //     default:
  //         calendarDates = await getDates()
  //         break
  // }

  let firstDay = new Date(year, month).getDay()

  let tbl = document.getElementById("table-body")
  tbl.innerHTML = ""

  monthAndYear.innerHTML = `${month} ${year}`
  selectYear.value = year
  selectMonth.value = month

  //create all the cells
  let date = 1
  for (let i = 0; i < 6; i++) {
    // create row
    let row = document.createElement("tr")

    // create ind cells
    for (let j = 0; j < 7; j++) {
      if (i === 0 && j < firstDay) {
        cell = document.createElement("td")
        cellText = document.createTextNode("")
        cell.appendChild(cellText)
        row.appendChild(cell)
      } else if (date > getDaysInMonth(year, month)) {
        break
      } else {
        cell = document.createElement("td")
        cellText = document.createTextNode(date)

        cell.append(cellText)
        cell.setAttribute("class", "calendar-date")

        let dayId = date
        let monthId = month + 1

        if (dayId < 10) {
          dayId = `0${date}`
        }

        if (monthId < 10) {
          monthId = `0${monthId}`
        }

        let reqDate = `${year}-${monthId}-${dayId}`

        let reqData = {}

        calendarDates.forEach(el => {
          if (el.date == reqDate) {
            if (el.current_price == null) {
              el.current_price = 1
            }
            return reqData = el
          }
        })

        // places the date from the calendar to be the id for request dates
        cell.setAttribute("id", reqDate)

        // display 8 / 10 hour costs for day
        let displayCost = `<div id="pto-cost">total: ₢ ${reqData.current_price * 8}</div>`
        if (currUser.ten_hour_shift) {
          displayCost = `<div id="pto-cost">total: ₢ ${reqData.current_price * 10}</div>`
        }

        // check if day has current_price
        if (isNaN(reqData.current_price)) {
          displayCost = `<div id="pto-cost">??</div>`
        }

        // grey out old dates 
        if ((year <= today.getFullYear() && month < today.getMonth()) || (date < today.getDate() && year <= today.getFullYear() && month <= today.getMonth())) {
          cell.classList.add('grey')
        }

        // check to see if the user has the days off
        let hasOff = userDates.filter(date => {
          return date.request_date == reqDate
        })

        if (hasOff.length == 1) {
          cell.classList.add('day-off')
        }

        // color todays date
        if (date == today.getDate() && year == today.getFullYear() && month == today.getMonth()) {
          cell.classList.add("blue")
        }

        let displayInfo = `<div id="pto-date">${date}</div><br/>${displayCost}`
        cell.innerHTML = displayInfo

        row.appendChild(cell)

        date++
      }
    }
    tbl.appendChild(row)
  }
}

// get last day of month
getDaysInMonth = (year, month) => {
  return 32 - new Date(year, month, 32).getDate()
}

next = () => {
  let nextYear = (currentMonth === 11) ? currentYear + 1 : currentYear
  let nextMonth = (currentMonth + 1) % 12
  if (nextYear == today.getFullYear() + 1) {
    let year = document.getElementById('nextYearTable')
    openYear(event, year)
    createCalendar(nextYear, nextMonth)
  }
  if (nextYear == today.getFullYear()) {
    let year = document.getElementById('currentYearTable')
    openYear(event, year)
    createCalendar(nextYear, nextMonth)
  }
  currentYear = nextYear
  currentMonth = nextMonth
}

previous = () => {
  let prevYear = (currentMonth === 0) ? currentYear - 1 : currentYear
  let prevMonth = (currentMonth === 0) ? 11 : currentMonth - 1

  if (prevYear == today.getFullYear() + 1) {
    let year = document.getElementById('nextYearTable')
    openYear(event, year)
    createCalendar(prevYear, prevMonth)
  }
  if (prevYear == today.getFullYear()) {
    let year = document.getElementById('currentYearTable')
    openYear(event, year)
    createCalendar(prevYear, prevMonth)
  }
  currentYear = prevYear
  currentMonth = prevMonth
}

jump = () => {
  let jumpYear = parseInt(selectYear.value)
  let jumpMonth = parseInt(selectMonth.value)

  if (jumpYear == today.getFullYear() + 1) {
    let year = document.getElementById('nextYearTable')
    openYear(event, year)
    createCalendar(jumpYear, jumpMonth)
  }
  if (jumpYear == today.getFullYear()) {
    let year = document.getElementById('currentYearTable')
    openYear(event, year)
    createCalendar(jumpYear, jumpMonth)
  }

  currentYear = jumpYear
  currentMonth = jumpMonth
}