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

module FlightConfigure
  module Commands
    class Show < Command
      # Wraps output mode to allow for variable length attribute fields
      # There are two output definitions:
      # 1. The core definitions on the class
      # 2. The variable config definitions on the instance
      OutputWrapper = Struct.new(:application) do
        extend  OutputMode::TLDR::Show
        include OutputMode::TLDR::Show

        register_attribute(header: 'Name') { |a| a.name }
        register_attribute(header: 'Summary') { |a| a.schema['title'] }
        register_attribute(header: 'Description') { |a| a.schema['text'] }

        def initialize(*_)
          super
          # TODO: Change label into a description field
          application.schema['values'].each do |value|
            register_attribute(header: value['key']) { value['label'] }
          end
        end

        def print
          puts self.class.build_output.render(application)
          if $stdout.tty?
            puts
            puts Paint["Configuration Attributes:", :blue, :bold]
          end
          puts build_output.render(application)
        end
      end

      def run
        OutputWrapper.new(application).print
      end

      def application
        @application ||= Application.load(args.first)
      end
    end
  end
end
