require 'spec_helper'

describe 'TerraformRunner:' do
  config_file_string = 'spec/mockdir/scripts/configs/tf_mock.json'
  describe 'destroy must prompt for user input' do
    it 'if there is no -f flag, prompts for user input and returns when "yes" is supplied' do
      opts = Options.get_options(['-a', 'destroy', '-c', config_file_string])
      tr = TerraformRunner.new(dummy_logger, opts)
      allow(tr).to receive(:gets).and_return('yes')
      expect(tr.send(:prompt_to_destroy)).to eq(nil)
    end

    it 'exit if it gets something other than yes.' do
      opts = Options.get_options(['-a', 'destroy', '-c', config_file_string])
      tr = TerraformRunner.new(dummy_logger, opts)
      allow(tr).to receive(:gets).and_return('wrong')
      expect { tr.send(:prompt_to_destroy) }.to raise_error SystemExit
    end
  end

  describe 'create directory must output the name of the directory' do
    it 'the output must be the mocked name.' do
      epoc = Time.now().to_i
      dirname = "terraform-runner-working-dir-#{epoc}"
      allow(FileUtils).to receive(:mkdir_p).and_return(true)

      opts = Options.get_options(['-a', 'plan', '-c', config_file_string])
      logger = LoggerHelper.get_logger(opts)
      tr = TerraformRunner.new(logger, opts)

      expect(logger).to receive(:info).with(/#{dirname}/)
      tr.send(:make_working_dir, dirname)
    end
  end

  describe 'must run terraform get' do
    def setup_get_test(json_file)
      testecho = TestEcho.new()
      allow(OS).to receive(:command).and_return(testecho)
      allow(CommandBuilder).to receive(:new).and_return(TestEchoCommand.new())

      opts = Options.get_options(['-a', 'plan', '-c', "spec/mockdir/scripts/configs/#{json_file}"])
      logger = LoggerHelper.get_logger(opts)
      tr = TerraformRunner.new(logger, opts)
      return testecho, tr
    end
    
    it 'if local_modules is enabled' do
      testecho, tr = setup_get_test('tf_mock_local_modules.json')

      expect(testecho).to receive(:run_command).with('terraform init')
      expect(testecho).to receive(:run_command).with('terraform get')
      expect(testecho).to receive(:run_command).with('terraform plan')
      tr.send(:run_commands)
    end

    it 'if modules_required is enabled' do
      testecho, tr = setup_get_test('tf_mock_modules.json')

      expect(testecho).to receive(:run_command).with('terraform init')
      expect(testecho).to receive(:run_command).with('terraform get')
      expect(testecho).to receive(:run_command).with('terraform plan')
      tr.send(:run_commands)
    end

    it 'only if required' do
      testecho, tr = setup_get_test('tf_mock.json')

      expect(testecho).to receive(:run_command).with('terraform init')
      expect(testecho).to receive(:run_command).with('terraform plan')
      tr.send(:run_commands)
    end
  end
end
