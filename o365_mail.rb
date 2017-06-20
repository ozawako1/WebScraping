require "mail"

def o365_mail_send(to_addr, cc_addr, subj, body)
    msg = Mail.new()

    msg.delivery_method(:smtp,
        address:    "smtp.office365.com",
        port:       587,
        domain:     "motex.co.jp",
        user_name:  "koichi.ozawa",
        password:   get_config("o365", "Password"),
        authentication: :login,
        enable_starttls_auto: true)


    msg.from = "koichi.ozawa@motex.co.jp"
    msg.to  = "koichi.ozawa@motex.co.jp"
    #msg.to  = to_addr
    #msg.cc = cc_addr
    msg.subject = subj
    msg.body = body

    msg.deliver

end

def send_mail_with_pjcode(to_addr, cc_addr, proj)

    body = ""
    body = sprintf("以下のプロジェクトコードを使用してください。\n\n" +
                "プロジェクト名: %s\n\n" +
                "プロジェクトコード: %s\n\n", proj.name, proj.code)

    
    o365_mail_send(to_addr, cc_addr, "プロジェクトコードが採番されました", body)

end