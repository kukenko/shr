#coding: utf-8
require 'os'

# The following code was referring to whichr.
# whichr - https://github.com/rdp/whichr

module Shr
  class Which
    @@path = ENV['PATH']
    if OS.windows?
      cwd = File::PATH_SEPARATOR + '.'
      @@path += cwd
    end

    if OS.windows?
      @@builtins = %w{
        assoc
        call
        cd chdir
        cls
        color
        date
        del erace
        dir
        echo
        exit
        ftype
        md mkdir
        mklink
        move
        path
        pause
        popd
        prompt
        pushd
        rd rmdir
        ren rename
        set
        start
        time
        title
        var
        verify
        vol
      }
    end

    def self.exist?(program)
      programs = add_extensions(program)

      entries = paths.product(programs).map { |list| list.join '/' }
      result = entries.find do |exe|
        File.executable?(exe) && !File.directory?(exe)
      end

      if OS.windows?
        result = program.to_s if @@builtins.include? program.to_s
      end

      result
    end
    class << self
      alias :exists? :exist?
    end

    def self.add_extensions(program)
      if OS.windows?
        # add .bat, .exe, etc.
        extensions = ENV['PATHEXT'].split(';')
        [program].product(extensions).map(&:join)
      else
        [program]
      end
    end

    def self.paths
      @@path.split(File::PATH_SEPARATOR).map! do |path|
        OS.windows? ? path.gsub('\\', '/') : path
      end
    end

    private_class_method :add_extensions, :paths
  end
end
