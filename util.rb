#!/usr/bin/env ruby
# encoding: utf-8

require "date"
require "csv"
require "json"

CHECK_FILE = "/var/tmp/commit_amoeba.chk"
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

def get_day_number_of_year(d)
    return d - Date.new(d.year - 1, 12, 31)
end

def get_first_day_of_week()
    return Date.new(Time.now.year, Time.now.month, Time.now.day - Time.now.wday + 1)
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

def shrink_place(place)
    
    ret = ""
    if (place == nil)
        return ret
    end
    
    places = place.split("\r\n")
    
    plist = {
    "　" => "",
    "【東京】セミナールーム（54席）※テレビ会議常設※" => "東京SeminarRoom",
    "【東京】PCセミナールーム（22席）"            => "東京PCROOM",
    "【東京】テレビ会議室（6席）※テレビ会議常設※"   => "東京TV会議室",
    "【東京】ミーティングルーム1（8席）" => "東京MTGRoom1",
    "【東京】ミーティングルーム2（6席）※テレビ会議常設※" => "東京MTGRoom2",
    "【東京】プロジェクター（持ち出し用/EPSON）" => "東京ProjectorEPSON",
    "【名古屋】プロジェクター（持ち出し用/EPSON）" => "名古屋ProjectorEPSON",
    "【大阪】2,3Fセミナーホール※テレビ会議常設※" => "大阪2F3FHall",
    "【大阪】4Fオレンジ" => "大阪Orange",
    "【大阪】4Fグリーン" => "大阪Green",
    "【大阪】4Fイエロー" => "大阪Yellow",
    "【大阪】4Fレッド※テレビ会議は別途予約必要 ※" => "大阪Red",
    "【大阪】4Fテレビ会議" => "大阪4FTV-set",
    "【大阪】4Fブルー（勉強会/待合）" => "大阪Blue",
    "【大阪】5A" => "大阪5A",
    "【大阪】5B※テレビ会議常設※" => "大阪5B",
    "【大阪】5C※役員優先※" => "大阪5C",
    "【大阪】6A" => "大阪6A",
    "【大阪】6B" => "大阪6B",
    "【大阪】6C※テレビ会議常設※" => "大阪6C",
    "【大阪】8A" => "大阪8A",
    "【大阪】10Fカフェ" => "大阪10FCafe",
    "【大阪】プロジェクター（短焦点タイプ/台が必要）" => "大阪Projector8F",
    "【大阪】プロジェクター&#40;EPSON&#41;" => "大阪ProjectorEPSON",
    "【名古屋】PCセミナールーム（12席）" => "名古屋PCRoom",
    "【名古屋】テレビ会議" => "名古屋TV会議室",
    "【名古屋】プロジェクター（WT61D）" => "名古屋ProjectorWT61D",
    "【東京】貸出用iPhone" => "東京iPhone",
    "【大阪】貸出用iPhone" => "大阪iPhone",
    "同報メールパソコン" => "同報メールPC",
    "【大阪】YAMAHAマイクセット" => "大阪YAMAHAMIC",
    "【東京】YAMAHAマイクセット " => "東京YAMAHAMIC",
    "【大阪】LiveOn（ID:motexosaka）" => "大阪LiveON",
    "【東京】LiveOn（ID:motextokyo）" => "東京LiveON",
    "ISLリモコン①（sales）（全社用）" => "ISL1",
    "ISLリモコン②（sales）（営業用）" => "ISL2",
    "ISLリモコン③（sales）（営業用）" => "ISL3",
    "ISLリモコン④（support）（サポート用）" => "ISL4",
    "ISLリモコン⑤（support）（サポート用）" => "ISL5",
    "【東京】貸出用iPad1" => "東京iPad1",
    "【東京】貸出用iPad2 " => "東京iPad2",
    "【大阪】貸出用iPad1" => "大阪iPad1",
    "【大阪】貸出用iPad2" => "大阪iPad2",
    "【名古屋】貸出用iPad1" => "名古屋iPad1"
    }
    
    i = 0
    while (i < places.length)
        if (i > 0)
            ret = ret + " + "
        end

        shortname = plist[places[i]]
        if (shortname != nil)
            ret = ret + plist[places[i]]
        else
            ret = ret + places[i]
        end

        i = i + 1
    end
    
    return ret
end

