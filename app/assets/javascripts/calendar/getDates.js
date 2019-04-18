// gets all calendar dates from rails 
// used in calendar and modal

let getDates = async () => {
    const response = await fetch('/calendars/fetch_dates')
    return await response.json()
}

let getL2Dates = async () => {
    const response = await fetch('calendars/l2_fetch_dates')
    return await response.json()
}

let getL3Dates = async () => {
    const response = await fetch('calendars/l3_fetch_dates')
    return await response.json()
}

let getSupDates = async () => {
    const response = await fetch('calendars/sups_fetch_dates')
    return await response.json()
}