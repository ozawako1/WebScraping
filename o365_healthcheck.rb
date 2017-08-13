#!/usr/bin/env ruby
# encoding: utf-8

require "uri"
require "net/http"
require "JSON"
require "jwt"

dbg = 1

begin
    uri = URI.parse("https://login.windows.net/")
    net = Net::HTTP.new(uri.host, 443)
    net.use_ssl = true
    net.set_debug_output $stderr if dbg == 1

    req = Net::HTTP::Post.new("/common/oauth2/token")
    req.set_form_data({"resource" => "https://manage.office.com",
                        "client_id" => "0fc9e90f-7e78-44fe-b655-22fcbd40f9e8",
                        "redirect_uri" => "https://tekito.motex.co.jp/o365hc", #= http%3A%2F%2Fwww.mycompany.com%2Fmyapp%2F
                        "client_secret" => "a68oM0w4Hc64apdFMwUCg41Tros9Tj2jcl4OAv+LqHE=",
                        "grant_type" => "authorization_code",
                        "code" => "AQABAAIAAAA9kTklhVy7SJTGAzR-p1Bc3vfvgqfj4c_Z-090W9HJWzvJhpcHTOpwp-o6Oa4GYw-5JCq_BgmnjHJOTWFfrK1T_HmiFAl48qUOVVB9qTMJJvmcU-rbXJmB1Z70dwvdXYhW0m4BeSPcJgY0Bs5RrYf92rsDpqbjxh7eH2PY6SJBadTrCyJ9nAqu-KVwY_Lv8mV1FQAVkvpXDJ_ZgzhFhTK3BxVSIC8lp5IUNIoJRhZ60ZafCZ84FcKzGSIslg_sKd43Z2CJZo2euEgQChfbY7O8iOUcfbnsaK09B8LPwoNHA3J-8vBCfXwRTJR248Z0VBTVbMZMuGpP50imGk7R9ileUIqLZL04ksz_zb9DIzPHJxk_xjzXVcerdAaYU-dAXNBTlJlFSzVHOD0o5VqraznPpiCmceAMATGJO3WS6rp-rdmDf9LBz2ZhN6iMev_EG1QTwDbaaryUDSLEtligb57nw1LM--dKT3oIZdLAAL7Ai5npqEHWhEj-RM51XxyKBk5QTfGkqfUnT48QgDlgwyje3eZlLry65_fv_egR8kXBpVMBrVl-7LhbeFnx2pVSKsnHjyCRrX6_6V17MuS18qrSxfEMaBJdfHRsC3rd6BVQQslbAvYByuKmSFoClCUjJXAs_iysM_xgWodHTwR4r4ZDwi0SyEtiBzv-uqtyoP9X0uGqJlcpG_3JmYauRLN0sF4gAA"
                    })
    res = net.request(req)

    jarr = JSON.parse(res.body)
    p jarr if dbg == 1

    at = jarr["access_token"]
    decode_at = JWT.decode(at, nil, false)

    p "JWT Decoded..."
    p decode_at if dbg == 1

    tenant_id = decode_at[0]["tid"]

#    tid = "efa9a9e1-c3d8-424e-acf5-574179cea8b1"

    uri2 = URI.parse("https://manage.office.com/")
    net2 = Net::HTTP.new(uri2.host, 443)
    net2.use_ssl = true
    net2.set_debug_output $stderr if dbg == 1
    res2 = net2.get("/api/v1.0/" + tenant_id + "/ServiceComms/CurrentStatus", {"Authorization" => "Bearer " + at})
    jarr = JSON.parse(res2.body)
    p jarr if dbg == 1

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
https://tekito.motex.co.jp/o365hc?code=
https://tekito.motex.co.jp/o365hc?code=

&session_state=89105fac-583c-4be5-8c8f-0d42d5acf46d
AQABAAIAAAA9kTklhVy7SJTGAzR-p1BceMPdnSkQL0Zy3kIB7SiebZFmE-YzlmFJ879hhvUb_ueSc-vyP34PET3L9tJNYqmDsoR0Wtv6jk9ewG9azV29TEOivUzzpObGod-Oz277AS0QQIVafOwQpTsxvG_T9yyjuVOue5uFKuBPjkqu3IZYy4AJg0K0BoJRNU3ib55G2bq7EVMhqDzQbnjX8AVo3PhXNSSEzDQ6LehP1yq3jiqb5nJjBiK19HHIAn8yLGsqKlgA9Qk7ZxSum3Zj7X9lpkXurYqmNsmd7ygm51V38OwwevNweDDhovI6-o0jbHs7U0VN3XiUaf5LRN6uPkZ9grRKqNmwf0X8pXJTcAixn-BsNqOr_M6a5bbLMnv8HKinvGsP2Si2F4erSC1jehlXg7QvT2EhCzurKcxc45uWj69pX3pIIfvvEjImoqeQ9-1C_YgH9Unv0lIjBJX5d_62ZbmXXpgHJmHa27EuLKQChU5Cvuj3KUWp186nt4Y7nq0U5mbBlMuE_BkUcnKatxV3R9W1BlKaXUPthIb4aEncEQL7TiGrL5b1dfkSiKU-CIWeOBX-SZ2QGLYafEmhCcvZwlBcm7yFdButjW10ViFS4HT8OecDQAKrgKbiNrbkZBXUEYfiH4viPZ6gT55JUq0OnA7tJSi3OHufnFbnhfkgBoMRAYTe-ZIugxtG3n7umRNrw38gAA
&session_state=89105fac-583c-4be5-8c8f-0d42d5acf46d

=end

