# == Define: windows::messagequeue
#
# Optionally installs MSMQ and creates/removes message queues
#
# == Examnple ==
#
# windows::messagequeue { '.\private$\Example.queueName':
#  transactional => true,
#
# }
# === Parameters
#
# [*$queue_name*]
#  Required, name of the message queue to perform action on
#
# [*transactional*]
#  Required, true if queue should be transactional.  Defaults to true
#
# [*action*]
#  Required.  Create|Delete to either create or delete message queue.  Default is create.
#
# [*user*]
#  Required.  User to grant queue permissions to.  Defaults to everyone.
#
# [*permission*]
#  Required.  full|restricted to grant FullControl or only DeleteMessage,GenericWrite,PeekMessage,ReceiveJournalMessage
#
# [*timeout*]
# Execution timeout in seconds for the unzip command; 0 disables timeout.  Defaults to 300 seconds (5 minutes).
#
# [*manage_msmq*]
# Required.  If true then the MSMQ feature will be installed if required.
#
define windows::messagequeue(
  $queue_name      = $name,
  $transactional  = true,
  $action         = 'create',
  $user           = 'everyone',
  $permission     = 'full',
  $timeout        = 300,
  $manage_msmq    = false,
) {

  validate_re($action,['^(create|delete)$'])
  validate_re($permission,['^(full|restricted)$'])

  if ($manage_msmq) {
    windowsfeature { 'MSMQ':
      ensure  => present,
    }
  }

  file { 'msmq_manage.ps1':
    ensure  => present,
    path    => 'C:\windows\\temp\\msmq_manage.ps1',
    content => file('windows/msmq_manage.ps1'),
  }

  exec { "msmq-${name}":
    #command     => template('windows/msmq_manage.ps1.erb'),
    command     => "powershell.exe -ExecutionPolicy ByPass -File C:\windows\temp\msmq_manage.ps1",
    provider    => 'powershell',
    timeout     => $timeout,
    require     => [ Windowsfeature['MSMQ'], file['msmq_manage.ps1'] ]
  }
}