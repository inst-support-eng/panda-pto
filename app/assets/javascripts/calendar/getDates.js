// gets all calendar dates from rails 
// used in calendar and modal

getDates = async () => {
    const response = await fetch('/calendars/fetch_dates')
    return await response.json()
}