getQuarter = (date) => {
    let year = date.getFullYear();
    let current_year = new Date().getFullYear();
    let quarters = [new Date(`${year}-01-01`), new Date(`${year}-04-01`), new Date(`${year}-07-01`), new Date(`${year}-10-01`)]
    
    if(year === current_year) {

        if(date.getTime() < quarters[1].getTime()) {
            return 'quarter1Balance'
        }

        if(date.getTime() < quarters[2].getTime()) {
            return 'quarter2Balance'
        }

        if(date.getTime() < quarters[3].getTime()) {
            return 'quarter3Balance'
        }

        if(date.getTime() > quarters[3].getTime()) {
            return 'quarter4Balance' 
        }
    } else if(year > current_year) {

        if(date.getTime() < quarters[1].getTime()) {
            return 'quarter1nextBalance'
        }

        if(date.getTime() < quarters[2].getTime()) {
            return 'quarter2nextBalance'
        }

        if(date.getTime() < quarters[3].getTime()) {
            return 'quarter3nextBalance'
        }
    }
}