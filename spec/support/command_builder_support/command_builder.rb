def create_CommandBuilder(options, config_file, logger)
  cmd = CommandBuilder.new(options, config_file, logger)
  allow(cmd).to receive(:terraform_bin).and_return('/usr/bin/terraform')
  return cmd
end

def generate_config(tf_file)
  return ConfigFile.new("spec/mockdir/scripts/configs/#{tf_file}", dummy_logger)
end

def new_config
  return generate_config 'tf_mock.json'
end

def new_config_with_modules
  return generate_config 'tf_mock_modules.json'
end

def new_config_with_no_backend
  return generate_config 'tf_mock_no_backend.json'
end
