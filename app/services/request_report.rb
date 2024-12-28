# frozen_string_literal: true

module Services
  class RequestReport
    attr_accessor :data

    def initialize
      @report = {
        '>= 01ms < 10ms' => 0,
        '>= 10ms < 50ms' => 0,
        '>= 50ms < 100ms' => 0,
        '>= 100ms < 300ms' => 0,
        '>= 300ms < 500ms' => 0,
        '>= 500ms < 1000ms' => 0,
        '>= 1000ms < 1500ms' => 0,
        '>= 1500ms < 2000ms' => 0,
        '>= 2000ms' => 0,
        'errors' => 0
      }

      @status = {
        '1xx' => 0,
        '2xx' => 0,
        '3xx' => 0,
        '4xx' => 0,
        '5xx' => 0
      }

      @request_count = { 'requests' => 0 }
      @mutex = Mutex.new
      @logger = Logger.new($stdout)
    end

    def data=(value)
      @mutex.synchronize do
        evaluate_report(value)
        evaluate_status(value)
      end
    end

    def data
      @mutex.synchronize do
        @report.merge({ status: @status })
               .merge({ report: @report })
               .merge({ request_count: @request_count })
      end
    end

    private

    def evaluate_status(data)
      return if data[:status].nil?

      @logger.info(@request_count['requests'])
      @request_count['requests'] += 1

      case data[:status].to_s[0].to_i
      when 1 then @status['1xx'] += 1
      when 2 then @status['2xx'] += 1
      when 3 then @status['3xx'] += 1
      when 4 then @status['4xx'] += 1
      when 5 then @status['5xx'] += 1
      end
    end

    def evaluate_report(data)
      return if data[:request_time].nil?

      case data[:request_time]
      when 1...10 then @report['>= 01ms < 10ms'] += 1
      when 10...50 then @report['>= 10ms < 50ms'] += 1
      when 50...100 then @report['>= 50ms < 100ms'] += 1
      when 100...300 then @report['>= 100ms < 300ms'] += 1
      when 300...500 then @report['>= 300ms < 500ms'] += 1
      when 500...1000 then @report['>= 500ms < 1000ms'] += 1
      when 1000...1500 then @report['>= 1000ms < 1500ms'] += 1
      when 1500...2000 then @report['>= 1500ms < 2000ms'] += 1
      when 2000.. then @report['>= 2000ms'] += 1
      else
        @report['errors'] += 1
      end
    end
  end
end
