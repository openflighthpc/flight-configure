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

    def script_path?
      File.exists? script_path
    end

    def script_path
      @script_path ||= File.join(File.dirname(schema_path), 'configure.sh')
    end

    def build_script_args
      schema['values'].map do |h|
        "#{h['key']}=#{h["value"]}"
      end
    end

    def schema
      @schema ||= YAML.load File.read(schema_path)
    end

    def save
      File.write schema_path, YAML.dump(schema)
    end

    def dialog_update
      dialog.request
      data = dialog.data
      schema['values'].each do |value|
        key = value['key']
        value['value'] = data[key]
      end
    end

    def dialog
      @dialog ||= begin
        cfg = schema
        values = {}.tap do |h|
          cfg['values'].each do |vh|
            h[vh['key']] = vh['value'].to_s
          end
        end
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
