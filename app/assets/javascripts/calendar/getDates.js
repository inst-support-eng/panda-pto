// gets all calendar dates from rails 
// used in calendar and modal

getDates = async () => {
    const response = await fetch('/calendars/fetch_dates')
    return await response.json()
}

getL2Dates = async () => {
    const response = await fetch('calendars/l2_fetch_dates')
    return await response.json()
}

getL3Dates = async () => {
    const response = await fetch('calendars/l3_fetch_dates')
    return await response.json()
}

getSupDates = async () => {
    const response = await fetch('calendars/sups_fetch_dates')
    return await response.json()
}