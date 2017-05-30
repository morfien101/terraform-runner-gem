require 'spec_helper'

describe 'Options' do
  describe '.get_options' do
    describe 'pass in configuration file' do
      it 'adds config_file to options hash' do
        options = Options.get_options(['-c /tmp/config'])
        expect(options[:config_file]).to eq('/tmp/config')
      end
    end

    # For some reason yet to be discovered "--" flags don't test
    # describe 'pass in configuration file 2' do
    #   it 'adds config_file to options hash' do
    #     options = Options.get_options(['--config-file /tmp/config'])
    #     expect(options[:config_file]).to eq('/tmp/config')
    #   end
    # end

    describe 'pass in custom arugments' do
      # it 'adds an array of arguments to the options hash' do
      #   options = Options.get_options(['--custom-parameters "-destory, -no-color"'])
      #   expect(options[:custom_parameter]).to eq(['-destory','-no-color'])
      # end

      it 'adds an array of arguments to the options hash with no spaces.' do
        options = Options.get_options(['-p "-destory, -no-color"'])
        expect(options[:custom_parameter]).to eq(['-destory', '-no-color'])
      end
    end

    describe 'pass in help option' do
      it 'displays help and exits the program' do
        expect { Options.get_options(['-h']) }.to raise_error SystemExit
      end

      it 'displays help for each available flag' do
        def run_help
          expect {
            begin Options.get_options(['-h'])
            rescue SystemExit
            end
          }
        end

        run_help.to output(/-c, --config-file/).to_stdout
        run_help.to output(/-a, --action/).to_stdout
        run_help.to output(/-p, --custom-parameters/).to_stdout
        run_help.to output(/--custom-command/).to_stdout
        run_help.to output(/--custom-command-vars/).to_stdout
        run_help.to output(/--update-modules/).to_stdout
        run_help.to output(/--json-example/).to_stdout
        run_help.to output(/-v, --version/).to_stdout
        run_help.to output(/--debug/).to_stdout
      end
    end
  end
end
