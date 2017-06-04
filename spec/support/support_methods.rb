def dummy_logger
  logger = double
  allow(logger).to receive(:debug).and_return(true)
  allow(logger).to receive(:warn).and_return(true)
  logger
end

def dummy_ProcessStatus(exit_code)
  double('Process::Status', exitstatus: exit_code)
end

class PTY
end if OS.windows?

class TestEcho
  def run_command(string)
    string
  end
end

class TestEchoCommand
  def tf_state_file_cmd
    'terraform init'
  end

  def tf_module_get_cmd
    'terraform get'
  end

  def tf_action_cmd
    'terraform plan'
  end
end
