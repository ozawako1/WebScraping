require "mechanize"
require_relative "CWebApp"
require_relative "util"

agent = Mechanize.new
agent.user_agent = "My User Agent"

kick = CWebApp.new(agent, "https://docs.google.com/forms", 0)
if (kick ==nil)
    puts("Google Init Error.")
    exit
end

kick.Go("/d/1zuj8DEgB15syssNb1izsIA3S4X8KBnduLTNTwVhYeCI/viewform")

kick.SetForm("ss-form", [["entry.132136151","ss2mail"]])

kick.Execute("ss-form")

p kick.GetPage()
