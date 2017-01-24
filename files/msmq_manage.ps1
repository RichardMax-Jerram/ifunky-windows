param (
	$queueName = "",
	$transactional = $true,
	$action = "create",
	$user = "everyone",
	$permission = "full"
)

[Reflection.Assembly]::LoadWithPartialName("System.Messaging") | Out-Null

function DoesQueueExist($name) {
	return ([System.Messaging.MessageQueue]::Exists($name))
}

switch ($action) {
	"create" {
		if (!(DoesQueueExist($queueName))){
			Write-Host "Creating $queueName transactional: $transactional"
			$queue = [System.Messaging.MessageQueue]::Create($queueName, $transactional)
			if ($permission -eq "full") {
				Write-Host "Granting full permissions to $user"
				$queue.SetPermissions($user,
								[System.Messaging.MessageQueueAccessRights]::FullControl,
								[System.Messaging.AccessControlEntryType]::Allow)
			} else {
				Write-Host "Granting basic permissions to $user"
				$queue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::DeleteMessage, [System.Messaging.AccessControlEntryType]::Set)
        $queue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::GenericWrite, [System.Messaging.AccessControlEntryType]::Allow)
        $queue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::PeekMessage, [System.Messaging.AccessControlEntryType]::Allow)
        $queue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::ReceiveJournalMessage, [System.Messaging.AccessControlEntryType]::Allow)
			}
		}
		else {
			Write-Host "Queue: $queueName already exists...ignoring"
		}
		break
	}
	"delete" {
		if (DoesQueueExist($queueName)){
			Write-Host "Deleting queue: $queueName"
			[System.Messaging.MessageQueue]::Delete($queueName)
		}
		else {
			Write-Host "Queue: $queueName does not exists...ignoring"
		}
		break
	}
	default {
		Write-Error "Unknown action: $action"
	}
}
