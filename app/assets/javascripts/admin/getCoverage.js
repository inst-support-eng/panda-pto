$('.admin.coverage').ready(() => {
    getCoverage = async (date) => {
        let response = {}
        if (date == undefined) {
            response = await fetch('/admin/coverage');
        } else {
            response = await fetch(`/admin/coverage/?date=${date}`)
        }

        return await response.json();
    }

    updateCoverage = async () => {
        let todayDate = new Date()
        let tomrorowDate = new Date()
        tomrorowDate.setDate(todayDate.getDate() + 1)

        let today = await getCoverage();
        let tomorrow = await getCoverage(tomrorowDate)

        let todayDateId = document.getElementById('todays-date')
        let totalAgents = document.getElementById('total-agents-today')
        let totalOff = document.getElementById('total-agents-off-today')
        let agentsOff = document.getElementById('agents-off-today')
        let agentsScheduled = document.getElementById('agents-scheduled')

        let tomorrowDateId = document.getElementById('tomorrows-date')
        let totalTomorrow = document.getElementById('total-agents-tomorrow')
        let offTomorrow = document.getElementById('total-agents-off-tomorrow')
        let agentsOffTomorrow = document.getElementById('agents-off-tomorrow')
        let scheduledTomorrow = document.getElementById('agents-scheduled-tomorrow')

        todayDateId.append(todayDate.toISOString())
        totalAgents.append(today.l1_total_on)
        totalOff.append(today.l1_total_off)
        today.agents_off.length != 0 ? agentsOff.append(today.agents_off) : agentsOff.innerHTML += 'none at this moment'
        let agents = ""
        today.agents_scheduled.forEach(el => {
            agents += `<div id='agent-info'>${el.name} ${el.start_time} ${el.end_time}</div>`
        })

        agentsScheduled.innerHTML += agents;

        tomorrowDateId.append(tomrorowDate.toISOString())
        totalTomorrow.append(tomorrow.l1_total_on)
        offTomorrow.append(tomorrow.l1_total_off)
        tomorrow.agents_off.length != 0 ? agentsOffTomorrow.append(today.agents_off) : agentsOffTomorrow.innerHTML += 'none at this moment'

        let agentsTomorrow = ""

        tomorrow.agents_scheduled.forEach(el => {
            agentsTomorrow += `<div id='agent-info'>${el.name} ${el.start_time} ${el.end_time}</div>`
        })

        scheduledTomorrow.innerHTML += agentsTomorrow

    }

    updateCoverage();
})