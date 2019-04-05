$(document).on('turbolinks:load', () => {
    let today = new Date();
    let currentMonth = today.getMonth();
    let currentYear = today.getFullYear();

    let selectYear = document.getElementById("year");
    let selectMonth = document.getElementById("month");

    let monthAndYear = document.getElementById("month-name");

    let months = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let createCalendar = async (year, month) => {

        let calendarDates = await getDates()
        let currUser = await currentUser()

        let firstDay = new Date(year, month).getDay();

        let tbl = document.getElementById("table-body");
        tbl.innerHTML = "";

        monthAndYear.innerHTML = `${months[month]} ${year}`;
        selectYear.value = year;
        selectMonth.value = month;

        //create all the cells
        let date = 1;
        for (let i = 0; i < 6; i++) {
            // create row
            let row = document.createElement("tr")

            // create ind cells
            for (let j = 0; j < 7; j++) {
                if (i === 0 && j < firstDay) {
                    cell = document.createElement("td");
                    cellText = document.createTextNode("");
                    cell.appendChild(cellText);
                    row.appendChild(cell)
                } else if (date > getDaysInMonth(year, month)) {
                    break
                }
                else {
                    cell = document.createElement("td");
                    cellText = document.createTextNode(date);

                    cell.append(cellText);
                    cell.setAttribute("class", "calendar-date")

                    let dayId = date;
                    let monthId = month+1;
                    
                    if (dayId < 10) { dayId = `0${date}` } 

                    if (monthId < 10) { monthId = `0${monthId}` }

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

                    cell.setAttribute("id", reqDate)

                    // display 8 / 10 hour costs for day
                    let displayCost = `<div id="pto-cost">total: ₢ ${reqData.current_price * 8}</div>`;
                    if (currUser.ten_hour_shift) {
                        displayCost = `<div id="pto-cost">total: ₢ ${reqData.current_price * 10}</div>`;
                    }

                    // check if day has current_price
                    if (isNaN(reqData.current_price)) {
                        displayCost = `<div id="pto-cost">??</div>`
                    }

                    // color todays date
                    if (date == today.getDate() && year == today.getFullYear() && month == today.getMonth()) {
                        cell.classList.add("blue");
                        cell.classList.add("lighten-3");
                    }

                    let displayInfo = `<div id="pto-date">${date}</div><br/>${displayCost}`
                    cell.innerHTML = displayInfo;

                    row.appendChild(cell);

                    date++;

                }
            }
            tbl.appendChild(row)
        }
    }

    // get last day of month
    let getDaysInMonth = (year, month) => {
        return 32 - new Date(year, month, 32).getDate();
    }

    let next = () => {
        currentYear = (currentMonth === 11) ? currentYear + 1 : currentYear;
        currentMonth = (currentMonth + 1) % 12;
        createCalendar(currentYear, currentMonth);
    }

    let previous = () => {
        currentYear = (currentMonth === 0) ? currentYear - 1 : currentYear;
        currentMonth = (currentMonth === 0) ? 11 : currentMonth - 1;
        createCalendar(currentYear, currentMonth);

    }

    let jump = () => {
        currentYear = parseInt(selectYear.value);
        currentMonth = parseInt(selectMonth.value);
        createCalendar(currentYear, currentMonth)
    }

    let prevButton = document.getElementById("prev");
    let nextButton = document.getElementById("next");
    let jumpButton = document.getElementById("jump");

    prevButton.onclick = previous;
    nextButton.onclick = next;
    jumpButton.onclick = jump;

    createCalendar(currentYear, currentMonth);
})