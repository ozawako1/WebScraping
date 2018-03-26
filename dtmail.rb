#!/usr/bin/env ruby
# encoding: utf-8

DTMAIL_SEPARATOR = "----------------------------"
DTMAIL_No       = "【アラートNo】"
DTMAIL_DATE     = "【検知日時】"
DTMAIL_TITLE    = "【検出脅威】"
DTMAIL_DETAIL   = "【検知内容】"
DTMAIL_RESEARCH = "【調査内容】"
DTMAIL_CONFIRM  = "【確認事項】"

require_relative "util"
require_relative "cw_post"

def splitvalue(str)
#    【アラートNo】 ： 6810
    s = str.chomp
    arr = s.split(" ： ")
    return arr[1]
end

def shorten(long_date)
#    2017年11月17日 8:34:05 → 2017/11/17
    d = DateTime.strptime(long_date, "%Y年%m月%d日 %H:%M:%s")
    return d.year.to_s + "/" + d.month.to_s + "/" + d.day.to_s
end

def read_dtmail(mail)
    
    almdata = nil

    File.open(mail, "rt") do |f|
        
        arr = Array.new()
        title = ""
        value = ""
        in_title = 0 #検知内容の複数行対応
        
        f.each() { |line|
            
            case 
            when line.start_with?(DTMAIL_SEPARATOR) then
                #セパレータ
                if (title != "" || value != "") then
                    
                    arr << Array[title, value]
                    
                    title = ""
                    value = ""                                    
                end

            when line.start_with?(DTMAIL_No) then
                # No.
                title = splitvalue(line)
            when line.start_with?(DTMAIL_DATE) then
                # 日時.
                title += " | "
                title += shorten(splitvalue(line))
            when line.start_with?(DTMAIL_TITLE) then
                # TITLE
                title += " | "
                title += splitvalue(line)
                in_title = 1
            else
                if ((in_title == 1) && (line.start_with?(DTMAIL_DETAIL) == false)) then
                    title += line.strip()
                    next
                end
                in_title = 0
                value += line
            end

        }

        almdata = arr
        
    end

    return almdata
end


use_debug = 1
ARGV.each { |arg|
	case arg
	when "DEBUG"
		use_debug = 1
	else
		puts("undefined arg. [" + arg + "]")
	end
}

mailpath  = get_config("DarkTrace",	"MailPath")

begin
	
	Dir::glob(mailpath + "dt*.txt") do |f|
	
		puts("processing " + f + "...")

        alarms = read_dtmail(f)
        if (alarms.length > 0) then
            p alarms
        end
		
		puts("[" + f + "] finished.")		
		File.rename(f, mailpath + "done/" + File.basename(f))

		chatmsg = "[info][title]DarkTraceアラート通知メールが処理されました[/title]"
#		chatmsg += "プロジェクト名: " + jdata["functionname"] + "\r\n"
#		chatmsg += "プロジェクトコード: " + jdata["code"]
		chatmsg += "[/info]（※このメッセージは、自動送信です。）"

        chatroom = "MO-CSIRT"
        if (use_debug == 1) then
            chatroom = "マイチャット"
        end
		cw_post_msg(chatroom, chatmsg)

	end
	
		
rescue => e
    p e
    p e.backtrace
    p Time.now

end

