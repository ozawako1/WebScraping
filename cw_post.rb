#!/usr/bin/env ruby
# encoding: utf-8

require_relative "util"
require_relative "CWebApp"

def cw_post_msg(room_name, msg)

    chatwork = CWebAppChatwork.new("https://api.chatwork.com")
    if chatwork == nil
        puts("Init Error.")
        exit
    end

    begin

        chatwork.chat_msg(room_name, msg)

    rescue => e
        p e
        p e.backtrace
        p Time.now

    end
end


