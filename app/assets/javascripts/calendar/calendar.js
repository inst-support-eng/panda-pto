// !TECHDEBT rewrite && comment this whole thing to be readable 

$('document').ready(function () {
    let calendar = document.getElementById("calendar-table");
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

        let newTr = document.createElement("tr");
        let currentTr = gridTable.appendChild(newTr);

        for (let i = 1; i < startDate.getDay(); i++) {
            let emptyDivCol = document.createElement("td");
            currentTr.appendChild(emptyDivCol);
        }

        let lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        lastDay = lastDay.getDate();

        for (let i = 1; i <= lastDay; i++) {
            if (currentTr.getElementsByTagName("td").length >= 7) {
                currentTr = gridTable.appendChild(addNewRow());
            }
            let currentDay = document.createElement("td");
            currentDay.setAttribute("class", "calendar-date")
            let dayId = i;
            if (i < 10) { dayId = '0' + i }
            let monthId = parseInt(currentDate.getMonth() + 1)
            if (monthId < 10) { monthId = '0' + monthId }

            let reqDate = currentDate.getFullYear() + "-" + monthId + "-" + dayId

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
            let displayCost = `<div id="pto-cost">${reqData.current_price * 8} </div>`;
            if (currUser.ten_hour_shift) {
                displayCost = `<div id="pto-cost">${reqData.current_price * 10}</div>`;
            } 
            if(isNaN(reqData.current_price)) {
                displayCost = `<div id="pto-cost">??</div>`
            }
            let displayInfo = `<div id="pto-date">${i}</div>` + "<br/> " + displayCost

            currentDay.innerHTML = displayInfo;
            currentTr.appendChild(currentDay);
        }

        for (let i = currentTr.getElementsByTagName("td").length; i < 7; i++) {
            let emptyDivCol = document.createElement("td");
            currentTr.appendChild(emptyDivCol);
        }

        setTimeout(() => {
            if (side == "left") {
                gridTable.className = "animated fadeInLeft";
            } else {
                gridTable.className = "animated fadeInRight";
            }
        }, 270);

        function addNewRow() {
            let node = document.createElement("tr");
            return node;
        }
    }

    createCalendar(currentDate);


    let todayDayName = document.getElementById("todayDayName");
    todayDayName.innerHTML = "Today is " + currentDate.toLocaleString("en-US", {
        weekday: "long",
        day: "numeric",
        month: "short"
    });

    let prevButton = document.getElementById("prev");
    let nextButton = document.getElementById("next");

    prevButton.onclick = changeMonthPrev;
    nextButton.onclick = changeMonthNext;

    function changeMonthPrev() {
        currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1);
        createCalendar(currentDate, "left");
    }
    function changeMonthNext() {
        currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1);
        createCalendar(currentDate, "right");
    }
})
