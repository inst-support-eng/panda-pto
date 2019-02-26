async function getDates() {
    const response = await fetch('/calendars/fetch_dates')
    return await response.json()
}