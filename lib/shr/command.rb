#command utf-8
require 'os'
require 'shr/option'

module Shr
  class Command
    def initialize(command, options)
      @command = command
      Option.indicator = '/' if OS.windows?
      @options = Option.translate(options).join(' ')
    end
    attr_reader :command

    def command
      OS.windows? ? "cmd /c #{@command}" : @command
    end

    def to_s
      [command, @options].join(' ')
    end
  end
end
