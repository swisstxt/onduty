module Onduty
  class Icinga
    require 'net/http'

    def self.icinga_cmd_path
      if defined? settings
        return settings.icinga_cmd_path if settings.respond_to?(:icinga_cmd_path)
      end
      "/var/run/icinga2/cmd/icinga2.cmd"
    end

    def initialize(options = {})
      @cgi_path = options[:cgi_path] || "http://localhost/icinga/cgi-bin"
      @user     = options[:user] || "icingaadmin"
      @password = options[:password] || "icingaadmin"
    end

    def acknowledge_service(host, service, options = {})
      comment = options[:comment] || "Acknowledged from Onduty"
      if options[:cgi]
        acknowledge_service_cgi(host, service, comment)
      else
        acknowledge_service_command(host, service, comment)
      end
    end

    def acknowledge_service_command(host, service, comment)
      now = Time.now
      command = "[#{now.to_i}] ACKNOWLEDGE_SVC_PROBLEM;#{host};#{service};1;1;onduty;#{comment}"
      begin
        File.open(Icinga.icinga_cmd_path, 'a') do |pipe|
          pipe.puts command
          pipe.close
        end
      rescue => e
        puts e.message
        return nil
      end
      now
    end

    def acknowledge_service_cgi(host, service, comment)
      uri = URI(@cgi_path + "/cmd.cgi")
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(
        "cmd_typ" => "34",
        "cmd_mod" => "2",
        "hostservice" => "#{host}^#{service}",
        "com_author" => "onduty",
        "com_author" => "on",
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
