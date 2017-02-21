module Onduty
  class Icinga
    require 'net/http'

    def initialize(options = {})
      @cgi_path = options[:cgi_path] || "http://localhost/icinga/cgi-bin"
      @user     = options[:user] || "icingaadmin"
      @password = options[:password] || "icingaadmin"
    end

    def acknowledge_service(host, service, options = {})
      comment = options[:comment] || "Acknowledged from Onduty"
      uri = URI(@cgi_path + "/cmd.cgi")
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(
        "cmd_typ" => "34",
        "cmd_mod" => "2",
        "hostservice" => "#{host}^#{service}",
        "com_author" => "onduty",
        "com_data" => comment,
        "send_notification" => "on"
      )
      req.basic_auth @user, @password
      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
      case res
      when Net::HTTPSuccess
        puts res.body
        puts true
      else
        puts res.value
      end
    end

  end
end
