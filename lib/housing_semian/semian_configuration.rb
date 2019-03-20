require 'deep_dup/core_ext/object'
module HousingSemian
  class SemianConfiguration
    attr_accessor :host, :port, :path, :data

    # Singleton Object associated with Semian Configuration that has various specifications for Semian initialization
    class SemianParameters
      attr_accessor :app_server, :service_configs, :free_hosts, :track_exceptions, :service_name

      SEMIAN_PARAMETERS = {
                      semian_default: {
                        quota: 0.75,
                        success_threshold: 2,
                        error_threshold: 3,
                        error_timeout: 10,
                        timeout: 10,
                        bulkhead: false
                      }
                    }

      def initialize
        @app_server = false
        @service_configs = SEMIAN_PARAMETERS
        @free_hosts = []
        @track_exceptions = ['Net::ReadTimeout']
        @service_name = nil
      end

      # Passed true only for app server so that bulkheading is disabled in worker servers
      def app_server=value
        @app_server = value
        self.service_configs[:semian_default][:bulkhead] = value
      end

      # semian options alongwith the ones defined by the service
      def service_configs=value
        self.service_configs.merge!(value)
      end

      # exceptions to be tracked defined by the service 
      def track_exceptions=value
        self.track_exceptions |= value
      end

      # initial computations
      def generate_specifications
        # Define exceptions to be tracked by Semian
        Semian::NetHTTP.exceptions |= self.track_exceptions
        # Create the complete host,path driven semian options
        semian_default = self.service_configs.delete(:semian_default)
        service_default = semian_default.merge(self.service_configs.delete(:default) || self.service_configs.delete('default') || {})
        self.service_configs.each do |host, specs|
          host_default = service_default.merge(specs.delete(:default) || specs.delete('default') || {})
          # self.service_configs[host.intern] = service_default.merge(specs)
          specs.each do |path, path_specs|
            self.service_configs[host.intern][path.intern] = host_default.merge(path_specs)
          end
          self.service_configs[host.intern][:default] = host_default
        end
        self.service_configs.merge!({semian_default: semian_default, default: service_default})
      end

    end

    @@semian_parameters = SemianParameters.new

    ::Semian::NetHTTP.semian_configuration = proc do |host, port|
      if !self.free_hosts.include?(host)
        semian_options = get_semian_parameters(host, port)
        semian_options
      else
        nil
      end
    end

    # def initialize(host, port, path, data)
    #   @host = host
    #   @port = port
    #   @path = path
    #   @data = data
    #   initialize_semian
    # end

    # def self.initialize_semian(host, port)
    #   if !self.host.nil? and self.host.is_a?(String)
    #     Semian::NetHTTP.semian_configuration.call(host, port)
    #   end
    # end

    def self.get_semian_parameters(host, port)
      # resource_name = "testing1"
      resource_name = "#{self.service_name}_#{host}"
      parameters = self.service_configs[host.intern].nil? ? self.service_configs[:default] : self.service_configs[host.intern][:default]
      # semian_parameters[:open_circuit_server_errors] = false if semian_parameters[path.intern].present?
      parameters.merge!({name: resource_name})
      semian_parameters = parameters.deep_dup
      semian_parameters.delete(:timeout)
      semian_parameters.delete('timeout')
      semian_parameters
    end

    def self.configure_client
      yield(@@semian_parameters)
      raise "Service Name not specified for Semian Configuration" if self.service_name.nil?
      @@semian_parameters.generate_specifications
    end

    @@semian_parameters.instance_variables.each do |variable|
      attribute = variable.to_s.delete('@')
      self.define_singleton_method(attribute) do
        return @@semian_parameters.instance_variable_get(variable)
      end
    end

  end
end