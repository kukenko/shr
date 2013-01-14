#command utf-8
require 'os'
require 'shr/option'

module Shr
  class Command
    def initialize(command, options)
      @command = command
      # xxx
      option = Option.new
      option.indicator = '/' if OS.windows?
      @opts = option.parse(options).join(' ')
    end
    attr_reader :command

    def command
      OS.windows? ? "cmd /c #{@command}" : @command
    end

    def to_s
      "#{command} #{@opts}".strip
    end
  end
end
