#command utf-8
require 'os'
require 'shr/option'

module Shr
  class Command
    # xxx
    def initialize(command, options)
      option = Option.new
      option.indicator = '/' if OS.windows?
      opts = option.parse(options).join(' ')

      @command = if OS.windows?
                   "cmd /c #{command} #{opts}".strip
                 else
                   "#{command} #{opts}".strip
                 end
    end

    def to_s
      @command
    end
  end
end
