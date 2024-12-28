# frozen_string_literal: true

require 'logger'
require 'colorize'
require_relative 'connection'
require_relative 'request_report'
require_relative 'create_result_file'

module Services
  class Request
    def initialize(filepath:)
      @filepath = filepath
      @logger = Logger.new($stdout)
      @request_count = content['request_count'].to_i
      @request_thread = content['request_thread'].to_i
      @request_report = ::Services::RequestReport.new
    end

    def call
      start = Time.now
      request_thread

      ::Services::CreateResultFile.new(@filepath, @request_report.data, start, Time.now).call
    end

    private

    def request_thread
      count = @request_count / @request_thread
      threads = []
      index = 0

      (1..@request_thread).each do
        threads << Thread.new do
          index += 1
          (1..count).each do |_index|
            request
          end
        end
      end

      threads.each(&:join)
    end

    def request
      @request_report.data = connection_service.request
    rescue Faraday::ConnectionFailed => e
      error_metric(e, 'Connection Failed Error')
    rescue Faraday::TimeoutError => e
      error_metric(e, 'Timeout request error')
    rescue StandardError => e
      error_metric(e, e.message)
    end

    def connection_service
      Services::Connection.new(
        url: content['url'],
        headers: content['headers'],
        body: content['body'],
        method: content['method'],
        params: content['params']
      )
    end

    def content
      JSON.parse(File.open(@filepath).read)
    rescue Errno::ENOENT
      @logger.error('arquivo não encontrado')
      nil
    end

    def error_metric(error, message)
      @logger.error(error.message.colorize(:red))

      @request_report.data = { status: 'error', request_time: -1, message: message }
    end
  end
end
