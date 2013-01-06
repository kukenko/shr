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
      it 'returns true if any of executables are found' do
        Which.exist?(:pwd).should be_true
      end

      it 'returns false if any of executables are not found' do
        Which.exist?(:not_found).should be_false
      end

      context 'with argument String' do
        it 'returns true if any of executables are found' do
          Which.exist?('pwd').should be_true
        end
      end
    end
  end
end
