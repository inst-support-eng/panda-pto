$(document).on('turbolinks:load', () => { 
    console.log('test')
    let getCoverage = async(date) =>  {
        let response = {}
        if(date == undefined) {
            response = await fetch('/admin/coverage');
        }

        else {
            response = await fetch(`/admin/coverage/?date=${date}`)
        }
        console.log(response)
        return await response.json();
    }

    getCoverage();
})