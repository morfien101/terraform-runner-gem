class WindowsCommand
  def run_command(command_text)
    command_output=`#{command_text}`
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
      PTY.spawn(command_text) do |stdout, stdin,pid|
        begin
          stdout.each{|line| puts line}
        rescue Errno::EIO
          # we seem to get into a race condition here waiting for the exit code
          # for the command to be generated. We can just hang tight for a bit
          # till it comes through. We will try 3 times and then exit with a error
          # state should we not get one.
          for i in 1..3
            ec = PTY.check(pid, false)
            break unless ec.nil?
            sleep 1 if i < 3
          end
          
          return 1 if ec.nil?
          return ec.exitstatus
        end
      end
    rescue PTY::ChildExited
      @logger.fatal('The child proesses exited!')
    end
  end
end
