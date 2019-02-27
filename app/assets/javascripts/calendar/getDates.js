// gets all calendar dates from rails 
async function getDates() {
    const response = await fetch('/calendars/fetch_dates')
    return await response.json()
}