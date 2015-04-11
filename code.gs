function ss2cal() {
    
    var CAL_SY = "CalSync";
    var CAL_SH = "CalSync";
    var CAL_ID = "koichi.ozawa.motex@gmail.com";
    
    Logger.log("ss2cal start.")
    
    try {
        var cal = CalendarApp.getCalendarById(CAL_ID);
        if (cal == null) {
            throw new Error("Cal not found.");
        }
        cal.setTimeZone("Asia/Tokyo");
        
        var file = null;
        var files = DriveApp.getFilesByName(CAL_SY);
        while (files.hasNext()) {
            file = files.next();
            if (file.getMimeType() == "application/vnd.google-apps.spreadsheet") {
                break;
            }
        }
        if (file == null) {
            throw new Error("File not found.");
        }
        
        var spreadsheet = SpreadsheetApp.open(file);
        if (spreadsheet == null) {
            throw new Error("File could not be opened.");
        }
        
        var sheet = spreadsheet.getSheetByName(CAL_SH);
        if (sheet == null) {
            throw new Error("Sheet not found.");
        }
        
        var cnt = sheet.getMaxRows();
        var rng = sheet.getRange(1, 1, cnt, 4);
        var arr = range2array(rng)
        
        for (var i = 0 ; i < cnt ; i++) {
            var s = new Date(arr[i][1] * 1000)
            var e = new Date(arr[i][2] * 1000)
            var event = cal.createEvent(arr[i][0], s, e, {location: arr[i][3]} );
        }
    } catch (e) {
        Logger.log("message:" + e.message + "\nfileName:" + e.fileName + "\nlineNumber:" + e.lineNumber + "\nstack:" + e.stack);
    }
    
    Logger.log("ss2cal end.")
    
}

function range2array(Range){
    var arr = new Array();
    var r = 0;
    
    var vals = Range.getValues();
    for (r in vals) {
        arr.push(vals[r]);
    }
    
    return arr;
}

function cal2ss() {
    
    var CAL_SY = "CalSync";
    var CAL_ID = "koichi.ozawa.motex@gmail.com";
    
    var cal = CalendarApp.getCalendarById(CAL_ID);
    if (cal == null) {
        Logger.log("Cal not found.")
    }
    
    var tday = new Date();
    var evts = cal.getEventsForDay(tday);
    eventsHandler(evts, null);
    
    var files = DriveApp.getFilesByName(CAL_SY);
    if (files.hasNext() == false){
        Logger.log("File not found.");
    }
    var file = files.next();
    var spreadsheet = SpreadsheetApp.open(file);
    var sheet = spreadsheet.getSheets()[0];
    resetSheet(sheet);
    
    eventsHandler(evts, sheet);
    
}


function eventsHandler(Events, Sheet){
    if (Events.length == 0) {
        Logger.log("Events not found.");
    }
    
    for (var i = 0 ; i< Events.length ; i++){
        Logger.log("Id   : " + Events[i].getId());
        Logger.log("Title: " + Events[i].getTitle());
        Logger.log("Start: " + Events[i].getStartTime());
        Logger.log("End  : " + Events[i].getEndTime());
        Logger.log("Location: " + Events[i].getLocation());
        
        if (Sheet != null) {
            Sheet.appendRow([Events[i].getId(),
                             Events[i].getTitle(),
                             Events[i].getStartTime(),
                             Events[i].getEndTime(),
                             Events[i].getLocation()]);
        }
    } 
}

function resetSheet(Sheet) {
    if (Sheet.getMaxRows() > 0){
        Sheet.deleteRows(1, Sheet.getMaxRows());
    }
}


