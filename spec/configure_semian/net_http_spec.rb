require 'rspec'
require 'configure_semian/semian_configuration'
require 'configure_semian/net_http'
require 'yaml'
RSpec.describe do
  describe 'check net http patch functionality for the gem' do

    context 'read timeout for service specifics' do

      before(:all) do
        ConfigureSemian::SemianConfiguration.configure_client{|ob|
          ob.app_server = false
          ob.service_configs = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),'test_specs.yml'))
          ob.service_name = 'spec_tests'
          ob.free_hosts = ['test.freehost.com']
        }
      end

      it 'should return correct read timeout for service default' do
        uri = URI('http://test.randomhost.com/testpath')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)
        expect(read_timeout).to eq(25)
      end

      it 'should return correct read timeout for given host' do
        uri = URI('http://test.givenhost.com/testpath')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)
        expect(read_timeout).to eq(8)
      end

      it 'should return correct read timeout for given path' do
        uri = URI('http://test.givenhost.com/givenpath')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)
        expect(read_timeout).to eql(11)
      end

      it 'should return correct read timeout for free host' do
        uri = URI('http://test.freehost.com/testpath')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)
        expect(read_timeout).to eql(16)
      end
    end
  end
end

