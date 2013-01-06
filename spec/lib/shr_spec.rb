#coding: utf-8
require 'spec_helper'

describe Shr do
  it 'has the following methods' do
    m = Shr.methods
    m.should include(:shell)
  end

  describe '#shell' do
    it 'returns an instance of Shr::Shell' do
      Shr.shell.should be_kind_of(Shr::Shell)
    end
  end
end
