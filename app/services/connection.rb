# frozen_string_literal: true

require 'faraday'
require 'logger'
require 'colorize'

module Services
  class Connection
    def initialize(url:, body:, headers:, method:, params:)
      @url = url
      @body = body
      @headers = headers
      @method = method
      @params = params
      @conn = Faraday.new
      @logger =  Logger.new($stdout)
    end

    def request
      start_time = Time.now

      response = conn.send(method.downcase) do |req|
        req.url url
        header(req)
        param(req)
        req.body = body.to_json
      end

      end_time = Time.now - start_time

      metric(end_time * 1000, response.status, response.body)
    end

    def metric(request_time, status, body)
      @logger.info("#{request_time} - Status: #{status} Body: #{body}".colorize(:yellow))

      { request_time: request_time, status: status, body: body }
    end

    def header(request)
      headers.each do |header|
        key = header.keys[0]
        request.headers[key] = header[key]
      end
    end

    def param(request)
      return unless params

      params.each do |param|
        key = param.keys[0]
        request.params[key] = param[key]
      end
    end

    private

    attr_reader :url, :body, :headers, :conn, :method, :params
  end
end
