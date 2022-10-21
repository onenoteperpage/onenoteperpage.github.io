###############################################################
#  Maintenance page (maintenance.ps1 together with index.html in same directory or index.html in s3://rews-syda-deployment/maintenance/index.html)
#  version : 1 
#  usage: . .\maintenance.ps1 (make a ELB selection, if more than one listener, selection will be offered)
#		: to use by sourcing the powershell file, putting a dot prior to the file . .\maintenance.ps1
#		: show-rule (display rule of listener)
#		: add-rule  URI-pattern maintenance-web-template.html priority (e.g.: add-rule /*prod/* .\index.html 100)
#		: add-rule -pattern /client*/* -template s3://rews-syda-deployment/maintenance/index.html -priority 100
#		: add-rule -hostheader sso.client.com -template s3://rews-syda-deployment/maintenance/index.html -priority 100
#		: add-rule -pattern /client*/* -template .\index.html -priority 100
#		: get-rule  URI-pattern (return rule object)
#		: remove-rule (remove rule as found by get-rule. e.g. get-rule /*prod/* | remove-rule)

function generate-tempfile
{
	"temp-{0}" -f (get-date -UFormat "%Y%m%d%H%M%S")
}
function get-bucketitem
{ # expect s3://bucket/key format
	param($s3)
	if ($s3 -match 's3://(.*)/(.+)')
	{
		$first_slash=$matches[1].IndexOf('/')
		$key =$matches[1].substring( $first_slash , ($matches[1].length - $first_slash) )
		$bucket = $matches[1].substring(0,$first_slash)
		
		$item = '{0}/{1}' -f $key,$matches[2]
		try {
			$temp=join-path -path $PSScriptRoot -childpath (generate-tempfile)
			read-s3object -bucketname $bucket -key $item $temp
			$temp
		}
		catch {
			write-host -ForegroundColor red ('Unable to retrieve S3 item: {0}' -f $s3)
			$false
		}
	}
}
function get-selection
{ 	Param($obj,$attribute,$ask=$false)
	
	for ($i=0; $i -lt ($obj.count); $i++ )
	{
		$line=@"
{0}`t{1}
"@ -f $i,[string]($obj[$i] | select $attribute)
		write-host $line
	}
	if($ask){
		$response = get-response 0 $obj.count
		$obj[$response]
	}
}

function get-response
{
	param ($min,$max)
	do
	{
		$answer = [int](read-host "please select:")
	} until ( ($answer -lt $max) -and ($answer -ge $min) )
	$answer
}

function show-rule
{
	#param($rules)
	get-selection (Get-ELB2Rule -ListenerArn $lst.listenerarn).conditions.values 
	#get-selection $rules.conditions.values 
}

function get-rule
{
	param($pattern,$all)
	$found=$false
	if ($pattern)
	{
		$rules = Get-ELB2Rule -ListenerArn $lst.listenerarn
		foreach ($r in $rules)
		{
			if ($r.conditions.values -eq $pattern)
			{	
				$found=$true
				break
			}
		}
	}
	if ($found)
	{	
		$r
	}
	else
	{
		$false
	}
	if ($all)
	{
		Get-ELB2Rule -ListenerArn $lst.listenerarn |where IsDefault -ne $true
	}
}
function remove-rule
{
 	Param(
	[Parameter(
		ValueFromPipeline)
		]
	$InputObject,
	$rule
    )
    BEGIN{}
    PROCESS
	{
		if  ( ($rule) -and ( get-elb2rule -RuleArn $rule.RuleArn ) ) 
		{	
			$r = $rule
			$proceed = $true
		} elseif ( ($inputobject) -and ( get-elb2rule -RuleArn $inputobject.RuleArn ) ) 
		{
			$r = $inputobject
			$proceed = $true
		}

		if ($proceed)
		{	
			remove-elb2rule -rulearn $r.RuleArn -force 
		}
	}
}
function add-rule
{
	param($pattern,$template,$priority,$hostheader)
	if ($template -match 's3://(.*)/(.+)')
	{
		$s3_template_file = (get-bucketitem $template)
		if ( ($s3_template_file) -and (test-path $s3_template_file) )
		{	
			write-host -ForegroundColor green ("Using template from S3: {0} , cache copy: {1}" -f $template, $s3_template_file.fullname)
			$template = $s3_template_file.fullname
		} else 
		{	
			write-host -ForegroundColor red ("Fail to get template from S3: {0}" -f $template)
			$template = $false
		}
	}
	if ( ( ($pattern) -or ($hostheader)) -and ( (test-path $template) -and ($priority) ) )
	{
	
		$actn=New-Object Amazon.ElasticLoadBalancingV2.Model.Action
		$fixedresponse_cfg = new-object Amazon.ElasticLoadBalancingV2.Model.FixedResponseActionConfig
		$fixedresponse_cfg.ContentType ='text/html' 
		$fixedresponse_cfg.statuscode='200'
		$fixedresponse_cfg.MessageBody = ((gc $template) -replace '##MESSAGE##',$message )
		$actn.FixedResponseConfig=$fixedresponse_cfg
		$actn.order=1
		$actn.type='fixed-response'

		$nr=New-Object Amazon.ElasticLoadBalancingV2.Model.RuleCondition
		if ($pattern){
			$path_pattern_config=new-object Amazon.ElasticLoadBalancingV2.Model.PathPatternConditionConfig
			$path_pattern_config.Values=$pattern
			$nr.PathPatternConfig=$path_pattern_config
			$nr.field='path-pattern'
		}
		if ($hostheader){
			$host_header_config=new-object Amazon.ElasticLoadBalancingV2.Model.HostHeaderConditionConfig
			$host_header_config.values=$hostheader
			$nr.HostHeaderConfig=$host_header_config
			$nr.field='host-header'
		}

		$o=New-ELB2Rule -ListenerArn $lst.ListenerArn -action $actn -Condition $nr -Priority $priority
		$o
		if ( ((gci $template).name).StartsWith('temp-') ) {remove-item $template}
		
	} else {
		write-host -ForegroundColor yellow "e.g. add-rule -pattern /client*/* -template s3://rews-syda-deployment/maintenance/index.html -priority 100"
		write-host -ForegroundColor yellow "URI pattern needed and/or Template file path invalid"
		write-host -ForegroundColor yellow "Each rule will need a priorty e.g. 100"
	}
}
function set-maint-message
{
	param($minute)
$m=@"
<p>The service is currently under maintenance.</p>

<p>Estimate time of completion is around ##TIME##</p>
"@ -replace '##TIME##', (((get-date).AddMinutes($minute) ).ToString('dd/MM/yyyy HH:mm') )
	$m
	
}
$message=@"
<p>The service is currently under maintenance.</p>

<p>Please check back at a later time.</p>
"@

$continue=$true
$llb=Get-ELB2LoadBalancer
$lb=get-selection $llb dnsname $true
$llst=Get-ELB2Listener -LoadBalancerArn $lb.LoadBalancerArn
if ($llst.count -gt 1)
{
	$lst = get-selection $llst port
} elseif ($llst.count -eq 1)
{
	$lst=$llst
} else
{
	write-host "ELB selected has no listener"
	$continue=$false
}

if ($continue)
{
	$rules=Get-ELB2Rule -ListenerArn $lst.listenerarn

}
