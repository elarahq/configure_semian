require 'net/http'
module Net
  class HTTP

    alias_method :old_request, :request
    alias_method :old_post, :post

    def request(req, body = nil, &block)
      timeout = get_request_timeout_value(self.address, req.path)
      self.read_timeout = timeout
      old_request(req, body, &block)
    end

    def get_request_timeout_value(host, path)
      path = process_request_path(path)
      if !ConfigureSemian::SemianConfiguration.service_configs[host.intern].nil?
        specs = ConfigureSemian::SemianConfiguration.service_configs[host.intern][path.intern]
        specs ||= ConfigureSemian::SemianConfiguration.service_configs[host.intern]["/#{path}".intern]
        specs ||= ConfigureSemian::SemianConfiguration.service_configs[host.intern][:default]
      end
      specs ||= ConfigureSemian::SemianConfiguration.service_configs[:default]
      timeout = specs[:timeout] || specs['timeout']
      return timeout
    end

    private
    def process_request_path(path)
      path = path.split('?').first
      path.gsub('//',"\/")
    end
  end

end
