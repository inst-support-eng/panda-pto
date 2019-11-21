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

	agentList = [''];
	agentPhoneList = [''];
	count = 0;

	$('input:checkbox[name=selected-agent]').change(event => {
		target = event.target;

			user = target.value.split('_');
			pNum = user[0];
			name = user[1];
		if (target.checked) {
			$(`:checkbox[value='${target.value}']`).attr('checked', target.checked);
			if (agentList.indexOf(name) < 0) {
				agentList.push(name);
			}
			if (agentPhoneList.indexOf(pNum) < 0) {
				agentPhoneList.push(pNum);
			}
		} else {
			$(`:checkbox[value='${target.value}']`).attr('checked', target.checked);
			if (agentList.indexOf(name) > -1) {
				val = agentList.indexOf(name);
				agentList.splice(val, 1);
			}
			if (agentPhoneList.indexOf(pNum) > -1) {
				val = agentPhoneList.indexOf(pNum);
				agentPhoneList.splice(val, 1);
			}
		}

		count = agentList.length - 1;
		$('#message_recipients').attr("value", [agentList, '']);
		$('#message_recipient_numbers').attr("value", [agentPhoneList, '']);
		$('#submit-message').attr('data-confirm', `You are about to text ${count}. Are you sure?`);
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