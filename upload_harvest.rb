#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require_relative "CWebApp"
require_relative "util"

csvpath = "/Users/OzawaKoichi/Develop/output"

use_proxy = 0
use_debug = 0
use_dump  = 0

ARGV.each { |arg|
    case arg
        when "PROXY"
        use_proxy = 1
        when "DEBUG"
        use_debug = 1
        when "DUMP"
        use_dump = 1
        else
        puts("undefined arg. [" + arg + "]")
    end
}

google = CWebAppGoogle.new("mygas")
if google == nil
    puts("Google Init Error.")
    exit
end

begin
    
    google.Login()
    
    google.WriteFile(csvpath + "/user_hours.csv")

rescue => e
    p e
    p e.backtrace
    p Time.now
    
end



