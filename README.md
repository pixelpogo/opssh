# Opssh

Opssh is a tiny tool, that utilizes the [OpsWorks API](http://docs.aws.amazon.com/opsworks/latest/APIReference/Welcome.html) to gather information, about stacks and their instances, required to start a SSH session on a single AWS EC2 instance.

You can select the stack and the desired instance interactively:

    =============================================================

             Opssh - ssh to your OpsWorks instance

    =============================================================


    Available OpsWorks stacks:
    -----------------------------
      [1]. My Fancy Todo App
      [2]. Google-Clone
      [3]. Next big thing
      [4]. Blog in 5 minutes example
      [5]. Continuous Integration

    --> Please select stack:


## Installation

    $ gem install opssh

## Usage

Just invoke

    $ opssh

Hint: Opssh caches API requests by default in `~/.opssh_api_cache` to improve speed.

Use the `-n` option if you want to avoid caching.

    $ opssh -n

Clear the API cache with

    $ opssh -c


## Configuration

Opssh will create a configuration file in `~/.opssh`. It's a [YAML](http://en.wikipedia.org/wiki/YAML) file.

The configuration can contain your AWS credentials and/or your customized ssh command.

### AWS Credentials

To add credentials for your [IAM](http://aws.amazon.com/iam/) user with permissions to access the OpsWorks API remove the comments and put in the keys:


    aws_credentials:
      access_key_id: YOURKEYGOESHERE
      secret_access_key: YOURSECRETKEYGOESHERE


**HINT**:
If you don't want to store credentials in the configuration file, you can use [environment variables](http://en.wikipedia.org/wiki/Environment_variable), as well. Opssh expects them to be declared as *OPSWORKS_ACCESS_KEY_ID* and *OPSWORKS_SECRET_ACCESS_KEY*.


##Custom ssh command

You need special ssh options, e.g. to use a specific ssh key or to provide a certain login name? No problem, just put it in `ssh_command` in the config:

    ssh_command: ssh -l yoursshusername -i /path/to/your/privatekey


Opssh will then add the public DNS name of your instance to `ssh_command`.

## History

This is a port of [Scassh](https://github.com/pixelpogo/scassh), which was build for Scalarium, the ancestor of OpsWorks.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
