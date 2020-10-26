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
    class Run < Command
      def run
        application.dialog_update
        if opts.force || application.changed?
          application.save
          run_script if application.script_path?
        else
          raise UnchangedError, <<~ERROR.chomp
            The configuration has not changed. Skipping the post configure script.
            The script can be ran using the following flag: #{Paint["--force", :yellow]}
          ERROR
        end
      end

      def application
        @application ||= Application.load(args.first)
      end

      def run_script
        pid = Kernel.spawn('bash',
                           application.script_path,
                           *application.build_script_args,
                           unsetenv_others: true,
                           close_others: true)
        Process.wait pid
      end
    end
  end
end
