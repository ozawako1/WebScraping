
require "date"
require "csv"
require "json"

CHECK_FILE = "/var/tmp/commit_amoeba.chk"
CONFIG = "/etc/ozawaapps/webapps.json"

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

def get_day_number_of_year(d)
    return d - Date.new(d.year - 1, 12, 31)
end

def get_first_day_of_week()
    return Date.new(Time.now.year, Time.now.month, Time.now.day - Time.now.wday + 1)
end

def get_first_day_of_amoebamonth()
    d = Date.new(Time.now.year, Time.now.month, 1)
    d = d - 1
    
    diff = 0
    
    while (true) do
        if (1 < d.wday && d.wday < 6)
            break
        end
        d = d - 1
    end
    
    return d
end


def flush_to_csv(arr, csvfile)
    CSV.open(csvfile, "w") do |writer|
        arr.each do |line|
            writer << line
        end
    end
end

def get_config(webapp, key)
    hash = JSON.parse(File.read(CONFIG))
    return hash[webapp][key]
end
