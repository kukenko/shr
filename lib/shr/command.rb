#command utf-8
require 'open3'
require 'shr/option'
require 'shr/which'

module Shr
  class Command

    def initialize(command, options=[])
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

    # xxx
    def run(environment)
      pid = spawn(self.to_s, environment)
      watcher = Process.detach(pid)
      environment[:out].close if environment[:out].kind_of?(IO)
      watcher
    end

    # xxx
    def run!
      Open3.pipeline(self.to_s)
    end
  end
end
