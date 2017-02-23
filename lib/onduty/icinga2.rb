module Onduty
  class Icinga2
    require 'uri'
    require 'net/http'

    def initialize(options = {})
      @api_path = options[:api_path] || "http://localhost:5665/v1"
      @user     = options[:user] || "icingaadmin"
      @password = options[:password] || "icingaadmin"
    end

    def acknowledge_services(services, options = {})
      status = true
      status = services.each do |service|
        acknowledge_service(service, options) && status
      end
    end

    def acknowledge_service(service, options = {})
      comment = options[:comment] || "Acknowledged from Onduty"
      query_string = "?type=Service&filter=service.name=#{service.name}"
      uri = URI(
        @api_path +
        "/actions/acknowledge-problem?#{query_string}"
      )
      req = Net::HTTP::Post.new(uri)
      req.set_form_data(
        "author" => "onduty",
        "comment" => comment,
        "notify" => true
      )
      req.basic_auth @user, @password
      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(req)
      }
      case res
      when Net::HTTPSuccess
        puts res.body
        true
      else
        puts res.value
        false
      end
    rescue => e
      puts e.message
      # TODO silently fails on exception
      true
    end

  end
end
