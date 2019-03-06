module HousingSemian
  class Net::HTTP

    alias_method :request, :old_request
    alias_method :post, :old_post

    def post(path, data, initheader = nil, dest = nil, &block)
      semian_config = SemianConfiguration.new(self.address, self.port, path, data)
      old_post(path, data, initheader, dest, &block)
    end

    def request(req, body = nil, &block)
      semian_config = SemianConfiguration.new(self.address, self.port, path, data)
      old_request(req, body, &block)
    end

  end
end

