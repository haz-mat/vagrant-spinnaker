require 'yaml'

begin
  config_file = YAML.load_file('cfg.yml')
rescue Errno::ENOENT
  raise Vagrant::Errors::VagrantError.new,
        'Configuration file cfg.yml not found but required.'
rescue Psych::SyntaxError
  raise Vagrant::Errors::VagrantError.new,
        'Configuration file cfg.yml malformed.'
end

base_url = config_file.key?('base_url') ?
  config_file['base_url'] :
  'http://localhost'
deck_port = config_file.key?('deck_port') ?
  config_file['deck_port'] :
  9000
gate_port = config_file.key?('gate_port') ?
  config_file['gate_port'] :
  8084
spinnaker_version = config_file.key?('spinnaker_version') ?
  config_file['spinnaker_version'] :
  '1.7.1'

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.network 'forwarded_port', guest: deck_port, host: deck_port
  config.vm.network 'forwarded_port', guest: gate_port, host: gate_port
  config.vm.hostname = 'spinnaker.local'
  config.ssh.forward_agent = true
  # Sets vm name.
  config.vm.define 'spinnaker' do |spinnaker|
  end
  config.vm.provider 'virtualbox' do |vb|
    vb.name = 'spinnaker'
    vb.memory = '6144'
    # Disable console log file.
    vb.customize ['modifyvm', :id, '--uartmode1', 'disconnected']
  end
  config.vm.synced_folder './',
                          '/vagrant',
                          SharedFoldersEnableSymlinksCreate: false

  config.vm.provision 'shell',
                      privileged: false,
                      path: 'provision.sh',
                      env: { 'AWS_ACCOUNT_ID' =>
                               config_file['aws_account_id'],
                             'AWS_ACCESS_KEY_ID' =>
                               config_file['aws_access_key_id'],
                             'AWS_SECRET_ACCESS_KEY' =>
                               config_file['aws_secret_access_key'],
                             'BASE_URL' => base_url,
                             'DECK_PORT' => deck_port,
                             'GATE_PORT' => gate_port,
                             'SPINNAKER_VERSION' => spinnaker_version }
end
