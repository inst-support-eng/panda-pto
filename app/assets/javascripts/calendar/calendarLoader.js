$(document).on('turbolinks:load', () => {
	let today = new Date()
	let currentMonth = today.getMonth()
	let currentYear = today.getFullYear()

	let year = document.getElementById('currentYearTable')

	$('.pages.index').ready(() => {
		createCalendar(currentYear, currentMonth)
		openYear(event, year)
	})

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