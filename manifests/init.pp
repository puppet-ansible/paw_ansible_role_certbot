# paw_ansible_role_certbot
# @summary Manage paw_ansible_role_certbot configuration
#
# @param ansible_managed
# @param item
# @param certbot_auto_renew Certbot auto-renew cron job configuration (for certificate renewals).
# @param certbot_auto_renew_user
# @param certbot_auto_renew_hour
# @param certbot_auto_renew_minute
# @param certbot_auto_renew_options
# @param certbot_testmode
# @param certbot_hsts
# @param certbot_create_if_missing Parameters used when creating new Certbot certs.
# @param certbot_create_method
# @param certbot_create_extra_args
# @param certbot_admin_email
# @param certbot_expand
# @param certbot_webroot Default webroot, overwritten by individual per-cert webroot directories
# @param certbot_certs
# @param certbot_create_command
# @param certbot_create_standalone_stop_services
# @param certbot_install_method Available options: 'package', 'snap', 'source'.
# @param certbot_repo Source install configuration.
# @param certbot_version
# @param certbot_keep_updated
# @param certbot_dir Where to put Certbot when installing from source.
# @param par_vardir Base directory for Puppet agent cache (uses lookup('paw::par_vardir') for common config)
# @param par_tags An array of Ansible tags to execute (optional)
# @param par_skip_tags An array of Ansible tags to skip (optional)
# @param par_start_at_task The name of the task to start execution at (optional)
# @param par_limit Limit playbook execution to specific hosts (optional)
# @param par_verbose Enable verbose output from Ansible (optional)
# @param par_check_mode Run Ansible in check mode (dry-run) (optional)
# @param par_timeout Timeout in seconds for playbook execution (optional)
# @param par_user Remote user to use for Ansible connections (optional)
# @param par_env_vars Additional environment variables for ansible-playbook execution (optional)
# @param par_logoutput Control whether playbook output is displayed in Puppet logs (optional)
# @param par_exclusive Serialize playbook execution using a lock file (optional)
class paw_ansible_role_certbot (
  Optional[String] $ansible_managed = undef,
  Optional[String] $item = undef,
  Boolean $certbot_auto_renew = true,
  String $certbot_auto_renew_user = '{{ ansible_user | default(lookup(\'env\', \'USER\')) }}',
  String $certbot_auto_renew_hour = '3',
  String $certbot_auto_renew_minute = '30',
  String $certbot_auto_renew_options = '--quiet',
  Boolean $certbot_testmode = false,
  Boolean $certbot_hsts = false,
  Boolean $certbot_create_if_missing = false,
  String $certbot_create_method = 'standalone',
  Optional[String] $certbot_create_extra_args = undef,
  String $certbot_admin_email = 'email@example.com',
  Boolean $certbot_expand = false,
  String $certbot_webroot = '/var/www/letsencrypt',
  Array $certbot_certs = [],
  String $certbot_create_command = '{{ certbot_script }} certonly --{{ certbot_create_method  }} {{ \'--hsts\' if certbot_hsts else \'\' }} {{ \'--test-cert\' if certbot_testmode else \'\' }} --noninteractive --agree-tos --email {{ cert_item.email | default(certbot_admin_email) }} {{ \'--expand\' if certbot_expand else \'\' }} {{ \'--webroot-path \' if certbot_create_method == \'webroot\'  else \'\' }} {{ cert_item.webroot | default(certbot_webroot) if certbot_create_method == \'webroot\' else \'\' }} {{ certbot_create_extra_args }} --cert-name {{ cert_item_name }} -d {{ cert_item.domains | join(\',\') }} {{ \'--expand\' if certbot_expand else \'\' }} {{ \'--pre-hook /etc/letsencrypt/renewal-hooks/pre/stop_services\'\n  if certbot_create_standalone_stop_services and certbot_create_method == \'standalone\'\nelse \'\' }} {{ \'--post-hook /etc/letsencrypt/renewal-hooks/post/start_services\'\n  if certbot_create_standalone_stop_services and certbot_create_method == \'standalone\'\nelse \'\' }} {{ "--deploy-hook \'" ~ cert_item.deploy_hook ~ "\'"\n  if \'deploy_hook\' in cert_item\nelse \'\' }}',
  Array $certbot_create_standalone_stop_services = ['nginx'],
  String $certbot_install_method = 'package',
  String $certbot_repo = 'https://github.com/certbot/certbot.git',
  String $certbot_version = 'master',
  Boolean $certbot_keep_updated = true,
  String $certbot_dir = '/opt/certbot',
  Optional[Stdlib::Absolutepath] $par_vardir = undef,
  Optional[Array[String]] $par_tags = undef,
  Optional[Array[String]] $par_skip_tags = undef,
  Optional[String] $par_start_at_task = undef,
  Optional[String] $par_limit = undef,
  Optional[Boolean] $par_verbose = undef,
  Optional[Boolean] $par_check_mode = undef,
  Optional[Integer] $par_timeout = undef,
  Optional[String] $par_user = undef,
  Optional[Hash] $par_env_vars = undef,
  Optional[Boolean] $par_logoutput = undef,
  Optional[Boolean] $par_exclusive = undef
) {
# Execute the Ansible role using PAR (Puppet Ansible Runner)
# Playbook synced via pluginsync to agent's cache directory
# Check for common paw::par_vardir setting, then module-specific, then default
$_par_vardir = $par_vardir ? {
  undef   => lookup('paw::par_vardir', Stdlib::Absolutepath, 'first', '/opt/puppetlabs/puppet/cache'),
  default => $par_vardir,
}
$playbook_path = "${_par_vardir}/lib/puppet_x/ansible_modules/ansible_role_certbot/playbook.yml"

par { 'paw_ansible_role_certbot-main':
  ensure        => present,
  playbook      => $playbook_path,
  playbook_vars => {
        'ansible_managed' => $ansible_managed,
        'item' => $item,
        'certbot_auto_renew' => $certbot_auto_renew,
        'certbot_auto_renew_user' => $certbot_auto_renew_user,
        'certbot_auto_renew_hour' => $certbot_auto_renew_hour,
        'certbot_auto_renew_minute' => $certbot_auto_renew_minute,
        'certbot_auto_renew_options' => $certbot_auto_renew_options,
        'certbot_testmode' => $certbot_testmode,
        'certbot_hsts' => $certbot_hsts,
        'certbot_create_if_missing' => $certbot_create_if_missing,
        'certbot_create_method' => $certbot_create_method,
        'certbot_create_extra_args' => $certbot_create_extra_args,
        'certbot_admin_email' => $certbot_admin_email,
        'certbot_expand' => $certbot_expand,
        'certbot_webroot' => $certbot_webroot,
        'certbot_certs' => $certbot_certs,
        'certbot_create_command' => $certbot_create_command,
        'certbot_create_standalone_stop_services' => $certbot_create_standalone_stop_services,
        'certbot_install_method' => $certbot_install_method,
        'certbot_repo' => $certbot_repo,
        'certbot_version' => $certbot_version,
        'certbot_keep_updated' => $certbot_keep_updated,
        'certbot_dir' => $certbot_dir
              },
  tags          => $par_tags,
  skip_tags     => $par_skip_tags,
  start_at_task => $par_start_at_task,
  limit         => $par_limit,
  verbose       => $par_verbose,
  check_mode    => $par_check_mode,
  timeout       => $par_timeout,
  user          => $par_user,
  env_vars      => $par_env_vars,
  logoutput     => $par_logoutput,
  exclusive     => $par_exclusive,
}
}
