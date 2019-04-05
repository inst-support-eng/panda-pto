// !TECHDEBT rewrite && comment this whole thing to be readable 

 $(document).on('turbolinks:load', function () {
    let gridTable = document.getElementById("table-body");
    let currentDate = new Date();
    let selectedDate = currentDate;
    let selectedDayBlock = null;

    async function createCalendar(date, side) {

        let calendarDates = await getDates()
        let currUser = await currentUser()

        let currentDate = date;
        let startDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);

        let monthTitle = document.getElementById("month-name");
        let monthName = currentDate.toLocaleString("en-US", {
            month: "long"
        });
        let yearNum = currentDate.toLocaleString("en-US", {
            year: "numeric"
        });
        monthTitle.innerHTML = `${monthName} ${yearNum}`;

        if (side == "left") {
            gridTable.className = "animated fadeOutRight";
        } else {
            gridTable.className = "animated fadeOutLeft";
        }

        gridTable.innerHTML = "";

        let newRow = document.createElement("tr");
        let currentRow = gridTable.appendChild(newRow);

        for (let i = 1; i < startDate.getDay(); i++) {
            let emptyDivCol = document.createElement("td");
            currentRow.appendChild(emptyDivCol);
        }

        let lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        lastDay = lastDay.getDate();

        let addNewRow =() => {
            let row = document.createElement("tr");
            return row;
        }
         
        for (let i = 0; i <= lastDay; i++) {
            if (currentRow.getElementsByTagName("td").length >= 7) {
                currentRow = gridTable.appendChild(addNewRow());
            }
            let currentDay = document.createElement("td");
            currentDay.setAttribute("class", "calendar-date")
            console.log(currentDay)
            let dayId = i+1;
            if (dayId < 10) { dayId = '0' + i }
            let monthId = parseInt(currentDate.getMonth() + 1)
            if (monthId < 10) { monthId = '0' + monthId }

            let reqDate = `${currentDate.getFullYear()}-${monthId}-${dayId}`

            let reqData = {}
            
            calendarDates.forEach(el => {
                if (el.date == reqDate) {
                    if (el.current_price == null) {
                        el.current_price = 1
                    }
                    return reqData = el
                }
            })

            currentDay.setAttribute("id", reqDate)
            if (selectedDayBlock == null && i == currentDate.getDate() || selectedDate.toDateString() == new Date(currentDate.getFullYear(), currentDate.getMonth(), i).toDateString()) {
                selectedDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), i);

                document.getElementById("eventDayName").innerHTML = selectedDate.toLocaleString("en-US", {
                    month: "long",
                    day: "numeric",
                    year: "numeric"
                });

                selectedDayBlock = currentDay;
                setTimeout(() => {
                    currentDay.classList.add("blue");
                    currentDay.classList.add("lighten-3");
                }, 900);
            }

            // display 8 / 10 hour costs for day
            let displayCost = `<div id="pto-cost">total: ₢ ${reqData.current_price * 8}</div>`;
            if (currUser.ten_hour_shift) {
                displayCost = `<div id="pto-cost">total: ₢ ${reqData.current_price * 10}</div>`;
            } 

            // check if day has current_price
            if(isNaN(reqData.current_price)) {
                displayCost = `<div id="pto-cost">??</div>`
            }
            let displayInfo = `<div id="pto-date">${i}</div><br/>${displayCost}`

            currentDay.innerHTML = displayInfo;
            currentRow.appendChild(currentDay);
        }

        for (let j = currentRow.getElementsByTagName("td").length; j < 7; j++) {
            let emptyDivCol = document.createElement("td");
            currentRow.appendChild(emptyDivCol);
        }

        setTimeout(() => {
            if (side == "left") {
                gridTable.className = "animated fadeInLeft";
            } else {
                gridTable.className = "animated fadeInRight";
            }
        }, 270);
    }

    createCalendar(currentDate);

    let prevButton = document.getElementById("prev");
    let nextButton = document.getElementById("next");

    let changeMonthPrev = () => {
        currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1);
        createCalendar(currentDate, "left");
    }
    let changeMonthNext = () => {
        currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1);
        createCalendar(currentDate, "right");
    }

    prevButton.onclick = changeMonthPrev;
    nextButton.onclick = changeMonthNext;
});
