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

require_relative 'commands'
require_relative 'errors'

require 'commander'

module FlightConfigure
  module CLI
    extend Commander::CLI

    program :application, Config::CACHE._program_application
    program :name,        Config::CACHE._program_name
    program :version,     Config::CACHE._program_version
    program :description, Config::CACHE._program_description
    program :help_paging, false
    default_command :help

    if [/^xterm/, /rxvt/, /256color/].all? { |regex| ENV['TERM'] !~ regex }
      Paint.mode = 0
    end

    def self.create_command(name, args_str = '', &b)
      command(name) do |c|
        c.syntax = "#{program :name} #{name} #{args_str}"
        c.hidden = true if name.split.length > 1

        c.action do |args, opts|
          Commands.build(name, *args, **opts.to_h).run!
        end

        yield c if block_given?
      end
    end

    global_slop.bool '--ascii', 'Display a simplified version of the interactive output'

    create_command 'avail' do |c|
      c.summary = 'List all configurable applications.'
    end

    create_command 'get', 'APPLICATION KEY' do |c|
      c.summary = 'Retrieve a configuration value for an application'
    end

    create_command 'run', 'APPLICATION' do |c|
      c.summary = 'Run the configuration for an application'
      c.slop.bool '--force', 'Execute the post configure script even when the config has not changed'
    end

    create_command 'show', 'APPLICATION' do |c|
      c.summary = 'View details about a specific application'
    end

    default_command 'run'

    if Config::CACHE.development
      create_command 'console' do |c|
        c.action do
          require_relative 'command'
          Command.new([], {}).instance_exec { binding.pry }
        end
      end
    end
  end
end
