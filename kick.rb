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

kick.Go("/d/1gJFgb3Dr3c39qiFF-EypFLxdqEy6xQ5IEpO15gjvvi4/viewform")

kick.Execute("ss-form")

p kick.GetPage()