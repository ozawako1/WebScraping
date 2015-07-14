#!/usr/bin/env ruby
# encoding: utf-8

require "mechanize"
require_relative "CWebApp"
require_relative "util"

use_proxy = 0
use_debug = 0
use_dump  = 0
b_date = ""
e_date = ""

if ARGV.length < 2 then
    puts("[ERROR] Insufficient Arg.")
    puts("\t$>ruby eco2csv.rb begin_date end_date")
    puts("\tbegin_date: YYYYMMDD")
    puts("\tend_date  : YYYYMMDD")
    puts("")
    exit
end

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    when "DUMP"
        use_dump = 1
    else
        if b_date == "" then
            b_date = Date.strptime(arg, "%Y%m%d")
        elsif e_date == "" then
            e_date = Date.strptime(arg, "%Y%m%d")
        else
            puts("undefined arg. [" + arg + "]")
            exit    
        end            
    end
}

# 設定ファイルからID/Password等を取得する
id = get_config("Eco","UserID")
pd = get_config("Eco","password")
pt = get_config("COMMON", "CSVPath")
login_info = Hash["UserID"=>id, "password"=>pd, "login"=>"1", "grsel"=>"-1"]
path = get_config("Eco", "Url")

site = CWebAppEco.new("http://192.168.103.149/LspEco", use_debug)
if site == nil
    puts("Init Error.")
    exit
end

begin
    # ECOにログイン
    puts("Log in Eco ...")
    site.Login("/cgi-bin/Eco.cgi", "loginf", login_info)
    
    # 検索により指定日のスケジュール一覧を取得
    puts("Getting Schedule from Eco ...")
    events = site.GetEvents(b_date, e_date)
    
    # 一覧の各スケジュールについて、詳細を取得し、配列に格納
    puts("Getting Schedule detail from Eco ...")
    arr = Array.new()
    events.each { | ev |
        arr.push(site.GetEventDetail(ev, MODE_GAROON))
    }
    
    # 配列をsCSVに出力
    puts("Flushing CSV ...")
    flush_to_csv(arr, pt + "eco2garoon.csv", true)
            
    puts("Success." + Time.now.strftime("%Y/%m/%d %H:%M:%S"))
    
rescue => e
    p e
    p e.backtrace
    p Time.now

	puts("Error." + e.message)
    
end



