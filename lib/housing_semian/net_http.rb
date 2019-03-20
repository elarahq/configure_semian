# module HousingSemian
  require 'net/http'
  require 'byebug'
  require 'semian'
  require 'semian/net_http'
  require '/home/dev/housing_semian/lib/housing_semian/semian_configuration.rb'
  module Net
    class HTTP

      alias_method :old_request, :request
      alias_method :old_post, :post

      def post(path, data, initheader = nil, dest = nil, &block)
        timeout = get_request_timeout_value(self.address, path)
        self.read_timeout = timeout
        # semian_config = SemianConfiguration.new(self.address, self.port, path)
        old_post(path, data, initheader, dest, &block)
      end

      def request(req, body = nil, &block)
        timeout = get_request_timeout_value(self.address, req.path)
        self.read_timeout = timeout
        # semian_config = HousingSemian::SemianConfiguration.initialize_semian(self.address, self.port)
        old_request(req, body, &block)
      end

      def get_request_timeout_value(host, path)
        if !HousingSemian::SemianConfiguration.service_configs[host.intern].nil?
          specs = HousingSemian::SemianConfiguration.service_configs[host.intern][path.intern]
          specs ||= HousingSemian::SemianConfiguration.service_configs[host.intern][:default]
        end
        specs ||= HousingSemian::SemianConfiguration.service_configs[:default]
        timeout = specs[:timeout] || specs['timeout']
        return timeout
      end
    end

  end
# end
