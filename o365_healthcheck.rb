#!/usr/bin/env ruby
# encoding: utf-8

require "uri"
require "net/http"
require "JSON"
require "jwt"
require_relative "CWebApp"

dbg = 1

begin

    o365 = CWebAppO365.new("https://manage.office.com/", 1)

    o365.makejwt()

    o365.Prep()
    
    status = o365.GetCurrentStatus()

    p status if dbg == 1

rescue => e
    p e
    p e.backtrace
    p Time.now

end

=begin
req = Net::HTTP::Post.new("/v2/rooms/" + room_id.to_s + "/messages")

req["X-ChatWorkToken"] = @token

req.set_form_data({"body" => msg})

res = @http.request(req)
if (res.code != "200") then
    raise "Error. post message error." + res.code
end

https://login.windows.net/common/oauth2/authorize?response_type=code&resource=https%3A%2F%2Fmanage.office.com&client_id=0fc9e90f-7e78-44fe-b655-22fcbd40f9e8&redirect_uri=https://tekito.motex.co.jp/o365hc

https://tekito.motex.co.jp/o365hc?code=
https://tekito.motex.co.jp/o365hc?code=
AQABAAIAAAA9kTklhVy7SJTGAzR-p1BcjO6V2rNdOZdFpHOUa7LQdvz55T7IeAucYQwgwi_-bJgTlCtjuOwn-4karTWYy5RpnN5xVvb5opNDueGNtvURTwIcPgrF0BIASAY8pBh2yBVoRs_bWt3Zg6J0VtMjIBagoP76z-C2ofJqHd71vbr_nruSkHSOPgwFO9bv-F3tjxt8oQaNMwIKNoan2zsMq5pzJIlT_-nX_6DZuEDN9slFYMIVUX1Lj60LggpZDMrfuUTCG-OUGfP0KMeBzQ649Vpdx7LhPydR3U2xTLX_pCdkkxe0OXEUr4GGPp-K2CuiVvJ-3ID6cX3edBJjh_KVrX1qUI2PE8n_iyX_jGJYyZcfzvBNH3ufkqzLKwCrMCWvK0OvoCr-B5RcKTMCsttXeYfO8LGe4jt3vOPAmLU_z_HUN3qU4PYlcucjRP-lCGLu3sRjoLUw2gK_qOm-XA7SJ7eJIzRKc2rGI_GQTCy5QGx0wkk4L5SRUPUYXC2XpiJo86U3Lo5lmminc_SBO4OoON7cUkNfQDERpkdl2s36Xig7J5dvGMKKz9IK1F6s9tTVgKjuUJiPUqImAsFG6B245PtEL_hJmtpynki7Hlw7iL-A7avYGfDNhlry-wPSHZCHCboQDJi_GhpLD2FAq02eJwQQbIpVvKrzL6NVf3g8VvxjSTTHgtl1Ck08Mx3kNzUOpEm6q9XUNCvE90TdbPZREG8HIAA
&session_state=730af77e-0179-46c5-ae6e-8e164266b33c
AQABAAIAAAA9kTklhVy7SJTGAzR-p1BceMPdnSkQL0Zy3kIB7SiebZFmE-YzlmFJ879hhvUb_ueSc-vyP34PET3L9tJNYqmDsoR0Wtv6jk9ewG9azV29TEOivUzzpObGod-Oz277AS0QQIVafOwQpTsxvG_T9yyjuVOue5uFKuBPjkqu3IZYy4AJg0K0BoJRNU3ib55G2bq7EVMhqDzQbnjX8AVo3PhXNSSEzDQ6LehP1yq3jiqb5nJjBiK19HHIAn8yLGsqKlgA9Qk7ZxSum3Zj7X9lpkXurYqmNsmd7ygm51V38OwwevNweDDhovI6-o0jbHs7U0VN3XiUaf5LRN6uPkZ9grRKqNmwf0X8pXJTcAixn-BsNqOr_M6a5bbLMnv8HKinvGsP2Si2F4erSC1jehlXg7QvT2EhCzurKcxc45uWj69pX3pIIfvvEjImoqeQ9-1C_YgH9Unv0lIjBJX5d_62ZbmXXpgHJmHa27EuLKQChU5Cvuj3KUWp186nt4Y7nq0U5mbBlMuE_BkUcnKatxV3R9W1BlKaXUPthIb4aEncEQL7TiGrL5b1dfkSiKU-CIWeOBX-SZ2QGLYafEmhCcvZwlBcm7yFdButjW10ViFS4HT8OecDQAKrgKbiNrbkZBXUEYfiH4viPZ6gT55JUq0OnA7tJSi3OHufnFbnhfkgBoMRAYTe-ZIugxtG3n7umRNrw38gAA
&session_state=89105fac-583c-4be5-8c8f-0d42d5acf46d

=end

