#!/usr/bin/env ruby
# encoding: utf-8

require_relative "hv_export_user_hours"

subdomain = get_config("Harvest",	"SubDomain")
username  = get_config("Harvest",	"ID")
password  = get_config("Harvest",	"Password")

use_proxy = 0
use_debug = 0
use_dump  = 0
yyyy = 0
mm = 0

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    when "DUMP"
        use_dump = 1
    end
}

begin
    hv = Harvest.hardy_client(subdomain: subdomain, username: username, password: password)	
    
    export_user_hours_amoeba(hv, Time.now.year, Time.now.month, use_debug)

rescue => e
    p e
    p e.backtrace
end


