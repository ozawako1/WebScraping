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

kick.Go("/d/1GW_KDM9HzQ0vyFWY3dku2LaK8BZaio9KX1EFrm1C4Mc/viewform")

kick.SetForm("ss-form", [["entry.1934995328","ss2cal"]])

kick.Execute("ss-form")

p kick.GetPage()