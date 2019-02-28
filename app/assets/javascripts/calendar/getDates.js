// gets all calendar dates from rails 
// used in calendar and modal

async function getDates() {
    const response = await fetch('/calendars/fetch_dates')
    return await response.json()
}