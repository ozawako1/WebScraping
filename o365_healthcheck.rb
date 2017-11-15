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
    if (DEBUG == 1) then
        p "Last Ran: " + Time.at(last_ran).getutc.to_s
    end
    
    o365 = CWebAppO365.new("https://manage.office.com/", DEBUG)

    status_arr = o365.GetCurrentStatus()

    status_arr.each { |s|

        s_id     = s["Id"]
        s_name   = s["WorkloadDisplayName"]
        s_status = s["Status"]
    
        if (o365.isChecked?(s_id) && s_status != "ServiceOperational") then
   
            s["IncidentIds"].each { |id| 

                msg = o365.GetMessage(id)
                upd = Time.parse(msg["LastUpdatedTime"]).to_i
                if (DEBUG == 1) then
                    p "Last Updated: " + Time.at(upd).getutc.to_s
                end

                if (upd > last_ran) then

                    chatmsg = ""
                    chatmsg += "[info][title]Office365 サービス異常検知（公式）[/title]"
                    chatmsg += "サービス名: " + s_name + "\r\n"
                    chatmsg += "サービス状態: " + s_status + "\r\n"
                    chatmsg += "障害概要: " + msg["Title"]
		    chatmsg += "https://portal.office.com/adminportal/home#/servicehealth"
                    chatmsg += "[/info]（※このメッセージは、自動送信です。）\r\n"                                              

                    cw_post_msg(board, chatmsg)                    
                end
            }
            
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

