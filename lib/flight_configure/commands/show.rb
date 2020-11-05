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
      class ShowOutput
        include OutputMode::TLDR::Show

        # TODO: Replace the label tag with a description
        TEMPLATE = <<~'ERB'
          <%  each(:shared) do |value, field:, padding:, **_| -%>
          <%=   padding -%><%= pastel.blue.bold(field) -%>: <%= pastel.green(value) %>
          <%  end -%>

          <%= pastel.cyan.bold '== Description ==' %>
          <%= pastel.green model.schema['text'].chomp %>

          <%= pastel.cyan.bold '== Configuration Attributes ==' %>
          <%  each(:value) do |datum, field:, padding:, **_| -%>
          <%    label = model.schema['values'].select { |v| v['key'] == field }.first["label"] -%>
          <%=   padding -%><%= pastel.blue.bold(field) -%>: <%= pastel.green(datum) -%> <%= pastel.dim("# #{label}") %>
          <%  end -%>
        ERB

        attr_reader :application

        def initialize(application)
          @application = application

          register_attribute(section: :shared, header: 'Name') do |a|
            a.name
          end
          register_attribute(section: :shared, header: 'Summary') do |a|
            # Replace newlines to ensure the output does not break
            a.schema['title'].gsub("\n", ' ')
          end
          register_attribute(section: :shared, verbose: true, header: 'Configuration Keys') do |a|
            a.schema['values'].map { |v| v['key'] }.join(' ')
          end

          application.schema['values'].each do |value|
            register_attribute(section: :value, header: value['key']) do
              application.current_data[value['key']]
            end
          end
        end

        def render(ascii: nil, **other)
          opts = ascii ? other.merge(ascii: true, interactive: true) : other.dup
          build_output(**opts).render(application)
        end

        def build_output(**opts)
          super(template: TEMPLATE, **opts)
        end
      end

      def run
        puts ShowOutput.new(application).render(ascii: opts.ascii, verbose: opts.verbose)
      end

      def application
        @application ||= Application.load(args.first)
      end
    end
  end
end
