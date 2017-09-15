#!/usr/bin/env ruby
# encoding: utf-8

require_relative "util"
require_relative "CWebApp"

NO_DEBUG = 0

def cw_say_hello(room_name)
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


cw_say_hello("情シスbot（ベータ版）")


