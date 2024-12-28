# frozen_string_literal: true

require_relative 'app/server'
require 'dotenv/load'

run Sinatra::Application
