require 'spec_helper'

describe 'CommandBuilder' do
  describe '#tf_module_get_cmd' do
    it 'must return the terraform get command' do
      cmd = create_CommandBuilder({}, new_config_with_modules, dummy_logger)
      expect(cmd.tf_module_get_cmd).to eq('/usr/bin/terraform get')
    end
  end

  describe '#tf_state_file_cmd' do
    describe 'full terraform remote state command' do
      it 'return state file command' do
        cmd = create_CommandBuilder({}, new_config, dummy_logger)
        expect(cmd.tf_state_file_cmd).to eq('/usr/bin/terraform remote config -backend=s3 -backend-config="region=eu-west-1" -backend-config="bucket=terraform-bucket" -backend-config="key=path/to/terraform.tfstate"')
      end
    end
  end

  describe '#tf_action_cmd' do
    describe 'action plan' do
      it 'return full plan command' do
        puts Dir.pwd
        ENV['aws_ssh_key_path'] = 'sshkeypath'
        options = { silent: false, action: 'plan', debug: false, create_json: false, module_updates: false }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect(cmd.tf_action_cmd).to eq(%(/usr/bin/terraform plan -var aws_ssh_key_path=sshkeypath -var aws_ssh_key_name=myawskey -var-file="#{Dir.pwd}/spec/mockdir/scripts/tfmockdir/mock_vars1.tfvars" -var-file="#{Dir.pwd}/spec/mockdir/scripts/tfmockdir/mock_vars2.tfvars" -parallelism=10 -detailed-exitcode))
      end
    end

    describe 'quoted strings' do
      it 'returns strings quoted if needed.' do
        options = { action: 'get' }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect((cmd.send :escape_values, 'test value')).to eq('"test value"')
        expect((cmd.send :escape_values, 'testvalue')).to eq('testvalue')
        expect((cmd.send :escape_values, '')).to eq('')
        expect((cmd.send :escape_values, nil)).to eq(nil)
        expect((cmd.send :escape_values, 123)).to eq(123)
      end
    end

    describe 'action get' do
      it 'return full get command with true @module_updates' do
        options = { action: 'get', module_updates: true }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect(cmd.tf_action_cmd).to eq('/usr/bin/terraform get -update')
      end

      it 'return full get command with false @module_updates' do
        options = { action: 'get', module_updates: false }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect(cmd.tf_action_cmd).to eq('/usr/bin/terraform get')
      end
    end

    describe 'action destroy' do
      it 'return full destroy command with -force flag' do
        options = { action: 'destroy' }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect(cmd.tf_action_cmd).to eq(%(/usr/bin/terraform destroy -var aws_ssh_key_path=sshkeypath -var aws_ssh_key_name=myawskey -var-file="#{Dir.pwd}/spec/mockdir/scripts/tfmockdir/mock_vars1.tfvars" -var-file="#{Dir.pwd}/spec/mockdir/scripts/tfmockdir/mock_vars2.tfvars" -parallelism=10 -force))
      end
    end

    describe 'action output' do
      it 'must return the output command' do
        options = { action: 'output' }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect(cmd.tf_action_cmd).to eq('/usr/bin/terraform output')
      end
    end

    describe 'action with custom arguments' do
      it 'must return the plan command with custom arguments' do
        options = { action: 'plan', custom_parameter: ['-destroy', '-no-color'] }
        cmd = create_CommandBuilder(options, new_config, dummy_logger)
        expect(cmd.tf_action_cmd).to eq(%(/usr/bin/terraform plan -var aws_ssh_key_path=sshkeypath -var aws_ssh_key_name=myawskey -var-file="#{Dir.pwd}/spec/mockdir/scripts/tfmockdir/mock_vars1.tfvars" -var-file="#{Dir.pwd}/spec/mockdir/scripts/tfmockdir/mock_vars2.tfvars" -parallelism=10 -detailed-exitcode -destroy -no-color))
      end
    end
  end
end
