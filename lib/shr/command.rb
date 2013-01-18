#command utf-8
require 'shr/option'
require 'shr/which'

module Shr
  class Command

    def initialize(command, options)
      @command = command.to_s
      Option.indicator = '/' if OS.windows?
      @options = Option.translate(options).join(' ')
    end
    attr_reader :command

    def command
      command = release? ? @command.chomp('!') : @command
      Which::builtins?(command) ? "cmd /c #{command}" : command
    end

    def to_s
      [command, @options].join(' ')
    end

    def exist?
      Which::exist? @command.chomp('!')
    end

    def release?
      @command.end_with? '!'
    end
  end
end
