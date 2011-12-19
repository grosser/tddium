# Copyright (c) 2011 Solano Labs All Rights Reserved

require 'mimic'

module Mimic
  class FakeHost
    class StubbedRequest
      def unmatched_response
        res = [404, {}, '{"status":1, "explanation":"not found"}']
        puts "unmatched: #{res}"
        res
      end

      def matches?(request)
        if @params.any?
          puts "checking params... got: #{request.params.inspect}, expected: #{@params.inspect}"
          request.params == @params
        else
          true
        end
      end
    end
  end
end

require 'antilles/cucumber'

port = Antilles.find_available_port
ENV['TDDIUM_CLIENT_PORT'] = port.to_s
ENV['TDDIUM_CLIENT_ENVIRONMENT'] = 'mimic'

Antilles.configure do |server|
  server.log = STDOUT
  server.port = port
end
