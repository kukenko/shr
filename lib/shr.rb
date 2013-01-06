#coding: utf-8
require 'shr/version'
require 'shr/shell'

module Shr
  class << self
    def shell
      Shr::Shell.new
    end
  end
end
