var COLUMN_TITLE = 0;
var COLUMN_STIME = 1;
var COLUMN_ETIME = 2;
var COLUMN_PLACE = 3;
var COLUMN_DESC = 4;

function ss2cal() {
    
    var CAL_SY = "CalSync";
    var CAL_SH = "CalSync";
    var CAL_ID = "koichi.ozawa.motex@gmail.com";
    
    Logger.log("ss2cal start.")
    
    try {
        // SpreadSheetに書かれたスケジュールデータを取得
        file = getSpreadSheetByName(CAL_SY);
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
        var rng = sheet.getDataRange().getValues();
        
        var cal = CalendarApp.getCalendarById(CAL_ID);
        if (cal == null) {
            throw new Error("Cal not found.");
        }
        cal.setTimeZone("Asia/Tokyo");
        
        // 範囲内の既存スケジュールを削除
        if (rng != null) {
            var min = getMinDate(rng);
            var max = getMaxDate(rng);
            clearEvents(cal, min, max);
        }
        
        // スケジュールをカレンダーに追加
        for (var i = 0 ; i < rng.length ; i++) {
            var s = new Date(rng[i][COLUMN_STIME] * 1000);
            var e = new Date(rng[i][COLUMN_ETIME] * 1000);
            var event = cal.createEvent(rng[i][COLUMN_TITLE], s, e, {location: rng[i][COLUMN_PLACE], description: rng[i][COLUMN_DESC]} );
        }
        Logger.log("[" + i + "] events are created.");
        
    } catch (e) {
        Logger.log("message:" + e.message + "\nfileName:" + e.fileName + "\nlineNumber:" + e.lineNumber + "\nstack:" + e.stack);
    }
    
    Logger.log("ss2cal end.")
    
}

function getSpreadSheetByName(SSName){
    var file = null;
    var files = DriveApp.getFilesByName(SSName);
    
    while (files.hasNext()) {
        file = files.next();
        if (file.getMimeType() == "application/vnd.google-apps.spreadsheet") {
            break;
        }
    }
    return file;
}


function getMinDate(Range){
    var i = 1;
    var min = Range[0][COLUMN_STIME];
    while (i < Range.length) {
        min = Math.min(min, Range[i][COLUMN_STIME]);
        i = i + 1;
    }
    return new Date(min * 1000);
}

function getMaxDate(Range){
    var i = 1;
    var max = Range[0][COLUMN_ETIME];
    while (i < Range.length) {
        max = Math.max(max, Range[i][COLUMN_ETIME]);
        i = i + 1;
    }
    return new Date(max * 1000);
}


function clearEvents(Calendar, MinDate, MaxDate) {
    var events = Calendar.getEvents(MinDate, MaxDate);
    if (events.length != null) {
        Logger.log("[" + events.length + "] events were found and deleted.");
        for (var i = 0 ; i < events.length ; i++) {
            events[i].deleteEvent();
        }
    }
}


function cal2ss() {
    
    var CAL_SY = "CalSync";
    var CAL_ID = "koichi.ozawa.motex@gmail.com";
    
    try {
        
        var cal = CalendarApp.getCalendarById(CAL_ID);
        if (cal == null) {
            throw new Error("Cal not found.");
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
        
        eventsHandler(evts, sheet);
        
    } catch (e) {
        Logger.log("message:" + e.message + "\nfileName:" + e.fileName + "\nlineNumber:" + e.lineNumber + "\nstack:" + e.stack);
    }
}


function eventsHandler(Events, Sheet){
    
    if (Events.length == 0) {
        return;
    }
    
    for (var i = 0 ; i< Events.length ; i++){
        Logger.log("Event:[" + i + "]"+Events[i].getTitile());
        if (Sheet != null) {
            Sheet.appendRow([Events[i].getTitle(),
                             Events[i].getStartTime(),
                             Events[i].getEndTime(),
                             Events[i].getLocation(),
                             Events[i].getDescription()]);
        }
    }
}

function resetSheet(Sheet) {
    if (Sheet.getMaxRows() > 0){
        Sheet.deleteRows(1, Sheet.getMaxRows());
    }
}

function onFormSubmit(e) {
    
    Logger.log("Form Submit Begin.");
    
    try {
        // フォームの回答内容
        var answer = e.values;
        if (answer.length < 2) {
            throw new Error("Invalid Function Call.");
        }
        
        // フォームの回答内容で振り分け
        var formname = answer[1];
        switch (formname) {
            case "ss2cal":
                ss2cal();
                break;
            default:
                throw new Error("Invalid Function Call. [FormName:"+ formname + "]");
                bareak;
        }
        
    } catch (exp) {
        Logger.log("Message:" + exp.message + "\nFileName:" + exp.fileName + "\nLineNumber:" + exp.lineNumber + "\nStack:" + exp.stack);
    }
    
    Logger.log("Form Submit End.");
    
}
