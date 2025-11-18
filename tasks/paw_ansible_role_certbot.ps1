# Puppet task for executing Ansible role: ansible_role_certbot
# This script runs the entire role via ansible-playbook

$ErrorActionPreference = 'Stop'

# Determine the ansible modules directory
if ($env:PT__installdir) {
  $AnsibleDir = Join-Path $env:PT__installdir "lib\puppet_x\ansible_modules\ansible_role_certbot"
} else {
  # Fallback to Puppet cache directory
  $AnsibleDir = "C:\ProgramData\PuppetLabs\puppet\cache\lib\puppet_x\ansible_modules\ansible_role_certbot"
}

# Check if ansible-playbook is available
$AnsiblePlaybook = Get-Command ansible-playbook -ErrorAction SilentlyContinue
if (-not $AnsiblePlaybook) {
  $result = @{
    _error = @{
      msg = "ansible-playbook command not found. Please install Ansible."
      kind = "puppet-ansible-converter/ansible-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Check if the role directory exists
if (-not (Test-Path $AnsibleDir)) {
  $result = @{
    _error = @{
      msg = "Ansible role directory not found: $AnsibleDir"
      kind = "puppet-ansible-converter/role-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Detect playbook location (collection vs standalone)
# Collections: ansible_modules/collection_name/roles/role_name/playbook.yml
# Standalone: ansible_modules/role_name/playbook.yml
$CollectionPlaybook = Join-Path $AnsibleDir "roles\paw_ansible_role_certbot\playbook.yml"
$StandalonePlaybook = Join-Path $AnsibleDir "playbook.yml"

if ((Test-Path (Join-Path $AnsibleDir "roles")) -and (Test-Path $CollectionPlaybook)) {
  # Collection structure
  $PlaybookPath = $CollectionPlaybook
  $PlaybookDir = Join-Path $AnsibleDir "roles\paw_ansible_role_certbot"
} elseif (Test-Path $StandalonePlaybook) {
  # Standalone role structure
  $PlaybookPath = $StandalonePlaybook
  $PlaybookDir = $AnsibleDir
} else {
  $result = @{
    _error = @{
      msg = "playbook.yml not found in $AnsibleDir or $AnsibleDir\roles\paw_ansible_role_certbot"
      kind = "puppet-ansible-converter/playbook-not-found"
    }
  }
  Write-Output ($result | ConvertTo-Json)
  exit 1
}

# Build extra-vars from PT_* environment variables
$ExtraVars = @{}
if ($env:PT_ansible_managed) {
  $ExtraVars['ansible_managed'] = $env:PT_ansible_managed
}
if ($env:PT_item) {
  $ExtraVars['item'] = $env:PT_item
}
if ($env:PT_certbot_auto_renew) {
  $ExtraVars['certbot_auto_renew'] = $env:PT_certbot_auto_renew
}
if ($env:PT_certbot_auto_renew_user) {
  $ExtraVars['certbot_auto_renew_user'] = $env:PT_certbot_auto_renew_user
}
if ($env:PT_certbot_auto_renew_hour) {
  $ExtraVars['certbot_auto_renew_hour'] = $env:PT_certbot_auto_renew_hour
}
if ($env:PT_certbot_auto_renew_minute) {
  $ExtraVars['certbot_auto_renew_minute'] = $env:PT_certbot_auto_renew_minute
}
if ($env:PT_certbot_auto_renew_options) {
  $ExtraVars['certbot_auto_renew_options'] = $env:PT_certbot_auto_renew_options
}
if ($env:PT_certbot_testmode) {
  $ExtraVars['certbot_testmode'] = $env:PT_certbot_testmode
}
if ($env:PT_certbot_hsts) {
  $ExtraVars['certbot_hsts'] = $env:PT_certbot_hsts
}
if ($env:PT_certbot_create_if_missing) {
  $ExtraVars['certbot_create_if_missing'] = $env:PT_certbot_create_if_missing
}
if ($env:PT_certbot_create_method) {
  $ExtraVars['certbot_create_method'] = $env:PT_certbot_create_method
}
if ($env:PT_certbot_create_extra_args) {
  $ExtraVars['certbot_create_extra_args'] = $env:PT_certbot_create_extra_args
}
if ($env:PT_certbot_admin_email) {
  $ExtraVars['certbot_admin_email'] = $env:PT_certbot_admin_email
}
if ($env:PT_certbot_expand) {
  $ExtraVars['certbot_expand'] = $env:PT_certbot_expand
}
if ($env:PT_certbot_webroot) {
  $ExtraVars['certbot_webroot'] = $env:PT_certbot_webroot
}
if ($env:PT_certbot_certs) {
  $ExtraVars['certbot_certs'] = $env:PT_certbot_certs
}
if ($env:PT_certbot_create_command) {
  $ExtraVars['certbot_create_command'] = $env:PT_certbot_create_command
}
if ($env:PT_certbot_create_standalone_stop_services) {
  $ExtraVars['certbot_create_standalone_stop_services'] = $env:PT_certbot_create_standalone_stop_services
}
if ($env:PT_certbot_install_method) {
  $ExtraVars['certbot_install_method'] = $env:PT_certbot_install_method
}
if ($env:PT_certbot_repo) {
  $ExtraVars['certbot_repo'] = $env:PT_certbot_repo
}
if ($env:PT_certbot_version) {
  $ExtraVars['certbot_version'] = $env:PT_certbot_version
}
if ($env:PT_certbot_keep_updated) {
  $ExtraVars['certbot_keep_updated'] = $env:PT_certbot_keep_updated
}
if ($env:PT_certbot_dir) {
  $ExtraVars['certbot_dir'] = $env:PT_certbot_dir
}

$ExtraVarsJson = $ExtraVars | ConvertTo-Json -Compress

# Execute ansible-playbook with the role
Push-Location $PlaybookDir
try {
  ansible-playbook playbook.yml `
    --extra-vars $ExtraVarsJson `
    --connection=local `
    --inventory=localhost, `
    2>&1 | Write-Output
  
  $ExitCode = $LASTEXITCODE
  
  if ($ExitCode -eq 0) {
    $result = @{
      status = "success"
      role = "ansible_role_certbot"
    }
  } else {
    $result = @{
      status = "failed"
      role = "ansible_role_certbot"
      exit_code = $ExitCode
    }
  }
  
  Write-Output ($result | ConvertTo-Json)
  exit $ExitCode
}
finally {
  Pop-Location
}
