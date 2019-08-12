$(document).on('turbolinks:load', () => {
	let today = new Date()
	let month = today.getMonth()
	let year = document.getElementById('currentYearTable')

	$('.pages.index').ready(()  => {
		createCalendar(year, month)
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