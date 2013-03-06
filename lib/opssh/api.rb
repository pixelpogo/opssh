require 'aws-sdk'
require 'json'
require 'yaml'
require 'tmpdir'
require 'etc'
require 'fileutils'

module Opssh

  module Api

    def stacks
      get_cache('all_stacks') do
         api("describe_stacks")[:stacks].map{|s| {:name => s[:name], :id => s[:stack_id]}}
      end
    end

    def instances(stack_id)
      get_cache("stack-#{stack_id}---instances") do
        instances_list = api("describe_instances",{:stack_id => stack_id})
        instances_list = instances_list[:instances].select{|instance| instance[:status] == 'online'}
        instances_list.map! do |instance|
          { :name              => instance[:hostname],
            :public_dns        => instance[:public_dns],
            :availability_zone => instance[:availability_zone]
          }
        end
      end
    end

    def reset_cache(verbose=false)
      Opssh::Api.reset_cache(verbose)
    end

    def self.reset_cache(verbose=false)
      File.unlink(cache_file) rescue ""
    end

    private

    def api(action, options={})
      opsworks = AWS::OpsWorks.new(Opssh::Config.aws_credentials)
      opsworks.client.send(action, options)
    end

    def get_cache(*args)
      cache = load_cache
      cache_id = args.first.to_s
      return cache[cache_id] unless cache[cache_id].nil? || !caching_enabled?
      set_cache(cache_id, yield)
    end


    def set_cache(cache_id, value)
      cache = load_cache
      cache[cache_id] = value
      write_cache(cache) if caching_enabled?
      value
    end

    def load_cache
      File.exist?(cache_file) ? YAML.load_file(cache_file) : {}
    end

    def write_cache(cache)
      FileUtils.touch(cache_file)
      FileUtils.chmod(0600, cache_file, :verbose => @verbose)
      File.open(cache_file, 'w') {|f| f.write(cache.to_yaml)}
      cache
    end

    def cache_file
      Opssh::Api.cache_file
    end

    def self.cache_file
      Etc.getpwuid.dir. + "/.opssh_api_cache"
    end

    def caching_enabled?
      true
    end

  end
end