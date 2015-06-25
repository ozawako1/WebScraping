#!/usr/bin/env ruby
# encoding: utf-8

SOURCE = "https://7vhc3.cybozu.com/g/index.csp?WSDL"

=begin
This XML file does not appear to have any style information associated with it. The document tree is shown below.
<definitions xmlns="http://schemas.xmlsoap.org/wsdl/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:tns="http://wsdl.cybozu.co.jp/api/2008" xmlns:base_services="http://wsdl.cybozu.co.jp/base/2008" xmlns:schedule_services="http://wsdl.cybozu.co.jp/schedule/2008" xmlns:address_services="http://wsdl.cybozu.co.jp/address/2008" xmlns:workflow_services="http://wsdl.cybozu.co.jp/workflow/2008" xmlns:mail_services="http://wsdl.cybozu.co.jp/mail/2008" xmlns:message_services="http://wsdl.cybozu.co.jp/message/2008" xmlns:notification_services="http://wsdl.cybozu.co.jp/notification/2008" xmlns:cbwebsrv_services="http://wsdl.cybozu.co.jp/cbwebsrv/2008" xmlns:report_services="http://wsdl.cybozu.co.jp/report/2008" xmlns:cabinet_services="http://wsdl.cybozu.co.jp/cabinet/2008" xmlns:admin_services="http://wsdl.cybozu.co.jp/admin/2008" xmlns:util_api_services="http://wsdl.cybozu.co.jp/util_api/2008" xmlns:star_services="http://wsdl.cybozu.co.jp/star/2008" xmlns:bulletin_services="http://wsdl.cybozu.co.jp/bulletin/2008" name="GaroonServices" targetNamespace="http://wsdl.cybozu.co.jp/api/2008">
<wsdl:import namespace="http://wsdl.cybozu.co.jp/base/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/base.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/schedule/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/schedule.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/address/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/address.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/workflow/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/workflow.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/mail/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/mail.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/message/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/message.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/notification/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/notification.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/cbwebsrv/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/cbwebsrv.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/report/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/report.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/cabinet/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/cabinet.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/admin/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/admin.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/util_api/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/util_api.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/star/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/star.wsdl"/>
<wsdl:import namespace="http://wsdl.cybozu.co.jp/bulletin/2008" location="https://static.cybozu.com/g/F6.0.246_5.6/api/2008/bulletin.wsdl"/>
<service name="BaseService">
<port name="BasePort" binding="base_services:BaseBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/base/api.csp?"/>
</port>
</service>
<service name="ScheduleService">
<port name="SchedulePort" binding="schedule_services:ScheduleBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/schedule/api.csp?"/>
</port>
</service>
<service name="AddressService">
<port name="AddressPort" binding="address_services:AddressBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/address/api.csp?"/>
</port>
</service>
<service name="WorkflowService">
<port name="WorkflowPort" binding="workflow_services:WorkflowBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/workflow/api.csp?"/>
</port>
</service>
<service name="MailService">
<port name="MailPort" binding="mail_services:MailBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/mail/api.csp?"/>
</port>
</service>
<service name="MessageService">
<port name="MessagePort" binding="message_services:MessageBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/message/api.csp?"/>
</port>
</service>
<service name="NotificationService">
<port name="NotificationPort" binding="notification_services:NotificationBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/notification/api.csp?"/>
</port>
</service>
<service name="CybozuWebSrvService">
<port name="CBWebSrvPort" binding="cbwebsrv_services:CBWebSrvBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/cbwebsrv/api.csp?"/>
</port>
</service>
<service name="ReportService">
<port name="ReportPort" binding="report_services:ReportBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/report/api.csp?"/>
</port>
</service>
<service name="CabinetService">
<port name="CabinetPort" binding="cabinet_services:CabinetBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/cabinet/api.csp?"/>
</port>
</service>
<service name="AdminService">
<port name="AdminPort" binding="admin_services:AdminBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/sysapi/admin/api.csp?"/>
</port>
</service>
<service name="UtilService">
<port name="UtilPort" binding="util_api_services:UtilBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/util_api/util/api.csp?"/>
</port>
</service>
<service name="StarService">
<port name="StarPort" binding="star_services:StarBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/star/api.csp?"/>
</port>
</service>
<service name="BulletinService">
<port name="BulletinPort" binding="bulletin_services:BulletinBinding">
<soap12:address location="https://7vhc3.cybozu.com/g/cbpapi/bulletin/api.csp?"/>
</port>
</service>
</definitions>

=end
