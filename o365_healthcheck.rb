#!/usr/bin/env ruby
# encoding: utf-8

require "uri"
require "net/http"
require "JSON"
require "jwt"
require_relative "cw_post"

require_relative "CWebApp"

DEBUG = 0

begin

    board = "情シス委員会"
    if (DEBUG == 1) then
        board = "マイチャット"
    end
    
    last_ran = get_last_ran_o365()
    
    o365 = CWebAppO365.new("https://manage.office.com/", DEBUG)

    o365.Prep()
    status_arr = o365.GetCurrentStatus()

    status_arr.each { |s|
        s_id     = s["Id"]
        s_name   = s["WorkloadDisplayName"]
        s_status = s["Status"]
        s_time   = Time.parse(s["StatusTime"]).to_i

        if (s_status != "ServiceOperational" && s_time > last_ran) then

            chatmsg = ""
            chatmsg += "[info][title]Office365 正常性確認[/title]"
            chatmsg += "サービス名: " + s_name + "\r\n"
            chatmsg += "サービス状態: " + s_status
            chatmsg += "[/info]（※このメッセージは、自動送信です。）\r\n"
            
            cw_post_msg(board, chatmsg)
        end
    
        p "ID:"     + s_id      if DEBUG == 1
        p "Name:"   + s_name    if DEBUG == 1
        p "Status:" + s_status  if DEBUG == 1
        p "-----"               if DEBUG == 1
    }

    mark_ran_o365()


rescue => e
    p e
    p e.backtrace
    p Time.now

end

