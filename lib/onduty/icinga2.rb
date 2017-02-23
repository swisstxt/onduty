module Onduty
  class Icinga2
    require 'uri'
    require 'net/http'

    def initialize(options = {})
      @api_path = options[:api_path] || "https://localhost:5665/v1"
      @user     = options[:user] || "admin"
      @password = options[:password] || "icinga"
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

      http = Net::HTTP::Post.new(uri)
      http.set_form_data(
        "author" => "onduty",
        "comment" => comment,
        "notify" => true
      )
      http.basic_auth @user, @password
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      case response = Net::HTTP.start(uri.hostname, uri.port) do |session|
        session.request(http)
      end
      when Net::HTTPSuccess
        puts response.body
        true
      else
        puts response.value
        false
      end
    rescue => e
      puts e.message
      # !! silently fails on exceptions
      true
    end

  end
end
