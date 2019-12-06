require 'rspec'
require 'configure_semian/semian_configuration'
require 'configure_semian/net_http'
require 'yaml'
RSpec.describe do
  describe 'check net http patch functionality for the gem' do

    before(:each) do
      ConfigureSemian::SemianConfiguration.configure_client{|ob|
        ob.app_server = true
        ob.service_configs = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),'test_specs.yml'))
        ob.service_name = 'spec_tests'
        ob.free_hosts = ['test.freehost.com']
      }
    end

    context 'read timeout for service specifics' do

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

    context 'read timeout for service specifics with request params' do

      let!(:path) {'givenpath-with-params?a=b'}

      it 'should return correct read timeout for given host with forward /' do
        uri = URI('http://test.givenhost.com/givenpath-with-params?a=b')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.request_uri)
        expect(read_timeout).to eql(20)
      end

      it 'should return correct read timeout for given host without forward /' do
        uri = URI('http://test.givenhost.com/givenpath-with-params?a=b')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, path)
        expect(read_timeout).to eql(20)
      end

    end

    context 'read timeout for service specifics without request params' do

      let!(:path) {'givenpath-without-params'}

      it 'should return correct read timeout for given host with forward /' do
        uri = URI('http://test.givenhost.com/givenpath-without-params')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.request_uri)
        expect(read_timeout).to eql(15)
      end

      it 'should return correct read timeout for given host without forward /' do
        uri = URI('http://test.givenhost.com/givenpath-without-params')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, path)
        expect(read_timeout).to eql(15)
      end
    end

    it 'should return same timeout with double slash url as with single slash url' do
      uri = URI('http://test.givenhost.com/nested/testpath')
      net_http = Net::HTTP.new(uri.host, uri.port)
      single_slash_read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)

      uri = URI('http://test.givenhost.com//nested//testpath')
      net_http = Net::HTTP.new(uri.host, uri.port)
      double_slash_read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)

      expect(single_slash_read_timeout).to eql(10)
      expect(single_slash_read_timeout).to eql(double_slash_read_timeout)
    end

    it 'should return same timeout with forward / path as without /' do
      uri = URI('http://test.givenhost.com/givenpath-without-slash')
      net_http = Net::HTTP.new(uri.host, uri.port)
      read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)
      expect(read_timeout).to eql(5)
    end

  end
end

