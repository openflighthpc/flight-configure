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
    class Avail < Command
      extend OutputMode::TLDR::Index

      register_column(header: 'Name', row_color: :cyan) { |a| a.name }
      register_column(header: 'Summary', row_color: :green) { |a| a.schema['title'] }
      register_column(header: 'Configured') { |a| File.exists? a.data_path }

      def self.build_output
        super(header_color: :clear, row_color: :clear)
      end

      def run
        apps = Dir.glob(Application.build('*').schema_path).map do |path|
          Application.build_from_schema_path(path)
        end.to_a
        puts self.class.build_output.render(*apps)
      end
    end
  end
end
