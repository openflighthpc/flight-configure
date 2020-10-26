#==============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
#
# This file is part of Flight Configure.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Configure is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Configure. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Configure, please visit:
# https://github.com/openflighthpc/flight-configure
#==============================================================================

require 'logger'
require 'forwardable'
require 'xdg'

module FlightConfigure
  ETC_CONFS = Dir.glob(File.expand_path('../../etc/*\.conf', __dir__)).sort

  class ConfigData
    def self.load_data(*paths)
      new.tap do |data|
        paths.each do |path|
          data.instance_eval(File.read(path), path)
        end
      end
    end

    attr_reader :_program_application
    attr_reader :_program_name
    attr_reader :_program_description
    attr_reader :_program_version

    attr_reader :dialog_config
    attr_reader :applications_path
    attr_reader :data_path
    attr_reader :log_dir

    attr_reader :script_env

    attr_reader :log_level
    attr_reader :development

    private

    def xdg
      @xdg ||= XDG::Environment.new
    end
  end

  class Config
    def initialize(*paths)
      @data = ConfigData.load_data(*paths)
    end

    def log_path
      @log_path ||= begin
        case @data.log_dir
        when String
          FileUtils.mkdir_p @data.log_dir
          File.join(@data.log_dir, 'application.log')
        else
          @data.log_dir
        end
      end
    end

    def logger
      @logger ||= Logger.new(log_path).tap do |log|
        # Determine the level
        level = case log_level
        when 'fatal'
          Logger::FATAL
        when 'error'
          Logger::ERROR
        when 'warn'
          Logger::WARN
        when 'info'
          Logger::INFO
        when 'debug'
          Logger::DEBUG
        when Integer
          log_level if 0 <= log_level && log_level <= 5
        end

        if level.nil?
          # Log bad log levels
          log.level = Logger::ERROR
          log.error "Unrecognized log level: #{log_level}"
        else
          # Sets good log levels
          log.level = level
        end
      end
    end

    # Forward undefined properties to the data
    extend Forwardable
    def_delegators :@data, *(ConfigData.public_instance_methods - self.instance_methods)
  end

  # Caches the default config
  Config::CACHE = Config.new(*ETC_CONFS)
end
