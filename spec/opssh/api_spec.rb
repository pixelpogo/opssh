require 'spec_helper'
require 'tmpdir'

describe Opssh::Api do

  class ApiHelper
    include Opssh::Api
    def cache_file
      Dir.tmpdir + "/.opssh-rspec-cache"
    end
  end

  let(:api_helper) { ApiHelper.new }

  before :each do
    # clear temporary cache file ...
    File.unlink(Dir.tmpdir + "/.opssh-rspec-cache") rescue ""
  end

  context "#stacks" do
    it "should return list of available stacks" do
      example =  { :stacks => [
        { :name => "Monitoring", :stack_id => "d30104ef" },
        { :name => "Reports",    :stack_id => "ffa0116d" },
        { :name => "RailsApp",   :stack_id => "ac263281" }
      ] }

      api_helper.stub(:api).with("describe_stacks").and_return(example)
      api_helper.stacks.size.should be(3)
    end

    it "should return empty list in case of no available stacks" do
      example =  { :stacks => [] }
      api_helper.stub(:api).with("describe_stacks").and_return(example)
      api_helper.stacks.size.should be(0)
    end

    it "should return stack hashes with all required keys" do
      example =  { :stacks => [
        { :name => "Monitoring", :stack_id => "d30104ef" },
        { :name => "Reports",    :stack_id => "ffa0116d" },
        { :name => "RailsApp",   :stack_id => "ac263281" }
      ] }

      api_helper.stub(:api).with("describe_stacks").and_return(example)
      api_helper.stacks.each do |stack|
        stack.should have_key(:name)
        stack.should have_key(:id)
      end
    end
  end

  context "#instances" do
    it "should return list of available instances of a given stack" do
      example =  { :instances => [
        { :hostname => "rails-app1", :public_dns => "ra1.aws-amazon.com",    :status => "online", :availability_zone =>  "eu-west-1a"},
        { :hostname => "db-master1", :public_dns => "db1.aws-amazon.com",    :status => "online", :availability_zone =>  "eu-west-1a"},
        { :hostname => "worker1",    :public_dns => "w1.aws.aws-amazon.com", :status => "online", :availability_zone =>  "eu-west-1a"}
      ] }

      api_helper.stub(:api).with("describe_instances", {:stack_id =>"fake-id"}).and_return(example)
      api_helper.instances("fake-id").size.should be(3)
    end

    it "should ignore instances with status other than 'online'" do
      example =  { :instances => [
        { :name => "rails-app1", :public_dns => "ra1.aws-amazon.com",    :status => "running_setup",   :availability_zone =>  "eu-west-1a"},
        { :hostname => "db-master1", :public_dns => "db1.aws-amazon.com",    :status => "setup_failed",    :availability_zone =>  "eu-west-1a"},
        { :hostname => "worker1",    :public_dns => "w1.aws.aws-amazon.com", :status => "connection_lost", :availability_zone =>  "eu-west-1a"}
      ] }

      api_helper.stub(:api).with("describe_instances", {:stack_id =>"fake-id"}).and_return(example)
      api_helper.instances("fake-id").size.should be(0)
    end


    it "should return instance hashes with all required keys" do
      example =  { :instances => [
        { :hostname => "rails-app1", :public_dns => "ra1.aws-amazon.com",    :status => "online", :availability_zone =>  "eu-west-1a"},
        { :hostname => "db-master1", :public_dns => "db1.aws-amazon.com",    :status => "online", :availability_zone =>  "eu-west-1a"},
        { :hostname => "worker1",    :public_dns => "w1.aws.aws-amazon.com", :status => "online", :availability_zone =>  "eu-west-1a"}
      ] }

      api_helper.stub(:api).with("describe_instances", {:stack_id =>"fake-id"}).and_return(example)
      api_helper.instances("fake-id").each do |instance|
        instance.should have_key(:name)
        instance.should have_key(:public_dns)
        instance.should have_key(:availability_zone)
      end
    end
  end

  context "caching" do

    it "should cache stacks" do
      example =  { :stacks => [
        { :name => "Monitoring", :stack_id => "d30104ef" }
      ] }

      api_helper.stub(:api).with("describe_stacks").and_return(example)
      api_helper.stacks # --> response goes to cache
      cache = api_helper.send("load_cache")
      cache['all_stacks'].should =~ [ { :name => "Monitoring", :id => "d30104ef" } ]
    end

    it "should cache instances" do
      example =  { :instances => [
        { :hostname => "rails-app1", :public_dns => "ra1.aws-amazon.com",    :status => "online", :availability_zone =>  "eu-west-1a"}
      ] }

      api_helper.stub(:api).with("describe_instances", {:stack_id =>"fake-id"}).and_return(example)
      api_helper.instances("fake-id") # ---> response goes to cache
      cache = api_helper.send("load_cache")
      cache['stack-fake-id---instances'].should =~ [{ :name => "rails-app1", :public_dns => "ra1.aws-amazon.com", :availability_zone =>  "eu-west-1a"}]
    end

    it "should be disengageable" do
      example =  { :stacks => [
        { :name => "Monitoring", :stack_id => "d30104ef" }
      ] }

      api_helper.stub(:api).with("describe_stacks").and_return(example)
      api_helper.stub(:caching_enabled?).and_return(false)
      api_helper.should_receive(:set_cache).with(any_args()).twice
      api_helper.stacks # no caching!
      api_helper.stacks # no caching!
    end

  end


end