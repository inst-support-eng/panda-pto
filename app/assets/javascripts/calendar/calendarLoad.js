$(document).on('turbolinks:load',() => {
	$('.pages.index').ready(() => {
		console.log('also here')
		let today = new Date()
    let currentMonth = today.getMonth()
		let currentYear = today.getFullYear()

		let year = document.getElementById('currentYearTable')

		createCalendar(currentYear, currentMonth)
		openYear(event, year)

		$('#prev').click(() => {
			previous()
		})
		$('#next').click(() => {
			next()
		})
		$('#jump').click(() => {
			jump()
		})
	})
})