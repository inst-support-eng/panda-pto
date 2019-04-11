$(document).on('turbolinks:load', () => { 
    let getCoverage = async(date) =>  {
        let response = {}
        if(date == undefined) {
            response = await fetch('/admin/coverage');
        }

        else {
            response = await fetch(`/admin/coverage/?date=${date}`)
        }
        
        return await response.json();
    }

    let updateCoverage = async () => {
        let response = await getCoverage();

        let totalAgents = document.getElementById('total-agents-today')
        let totalOff = document.getElementById('total-agents-off-today')
        let agentsOff = document.getElementById('agents-off-today')
        let agentsScheduled = document.getElementById('agents-scheduled')

        totalAgents.append(response.l1_total_on)
        totalOff.append(response.l1_total_off)
        agentsOff.append(response.agents)
        let agentsToday = response.agents_scheduled
        let agents = ""
        agentsToday.forEach(el => {
            console.log(el)
            agents += `<div id='agent-info'>${el.name} ${el.start_time} ${el.end_time}</div>`
        })
        
        agentsScheduled.innerHTML += agents;
    }

    updateCoverage();
})