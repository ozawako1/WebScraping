#!/usr/bin/env ruby
# encoding: utf-8

require_relative "util"
require_relative "CWebApp"
require_relative "sqlite"

NO_DEBUG = 0

def proc_make_msg(from_msg)
    
    repmsg = ""
    
    user    = get_user_from_ipaddr(from_msg)
    machine = get_machine_from_ipaddr(from_msg)

    if ((user.nil? || user.empty?) && (machine.nil? || machine.empty?)) then
        repmsg = "そのアドレス(%s)は、未使用です。"%from_msg
    else
        repmsg = "そのアドレス(%s)は、"%from_msg
        if (user != nil)
            repmsg += "%sさんが、"%user
        end
        if (machine != nil)
            repmsg += "%sで"%machine
        end
        repmsg += "使用しています。"
    end

    return repmsg
end

def cw_reply(room_name)
    
        chatwork = CWebAppChatwork.new("https://api.chatwork.com", NO_DEBUG)
        if chatwork == nil
            puts("Init Error.")
            exit
        end
    
        body = ""
    
        begin
    
            chatwork.say_hello(room_name)
    
        rescue => e
            
            p e
            p e.backtrace
            p Time.now
    
        end
    end

def cw_say_hello()

    chatwork = CWebAppChatwork.new("https://api.chatwork.com", NO_DEBUG)
    if chatwork == nil
        puts("Init Error.")
        exit
    end

    body = ""

    begin

        chatwork.reply_rooms(method(:proc_make_msg))

    rescue => e
        
        p e
        p e.backtrace
        p Time.now

    end
end


def cw_post_msg(room_name, msg, to_email = nil, cc_email = nil)

    chatwork = CWebAppChatwork.new("https://api.chatwork.com", NO_DEBUG)
    if chatwork == nil
        puts("Init Error.")
        exit
    end

    body = ""

    begin
        if to_email != nil then
            body += get_CW_to_format(to_email)
        end

        if cc_email != nil then
            cc_arr = cc_email.split(",")
            cc_arr.each do |cc|
                body += get_CW_to_format(cc, false)
            end
            body += "\r\n"
        end

        body += msg
        chatwork.chat_msg(room_name, body)

    rescue => e
        p e
        p e.backtrace
        p Time.now

    end
end

cw_reply("情シスbot（ベータ版）")
#cw_say_hello()


