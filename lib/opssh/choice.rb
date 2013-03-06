require 'highline/import'

module Opssh

  class Choice

    include Api

    attr_accessor :caching_enabled

    def initialize
      @caching_enabled = true
    end

    def select_stack
      stack_list = stacks
      raise "Sorry, no stacks available." if stack_list.size < 1
      show_list(stack_list)
      index = ask("\n--> Please select stack:")
      puts "Index: #{index} and #{stack_list[index.to_i - 1].inspect}"
      stack_list[index.to_i - 1] rescue nil unless index.to_i == 0
    end

    def select_instance(stack_id)
      instance_list = instances(stack_id)
      raise "Sorry, no instance available in this stack." if instance_list.size < 1
      show_list(instance_list)
      index = ask("\n--> Please select instance:")
      instance_list[index.to_i - 1] rescue nil unless index.to_i == 0
    end

    private

    def show_list(list)
      list.sort!{|x,y| x[:name] <=> y[:name] }
      list.each_index do |index|
        item = "[#{index + 1}]."
        puts "#{item.rjust(6)} #{list[index][:name]}"
      end
    end

    def caching_enabled?
      @caching_enabled
    end

  end

end

