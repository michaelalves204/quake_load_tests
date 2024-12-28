# frozen_string_literal: true

require 'rake'
require 'logger'
require_relative 'app/services/request'

logger = Logger.new($stdout)

desc 'Executar teste de carga'
task :quake do
  puts 'Informe o path do arquivo que contem as configurações de teste'
  puts 'Exemplo: test_endpoint/default.json'

  filepath = $stdin.gets.chomp

  Services::Request.new(filepath: filepath).call
end

desc 'Criar arquivo padrão de configuração'
task :quake_create_default do
  puts 'Informe o nome do diretorio que deseja criar:'

  filepath = $stdin.gets.chomp
  filepath = filepath.gsub(/\s+/, '_')
  filepath = filepath.gsub(/[^a-zA-Z_]/, '')

  next if filepath.empty?

  Dir.mkdir(filepath) unless Dir.exist?(filepath)

  File.open("#{filepath}/default.json", 'w') do |file|
    file.puts File.open('templates/default_config.json').read
  end

  logger.info "Create #{filepath}/default.json"
end
