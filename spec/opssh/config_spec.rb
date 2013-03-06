require 'spec_helper'

describe Opssh::Config do

  context "#aws_credentials" do
    it "should use aws_credentials from config file" do
      keys = { 'aws_credentials' => { 'access_key_id' => "Foo", 'secret_access_key' => "Bar" } }
      Opssh::Config.stub(:load_config).and_return(keys)
      Opssh::Config.aws_credentials.should == keys['aws_credentials']
    end

    it "should use aws_credentials from ENV variables" do
      ENV['OPSWORKS_ACCESS_KEY_ID'] = "Foo"
      ENV['OPSWORKS_SECRET_ACCESS_KEY'] = "Bar"
      Opssh::Config.stub(:load_config).and_return({})
      Opssh::Config.aws_credentials.should == { 'access_key_id' => "Foo", 'secret_access_key' => "Bar" }
    end
  end

  context "#ssh" do
    it "should return custom ssh command from config file" do
      conf = {'aws_credentials' => {}, 'ssh_command' => "ssh -l yoursshusername -i /path/to/your/privatekey"}
      Opssh::Config.stub(:load_config).and_return(conf)
      Opssh::Config.ssh.should == conf['ssh_command']
    end
  end
end