# frozen_string_literal: true

require 'erb'
require 'logger'
require 'colorize'

module Services
  class CreateResultFile
    RESULT_FILEPATH = 'templates/result.erb'
    INFO = 'The test ended successfully, file with the results:'

    def initialize(filepath, data, start_datetime, end_datetime)
      @data = data
      @start_datetime = start_datetime
      @end_datetime = end_datetime
      @filepath = File.dirname(filepath)
      @logger = Logger.new($stdout)
    end

    def call
      File.open(filename, 'w') do |file|
        file.puts ERB.new(file_content).result(binding)
      end

      logger.info("#{INFO} #{filename}".colorize(:green))
    rescue => e
      logger.error(e.colorize(:red))
    end

    private

    def filename
      now = DateTime.now.strftime('%d_%m_%Y_%H_%M_%S')
      "#{@filepath}/#{now}.html"
    end

    def file_content
      @file_content ||= File.open(RESULT_FILEPATH).read
    end

    attr_reader :data, :start_datetime, :end_datetime, :logger
  end
end
