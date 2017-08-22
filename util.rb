#!/usr/bin/env ruby
# encoding: utf-8

require "date"
require "csv"
require "json"

CHECK_FILE = "/var/tmp/commit_amoeba.chk"
CHECK_FILE_O365 = "/var/tmp/o365_service.chk"
CONFIG = "/etc/ozawaapps/webapps.json"
MODE_NORMAL = 0
MODE_GAROON = 1

def getdatestr(dif = 0)
	ret = Date::today + dif
	return ret.strftime("%Y/%m/%d")
end

def getlastworkday()
    tday = Date::today
    diff = 0

    case (tday.wday)
    when 0	#Sunday
        diff = -2
    when 1	#Monday
        diff = -3
    else
        diff = -1
    end

    return getdatestr(diff)
end

def is_today(jud)
	ret = 0
	if (jud == Date::today.jd.to_s)
		ret = 1
	end
	return ret
end

def is_already_ran()
	f = open(CHECK_FILE, "r+")
	ltime = f.read
	f.close
	return is_today(ltime)
end

def mark_ran()
	f = open(CHECK_FILE, "w")
	f.write(Date::today.jd)
	f.close
end

def mark_ran_o365()
	f = open(CHECK_FILE_O365, "w")
	f.write(Time.now)
	f.close
end

def get_last_ran_o365()
	f = open(CHECK_FILE_O365, "r+")
	ltime = f.read
    f.close
    
    lt = 0
    if ltime != ""
        lt = Time.parse(ltime)
        lt = lt.to_i
    end

	return lt
end

def get_day_number_of_year(d)
    return d - Date.new(d.year - 1, 12, 31)
end

def get_first_day_of_week()
    return Date.new(Time.now.year, Time.now.month, Time.now.day - Time.now.wday + 1)
end

def get_first_day_of_month()
    return Date.new(Time.now.year, Time.now.month, 1)
end

def get_last_day_of_amoebamonth(yyyy = 0, mm = 0)

    if (yyyy == 0) then
        yyyy = Time.now.year
    end
    if (mm == 0) then
        mm = Time.now.month
    end
    
    if (mm == 12) then
        next_mm = 1
        next_yyyy = yyyy + 1
    else
        next_mm = mm + 1
        next_yyyy = yyyy
    end

    # get the last day of last month
    d = Date.new(next_yyyy, next_mm, 1)
    d = d - 2
    
    # check if it was work day
    # if not rewind 1 day
    while (true) do
        if (1 < d.wday && d.wday < 6)
            break
        end
        d = d - 1
    end
    
    return d    
end

def get_first_day_of_amoebamonth(yyyy = 0, mm = 0)

    if (yyyy == 0) then
        yyyy = Time.now.year
    end
    if (mm == 0) then
        mm = Time.now.month
    end

    # get the last day of last month
    d = Date.new(yyyy, mm, 1)
    d = d - 1
    
    # check if it was work day
    # if not rewind 1 day
    while (true) do
        if (1 < d.wday && d.wday < 6)
            break
        end
        d = d - 1
    end
    
    return d
end


def flush_to_csv(arr, csvfile, quote = false)
    CSV.open(csvfile, "w", :force_quotes => quote) do |writer|
        arr.each do |line|
            writer << line
        end
    end
end

def get_config(webapp, key)
    hash = JSON.parse(File.read(CONFIG))
    return hash[webapp][key]
end

def set_config(webapp, key, value)
    
    hash = JSON.parse(File.read(CONFIG))
    hash[webapp][key] = value
    
    File.open(CONFIG, "w") do |f|
        f.write(JSON.pretty_generate(hash))
    end
end

def split_event_time(event_time, mode = MODE_NORMAL)
    
    if (event_time == nil) then
        raise "Invalid Arg event_time = nil"
    end
    
    str = event_time.split("〜")
    arr = Array.new(4)
    
    if (str[0].index(":") != nil )
        arr[0] = Time.strptime(str[0], "%Y年%m月%d日　%H:%M")
    else
        arr[0] = Time.strptime(str[0], "%Y年%m月%d日")
    end
    
	if (str[1] != nil) 
    	if (str[1].index(":") != nil )
        	tmp = str[0].split("　")
        	arr[1] = Time.strptime(tmp[0] + str[1], "%Y年%m月%d日 %H:%M")
    	else
			arr[1] = Time.strptime(str[1], " %Y年%m月%d日")
    	end
	else
        # 開始日と同じに
		arr[1] = arr[0]
	end
    
    
    if (mode == MODE_NORMAL) then
        # UNIXTIME
        arr[0] = arr[0].to_i
        arr[1] = arr[1].to_i
    elsif (mode == MODE_GAROON) then
        # Garoon CSV string
        arr[3] = arr[1].strftime("%H:%M:%S")
        arr[2] = arr[0].strftime("%H:%M:%S")
        arr[1] = arr[1].strftime("%Y/%m/%d")
        arr[0] = arr[0].strftime("%Y/%m/%d")
    end    

    
    return arr
end

def is_empty(obj)
    
    ret = false
    
    if (obj == nil)
        ret = true
    elsif (obj.length == 0)
        ret = true
    end
    
    return ret
end

CW_ACCOUNT_TAB_ID = 0
CW_ACCOUNT_TAB_ROOM_ID = 1
CW_ACCOUNT_TAB_NAME = 2
CW_ACCOUNT_TAB_EMAIL = 3

def load_cw_acount_table()
    cw_usermaster = get_config("COMMON", "CSVPath") + get_config("chatwork", "UserMaster")

    return CSV.read(cw_usermaster)
end


def get_CW_account_id(email)

    id = nil

    cw_account_table = load_cw_acount_table()
    
    for account in cw_account_table do
        if account[CW_ACCOUNT_TAB_EMAIL] == email
            id = account[CW_ACCOUNT_TAB_ID]
            break
        end
    end

    return id

end

def get_CW_to_format(email, rich = true)

    fmt = ""

    cw_account_table = load_cw_acount_table()

    id = ""
    name = ""

    for account in cw_account_table do
        if (account[CW_ACCOUNT_TAB_EMAIL] == email) then
            id = account[CW_ACCOUNT_TAB_ID]
            name = account[CW_ACCOUNT_TAB_NAME]
            break
        end
    end

    fmt = "[To:" + id + "]"
    if (rich == true) then
        fmt += name + " さん" + "\r\n"
    end

    return fmt

end

