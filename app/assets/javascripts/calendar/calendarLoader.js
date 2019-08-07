$(document).on('turbolinks:load', () => {
	console.log('load')
	let today = new Date()
	let month = today.getMonth()
	let year = document.getElementById('currentYearTable')

	$('.pages.index').ready(() => {
		console.log('pages load')
		createCalendar(year, month)
		openYear(event, year)
	})

	$('#prev').click(() => {
		previous()
	})
	$('#next').click(() => {
		console.log(`click`)
		next()
	})
	$('#jump').click(() => {
		jump()
	})
})