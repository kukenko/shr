#coding: utf-8
require 'spec_helper'

module Shr
  describe Which do
    it 'has the following methods' do
      m = Which.methods
      m.should include(:exist?)
      m.should include(:exists?)
    end

    describe '#exist?' do
      shared_examples 'if any of executables are found' do
        it { Which.exist?(command).should be_true }
      end

      shared_examples 'if any of executables are not found' do
        it { Which.exist?(command).should be_false }
      end

      unless ENV['OS'] == 'Windows_NT'
        it_behaves_like 'if any of executables are found' do
          let(:command) { :pwd }
        end

        context 'with String' do
          it_behaves_like 'if any of executables are found' do
            let(:command) { 'pwd' }
          end
        end
      else
        it_behaves_like 'if any of executables are found' do
          let(:command) { :notepad }
        end

        context 'with builtin command' do
          it_behaves_like 'if any of executables are found' do
            let(:command) { :chdir }
          end
        end

        context 'with String' do
          it_behaves_like 'if any of executables are found' do
            let(:command) { 'chdir' }
          end
        end
      end

      it_behaves_like 'if any of executables are not found' do
        let(:command) { :not_found }
      end
    end
  end
end
