#!/usr/bin/env ruby
# encoding: utf-8

require_relative "CWebApp"
require_relative "proc"

COUNTPERPAGE = 20

use_proxy = 0
use_debug = 0
use_dump  = 0

def get_pages(number)
    pages = 0
    
    pages = (number / COUNTPERPAGE)
    if (number % COUNTPERPAGE) > 0 then
        pages +=  1
    end
    
    return pages
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
        puts("undefined arg. [" + arg + "]")
    end
}

dlive = CWebApp.new("http://search.dartslive.jp", use_debug)

=begin
prefs = Array.new(["北海道", "青森県", "岩手県", "秋田県", "宮城県", "福島県", "山形県",
                  "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
                  "新潟県", "長野県", "山梨県", "静岡県", "愛知県", "岐阜県", "富山県", "石川県", "福井県",
                  "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "三重県",
                  "岡山県", "広島県", "山口県", "鳥取県", "島根県", "香川県", "徳島県", "高知県", "愛媛県",
                  "福岡県", "大分県", "宮崎県", "鹿児島県", "熊本県", "長崎県", "佐賀県", "沖縄県"])
=end
prefs = Array.new(["滋賀県"])


list = Array.new()

prefs.each { |pref|
    dlive.Go("/list/"+ pref)

    count = dlive.GetItem(".number")[0].inner_text.to_i

    i = 0
    while i < get_pages(count) do
        dlive.Go("/list/"+ pref + "?p=" + i.to_s)
        list.concat(dlive.Table2Array("div.searchList2") )
        i += 1
    end    
}

p list if use_debug == 1
p list.count if use_debug == 1

# flush_to_csv(list, "/Users/ozawako1/develop/output/dlivelist.csv")




