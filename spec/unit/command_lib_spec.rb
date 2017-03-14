require 'spec_helper'

describe 'LinuxCommand' do
  describe '#get_exit_code' do
    it 'if it gets a nil it will exit with 1' do
      allow(PTY).to receive(:check).and_return(nil)
      expect((LinuxCommand.send :get_exit_code, 1)).to eq(1)
    end

    it 'if it gets a code it will exit with that code' do
      allow(PTY).to receive(:check).and_return(dummy_ProcessStatus(0))
      expect((LinuxCommand.send :get_exit_code, 1)).to eq(0)

      allow(PTY).to receive(:check).and_return(dummy_ProcessStatus(35))
      expect((LinuxCommand.send :get_exit_code, 1)).to eq(35)
    end
  end
end
