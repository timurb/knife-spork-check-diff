#
# Author: Timur Batyrshin <erthad@gmail.com>
#
# Loosely based on knife-spork source.
#

require 'knife-spork/plugins/plugin'
require 'hashdiff'

module KnifeSpork
  module Plugins
    class CheckDiff < Plugin
      name :checkdiff

      def perform; raise end

      # Environmental Git wrappers
      def before_environmentcreate
        check_environment_path(environment_path)
      end

      def after_environmentcreate
        save_environment(object_name) unless object_difference == ''
      end

      def before_environmentedit
        check_environment_path(environment_path)
      end

      def after_environmentedit
        save_environment(object_name) if object_difference != '' || !File.exist?(File.join(environment_path, object_name + '.json'))
      end

      def after_environmentdelete
        delete_environment(object_name)
      end

      def before_promote
        environments.each do |env|
          local_environment = env.to_hash
          remote_environment = load_remote_environment(env.name).to_hash
          diff = HashDiff.diff(remote_environment, local_environment)
          if !diff.empty?
            message = "Local environment is different from remote.\nAttributes changed:\n#{format_diff(diff)}"
            if config.epic_fail
              ui.error message
              ui.error 'Make sure environments match each other before proceeding'
              exit 1
            else
              ui.warn message
            end
          end
        end
      end

      def check_environment_path(path)
        if !File.directory?(path)
          ui.error "Environment path #{path} does not exist"
          exit 1
        end
       end

      def save_environment(environment)
        json = JSON.pretty_generate(Chef::Environment.load(environment))
        environment_file = File.expand_path( File.join(environment_path, "#{environment}.json") )
        File.open(environment_file, 'w'){ |f| f.puts(json) }
      end

      def delete_environment(environment)
        environment_file = File.expand_path( File.join(environment_path, "#{environment}.json") )
        File.delete(environment_file)
      end

      def load_remote_environment(environment_name)
        begin
          Chef::Environment.load(environment_name)
        rescue Net::HTTPServerException => e
          ui.error "Could not load #{environment_name} from Chef Server. You must upload the environment manually the first time."
          exit(1)
        end
      end

      def format_diff(diff)
        diff.map do |op, attribute, value1, value2|
          if value2
            "#{op}#{attribute}=#{value1.inspect}->#{value2.inspect}"
          else
            "#{op}#{attribute}=#{value1.inspect}"
          end
        end.join("\n")
      end
    end
  end
end
