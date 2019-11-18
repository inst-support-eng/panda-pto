$(document).ready(() => {
	$('#agent-select').change(() => {
		if ($('#agent-select').val() == 'all-agents') {
			$('#all-agents-list').show();
			$('#all-agents-button').show();

			$('#agents-off-today-list').hide();
			$('#agents-off-today-button').hide();

			$('#agents-currently-not-working-list').hide();
			$('#agents-currently-not-working-button').hide();

			$('#agents-team-list').hide();
			$('#agents-team-button').hide();
		}
		if ($('#agent-select').val() == 'agents-off-today') {
			$('#agents-off-today-list').show();
			$('#agents-off-today-button').show();

			$('#all-agents-list').hide();
			$('#all-agents-button').hide();

			$('#agents-currently-not-working-list').hide();
			$('#agents-currently-not-working-button').hide();

			$('#agents-team-list').hide();
			$('#agents-team-button').hide();
		}
		if ($('#agent-select').val() == 'agents-currently-not-working') {
			$('#agents-currently-not-working-list').show();
			$('#agents-currently-not-working-button').show();

			$('#all-agents-list').hide();
			$('#all-agents-button').hide();

			$('#agents-off-today-list').hide();
			$('#agents-off-today-button').hide();

			$('#agents-team-list').hide();
			$('#agents-team-button').hide();
		}
		if ($('#agent-select').val() == 'agents-team') {
			$('#agents-team-list').show();
			$('#agents-team-button').show();

			$('#agents-currently-not-working-list').hide();
			$('#agents-currently-not-working-button').hide();

			$('#all-agents-list').hide();
			$('#all-agents-button').hide();

			$('#agents-off-today-list').hide();
			$('#agents-off-today-button').hide();
		}
	});

	$('input:checkbox[name=selected-agent]').change(() => {
		agentList = [''];
		agentPhoneList = [''];
		count = 0;
		checkboxes = document.querySelectorAll('input[name=selected-agent]');
		checkboxes.length;
		checkboxes.forEach(el => {
			if (el.checked) {
				user = el.value.split('_');
				pNum = user[0];
				name = user[1];
				agentList.push(name);
				agentPhoneList.push(pNum);
				count++;
			}
		});
		$('#message_recipients').attr("value", [agentList, '']);
		$('#message_recipient_numbers').attr("value", [agentPhoneList, '']);
		document.getElementById('all-agents-counter').innerHTML = `Total agents to be messaged : ${count}`;
	});

	$('#agents-off-today-button').click(() => {
		checked = $(this).data();
		$('.agents-off-today-row').click();
		checked.checked = !checked.checked;
	});

	$('#agents-currently-not-working-button').click(() => {
		checked = $(this).data();
		$('.agents-currently-not-working-row').click();
		checked.checked = !checked.checked;
	});

	$('#all-agents-button').click(() => {
		checked = $(this).data();
		$('.all-agents-row').click();
		checked.checked = !checked.checked;
	});

	$('#agents-team-button').click(() => {
		checked = $(this).data();
		$('.agents-team-row').click();
		checked.checked = !checked.checked;
	});
});