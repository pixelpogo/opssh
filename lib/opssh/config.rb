require 'tmpdir'
require 'etc'
require 'fileutils'

module Opssh

  class Config

    def self.aws_credentials
      credentials = aws_credentials_from_config
      credentials = aws_credentials_from_env if credentials.nil?
      raise "Can't find your AWS credentials! Please set them via #{config_file} or ENV variables" if credentials.nil?
      credentials
    end

    def self.ssh
      config = load_config
      if config.class == Hash && config.has_key?('ssh_command')
        config['ssh_command']
      else
        "ssh"
      end
    end

    def self.config_file
      Etc.getpwuid.dir. + "/.opssh"
    end

    private

    def self.load_config
      write_config_file unless File.exist?(config_file)
      YAML.load_file(config_file)
    end

    def self.write_config_file
      File.open(config_file, 'w') {|f| f.write(example_config_content)}
    end

    def self.aws_credentials_from_config
      config = load_config
      return if config.nil?
      if config.class == Hash && config['aws_credentials'].class == Hash
        config['aws_credentials']
      else
        nil
      end
    end

    def self.aws_credentials_from_env
      if !ENV['OPSWORKS_ACCESS_KEY_ID'].nil? && !ENV['OPSWORKS_SECRET_ACCESS_KEY'].nil?
        {'access_key_id' => ENV['OPSWORKS_ACCESS_KEY_ID'], 'secret_access_key' => ENV['OPSWORKS_SECRET_ACCESS_KEY']}
      end
    end


    def self.example_config_content
      <<-END.gsub(/^ {6}/, '')
      #===============================
      # YOUR OPSSH CONFIGURATION FILE
      #===============================
      #
      # Opssh expects your AWS credentials either to be
      # defined here or in environment variables named
      # OPSWORKS_ACCESS_KEY_ID and OPSWORKS_SECRET_ACCESS_KEY
      #
      #aws_credentials:
      #  access_key_id: YOURKEYGOESHERE
      #  secret_access_key: YOURSECRETKEYGOESHERE
      #
      # If you need special ssh options, you can specify them here
      # as well.
      #
      #ssh_command: ssh -l yoursshusername -i /path/to/your/privatekey
      END
    end

  end

end
