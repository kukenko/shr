#coding: utf-8
require 'spec_helper'

module Shr
  describe Option do
    let(:opt) { Option.new }

    it 'has the following methods' do
      o = opt.methods
      o.should include(:parse)
    end

    describe '#parse' do
      shared_examples 'with short-form options' do
        it 'parses correctly' do
          opt.parse(options).should eq(['-o', 'page.html'])
        end
      end

      shared_examples 'with long-form options' do
        it 'parses correctly' do
          opt.parse(options).should eq(['--shell=/bin/sh', '--silent'])
        end
      end

      shared_examples 'with mixed options' do
        it 'parses correctly' do
          opt.parse(options).should eq(['-o', 'page.html', '--shell=/bin/sh', '--silent'])
        end
      end

      describe String do
        it_behaves_like 'with short-form options' do
          let(:options) { ['-o', 'page.html'] }
        end

        it_behaves_like 'with long-form options' do
          let(:options) { ['--shell', '/bin/sh', '--silent'] }
        end

        it_behaves_like 'with mixed options' do
          let(:options) { ['-o', 'page.html', '--shell', '/bin/sh', '--silent'] }
        end
      end

      describe Symbol do
        it_behaves_like 'with short-form options' do
          let(:options) { [:o, 'page.html'] }
        end

        it_behaves_like 'with long-form options' do
          let(:options) { [:shell, '/bin/sh', :silent] }
        end

        it_behaves_like 'with mixed options' do
          let(:options) { [:o, 'page.html', :shell, '/bin/sh', :silent] }
        end
      end

      describe Hash do
        it_behaves_like 'with short-form options' do
          let(:options) { [{ :o => 'page.html' }] }
        end

        it_behaves_like 'with long-form options' do
          let(:options) { [{ :shell => '/bin/sh', :silent => true }] }
        end

        it_behaves_like 'with mixed options' do
          let(:options) { [{ :o => 'page.html', :shell => '/bin/sh', :silent => true }] }
        end
      end

      describe Fixnum do
        it 'parses short-form options' do
          options = [1, 2, 3]
          opt.parse(options).should eq(['-1', '-2', '-3'])
        end
      end
    end
  end
end
