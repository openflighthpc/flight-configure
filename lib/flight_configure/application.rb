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

require 'yaml'
require_relative 'dialog'
require 'forwardable'

module FlightConfigure
  Application = Struct.new(:name, :schema_path) do
    extend Forwardable
    def_delegators :dialog, :changed?

    def self.build_from_schema_path(path)
      regex = /\A#{Regexp.escape Config::CACHE.applications_path}\/(?<name>[^\/]+)\/configuration\.yml\Z/
      if match = regex.match(path)
        name = match.named_captures['name']
        new(name, path)
      else
        raise InputError, <<~ERROR
          Could not resolve application from path: #{path}
        ERROR
      end
    end

    def self.build(name)
      path = File.join(Config::CACHE.applications_path, name, 'configuration.yml')
      new(name, path)
    end

    def self.load(name)
      build(name).tap do |app|
        next if File.exists? app.schema_path
        raise MissingError, <<~ERROR
          Could not locate configurable application: #{name}
        ERROR
      end
    end

    def legacy_script_path
      @legacy_script_path ||= File.join(File.dirname(schema_path), 'configure.sh')
    end

    def data_path
      @data_path ||= File.join(Config::CACHE.data_path, name + '.yml')
    end

    def schema
      @schema ||= YAML.load File.read(schema_path)
    end

    def current_data
      @current_data ||= if File.exists?(data_path)
        YAML.load(File.read(data_path)) || {}
      else
        {}
      end
    end

    # TODO: Should this execute via a bash process? Currently not all the
    # configuration scripts have executable permissions, hence the bash
    # shell. As this is a rebuild, should we break from this mechanism?
    # TBC
    #
    # NOTE: As this goes through a bash shell, there is the possibility
    # of a shell injection form the config options. However their actions
    # will be limited to the caller's permissions.
    #
    # Consider refactoring
    def run_script
      return unless File.exists? legacy_script_path
      pid = Kernel.spawn(Config::CACHE.script_env,
                         '/bin/bash',
                         '--noprofile',
                         '--norc',
                         '-x',
                         legacy_script_path,
                         *build_script_args,
                         unsetenv_others: true,
                         close_others: true,
                         [:out, :err] => log_fd)
      Process.wait pid
    end

    def save
      File.write data_path, YAML.dump(current_data)
    end

    def build_script_args
      build_values.map do |key, value|
        "#{key}=#{value}"
      end
    end

    def dialog_update
      dialog.request
      dialog.data.each do |key, value|
        current_data[key] = value
      end
    end

    private

    ##
    # Designed to work when logging is redirected to $stderr or
    # a file given by a string
    def log_fd
      @application_log_fd = case Config::CACHE.log_dir
      when IO
        Config::CACHE.log_dir.fileno
      else
        base_dir = File.join(Config::CACHE.log_dir, 'applications')
        FileUtils.mkdir_p base_dir
        [File.join(base_dir, name + '.log'), 'w']
      end
    end

    def build_values
      schema["values"].each_with_object({}) do |value_hash, memo|
        key = value_hash["key"]
        memo[key] = current_data[key] || value_hash['value']
      end
    end

    def dialog
      @dialog ||= begin
        cfg = schema
        values = build_values
        Dialog.create(values) do
          title cfg['title']
          text cfg['text']
          cfg['values'].each do |h|
            value h['label'], h['key'], h['length']
          end
        end
      end
    end
  end
end
