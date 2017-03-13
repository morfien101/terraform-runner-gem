# Copyright 2017 Randy Coburn
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class WindowsCommand
  def run_command(command_text)
    command_output = `#{command_text}`
    puts command_output
    return $?.exitstatus
  end
end

class LinuxCommand
  def run_command(command_text)
    # There is 2 places that this code will exit.
    # 1) if the command runs successfully then it will return the exit code.
    # 2) if the command failed it will run then rescue PTY::ChildExited block
    begin
      PTY.spawn(command_text) do |stdout, _, pid|
        begin
          stdout.each { |line| puts line }
        rescue Errno::EIO
          # we seem to get into a race condition here waiting for the exit code
          # for the command to be generated. We can just hang tight for a bit
          # till it comes through. We will try 3 times and then exit with a error
          # state should we not get one.
          return get_exit_code(pid)
        end
      end
    rescue PTY::ChildExited
      @logger.fatal('The child proesses exited!')
    end
  end

  def self.get_exit_code(pid)
    (1..3).each do |i|
      ec = PTY.check(pid, false)
      # exitstatus returns an int which is the exit code.
      return ec.exitstatus unless ec.nil?
      sleep 1 if i < 3
    end
    return 1
  end
  private_class_method :get_exit_code
end
