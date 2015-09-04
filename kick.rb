require "mechanize"
require_relative "CWebApp"
require_relative "util"

use_proxy = 0
use_debug = 0

ball = ""

ARGV.each { |arg|
    case arg
    when "PROXY"
        use_proxy = 1
    when "DEBUG"
        use_debug = 1
    else
        ball = arg
    end
}

if ball == ""
    puts("ARGV Must Be Defined.")
    exit
end


begin

    gas = CWebAppGoogle.new("mygas", 0)
    if (gas ==nil)
        puts("Google Init Error.")
        exit
    end

    gas.Kick_("/d/1zuj8DEgB15syssNb1izsIA3S4X8KBnduLTNTwVhYeCI/viewform", ball)

rescue => e
    p e
    p e.backtrace
    p Time.now

end

