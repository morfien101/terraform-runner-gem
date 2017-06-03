def create_CommandBuilder(options, config_file, logger)
  cmd = CommandBuilder.new(options, config_file, logger)
  allow(cmd).to receive(:terraform_bin).and_return('/usr/bin/terraform')
  cmd
end

def generate_config(tf_file)
  ConfigFile.new("spec/mockdir/scripts/configs/#{tf_file}", dummy_logger)
end

def new_config
  generate_config 'tf_mock.json'
end

def new_config_with_modules
  generate_config 'tf_mock_modules.json'
end
