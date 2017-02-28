module Onduty
  class Icinga2
    require 'uri'
    require 'net/http'
    require 'openssl'

    def initialize(options = {})
      @api_path = options[:api_path] || "https://localhost:5665/v1"
      @user     = options[:user] || "admin"
      @password = options[:password] || "icinga2"
    end

    def acknowledge_services(services, options = {})
      status = 1
      ack = {}
      services.each do |service|
        ack = acknowledge_service(service, options)
        status = ack[:acknowledged] > status ? ack[:acknowledged] : status
      end
      {
        acknowledged: status,
        message: ack[:message],
        debug: ack[:debug]
      }
    end

    def acknowledge_service(service, options = {})
      comment = options[:comment] || "Acknowledged by Onduty"
      url = URI(
        @api_path +
        "/actions/acknowledge-problem?type=Service&filter=host.name=='#{service.host}',service.name=='#{service.service}'"
        # "/actions/acknowledge-problem?type=Service&host=#{service.host}&service=#{service.service}"
      )

      http = Net::HTTP.new(url.host, url.port)
      http.set_debug_output($stdout)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url)
      request.body = {
          author: "onduty",
          comment: comment,
          notify: true
      }.to_json
      request.basic_auth(@user, @password)
      request["Content-Type"] = "text/json"
      request["Accept"] = "application/json"

      begin
        case response = http.request(request)
        when Net::HTTPSuccess
          {
            acknowledged: 1,
            message: "The alert has been successfully acknowledeged.",
            debug: "response body: #{response.body}"
          }
        else
          {
            acknowledged: 0,
            message: "Error during alert acknowledgment.",
            debug: "response value: #{response.value}"
          }
        end
      rescue => e
        puts "ERROR: #{e.message}"
        puts e.backtrace
        {
          acknowledged: 2,
          message: "ERROR: Unable to contact the Icinga2 API (#{e.message})",
          debug: e.backtrace
        }
      end
    end

  end
end
