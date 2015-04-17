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

    agent = Mechanize.new
    agent.user_agent = "My User Agent"

    kick = CWebApp.new(agent, "https://docs.google.com/forms", 0)
    if (kick ==nil)
        puts("Google Init Error.")
        exit
    end

    kick.Go("/d/1zuj8DEgB15syssNb1izsIA3S4X8KBnduLTNTwVhYeCI/viewform")
    kick.SetForm("ss-form", [["entry.132136151", ball]])
    kick.Execute("ss-form")

rescue => e
    p e
    p e.backtrace
    p Time.now

end
