
require "rubygems"
require "uri"

#require 'jira-ruby'

require_relative "util"

################################################################################
# Original API Reference
# https://github.com/sumoheavy/jira-ruby
# https://docs.atlassian.com/jira/REST/6.2.7/
################################################################################

class CWebAppJira
    attr_reader :http, :auth_header

    ########################## 
    # Constructor
    # base_url: Target Site. (eg. https://www.motex.co.jp/issue/)
    # dbg: set true / 1, if use Debug Mode.
    ########################## 
    def initialize(base_url, dbg = 0)

        uri = URI.parse(base_url)
        @http = Net::HTTP.new(uri.host, 443)
        @http.use_ssl = true
        @http.set_debug_output $stderr if dbg == 1

    end

    ########################## 
    # Service Login
    ########################## 
    def Login(userid, password)


        @auth_header = "Authorization: Basic " + Base64.encode64(userid + ":" + password) 
        
    end

    def get_projectid_by_key(project_key)


        @http.get()

        id = nil

        projects = @http.Project.all

        project = @http.Project.find(project_key)
        if (project == nil) then
            return id
        end
        
        id = project.id
        
        return id
    end

    ########################## 
    # Create Issue.
    ########################## 
    def Post(project, summary, description, issuetype)

        pid = get_projectid_by_key(project)
        iid = get_issueid_by_key(issuetype)

        issue = @http.Issue.build

    end

end

=begin
{
    "fields": {
       "project":
       { 
          "key": "TEST"
       },
       "summary": "REST ye merry gentlemen.",
       "description": "Creating of an issue using project keys and issue type names using the REST API",
       "issuetype": {
          "name": "Bug"
       }
   }
}
{
   "id":"39000",
   "key":"TEST-101",
    "self":"http://localhost:8090/rest/api/2/issue/39000"
}
=end

begin
    jira = CWebAppJira.new(get_config("Jira", "URL"), 1)

    jira.Login("koichi.ozawa", "Bu9GN8NhqAKqnTebUn")

    jira.Post("SRT", "", "", "")
rescue => e
    p e
end

