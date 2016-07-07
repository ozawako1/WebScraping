require "rubygems"
require "google/api_client"
require "google_drive"

# Authorizes with OAuth and gets an access token.
client = Google::APIClient.new
auth = client.authorization
auth.client_id = "53028217630-03oj5e4c3ph9dnlsu6umie1can2hvt1r.apps.googleusercontent.com" # Use My Client ID
auth.client_secret = "uLX21a71U70NKEDdY8PmCkRX" # Use My Client Secret
auth.scope =
    "https://www.googleapis.com/auth/drive " +
    "https://spreadsheets.google.com/feeds/"
auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
print("2. Enter the authorization code shown in the page: ")
auth.code = $stdin.gets.chomp
auth.fetch_access_token!
access_token = auth.access_token
refresh_token = auth.refresh_token

session = GoogleDrive.login_with_oauth(access_token)

puts "your access_token is:\n#{access_token}"
puts "----"

puts "your refresh_token is:\n#{refresh_token}"
puts "----"

session.files.each do |file|
  puts file.title
end
puts "----"

puts "done!"

