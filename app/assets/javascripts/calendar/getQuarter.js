getQuarter = (date) => {
    let year = date.getFullYear();
    let quarters = [new Date(`${year}-01-01`), new Date(`${year}-04-01`), new Date(`${year}-07-01`), new Date(`${year}-10-01`)]
    if(date.getTime() < quarters[0].getTime()) {
        return 'quarter1'
    }

    if(date.getTime() < quarters[1].getTime()) {
        return 'quarter2'
    }

    if(date.getTime() < quarters[2].getTime()) {
        return 'quarter3'
    }

    if(date.getTime() < quarters[3].getTime()) {
        return 'quarter4'
    }
}