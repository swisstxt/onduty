module Onduty
  class Icinga2
    require 'uri'
    require 'net/http'
    require 'openssl'

    private_class_method :new

    def self.instance()
      return @instance if @instance

      @instance_mutex.synchronize do
        @instance ||= new(
          api_path: SETTINGS.icinga2_api_path,
          web_path: SETTINGS.icinga2_web_path,
          user: SETTINGS.icinga2_user,
          password: SETTINGS.icinga2_password,
        )
      end

      @instance
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
      url = URI(url_to_acknowledge(service))

      http = Net::HTTP.new(url.host, url.port)
      unless ENV["APP_ENV"] == "production"
        http.set_debug_output($stdout)
      end
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
          message: "Icinga2 API returned the following error: #{e.message}",
          debug: e.backtrace
        }
      end
    end

    def url_to_host(service)
      "#{@web_path}/monitoring/host/show?host=#{service.host}"
    end

    def url_to_service(service)
      "#{@web_path}/monitoring/service/show?host=#{service.host}&service=#{service.name}"
    end

    private

    SETTINGS = Onduty::SETTINGS
    @instance_mutex = Mutex.new

    def initialize(options = {})
      @api_path = options[:api_path] || "https://localhost:5665/v1"
      @web_path = options[:web_path] || "https://localhost:8080/icinga2web"
      @user     = options[:user] || "admin"
      @password = options[:password] || "icinga"
    end

    def url_to_acknowledge(service)
      "#{@api_path}/actions/acknowledge-problem?service=#{service_full_name(service)}"
    end

    def service_full_name(service)
      "#{service.host}!#{service.name}"
    end

  end
end
