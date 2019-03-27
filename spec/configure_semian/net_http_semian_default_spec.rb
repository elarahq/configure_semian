require 'yaml'
RSpec.describe do
  describe 'check net http patch functionality for the gem' do

    context 'read timeout for semian default' do

      before(:all) do
        ConfigureSemian::SemianConfiguration.configure_client{|ob|
          ob.service_name = 'default_semian'
          ob.service_configs = {}
        }
      end

      it 'should return correct read timeout for semian default' do
        uri = URI('http://test.randomhost.com/testpath')
        net_http = Net::HTTP.new(uri.host, uri.port)
        read_timeout = net_http.get_request_timeout_value(uri.host, uri.path)
        expect(read_timeout).to eq(10)
      end
    end
  end
end
