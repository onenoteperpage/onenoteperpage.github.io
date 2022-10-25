function check-env
{
	write-host ("connection string : {0}/{1}@{2}" -f $env:schema,$env:passwd,$env:tns) -foreground green
	write-host ("`$env:dmp='{0}'" -f $env:dmp) 
	write-host ("`$env:client='{0}'" -f $env:client)
	write-host ("`$env:src_schema='{0}'" -f $env:src_schema) -foreground green
	write-host ("`$env:tgt_schema='{0}'" -f $env:tgt_schema) -foreground red
	
	write-host ("`$env:user_dmp='{0}'" -f $env:user_dmp) 
	
}
function kill-sqlconn
{ param($schema,$nonrds,$debug)
	if ($env:tgt_schema)
	{
		$tgt_schema=$env:tgt_schema
	}
	if ($schema)
	{
		$tgt_schema = $schema
	}

	if ($tgt_schema)
	{
		$sql=@"
set newpage 0; 
set echo off; 
set feedback off; 
set heading off; 
SELECT sid,serial# FROM v`$session WHERE username like '{0}' ORDER BY username ASC;
"@ -f $tgt_schema
		if ($debug)
		{	
			$output = $debug
		}
		else
		{
			$output=($sql | sqlplus -S dbadmin/$env:passwd@$env:tns)
		}
		$r=@"
==================================
SQL OUTPUT
{0}
==================================
"@ -f $output
		$env:output=$output
		write-host ('Result: {0}' -f $r)
		if ($output)
		{
			$f = $output.trim() -split '\s+'
			$count=$f.count
			0..($count/2) | % {
				$i=$_;'{0} {1}' -f $f[($i*2)], $f[($i*2)+1]
			# foreach ($l in ($output.trim() -split '\r?\n') ) 
			
				#$f = $l.trim() -split '\s+'
				if ($f)
				{
					'{0} {1} --' -f $f[$i*2],$f[($i*2)+1]
					$kill=@"
begin
	rdsadmin.rdsadmin_util.kill(
		sid    => {0},
		serial => {1},
		method => 'IMMEDIATE');
end;
/
"@ -f $f[($i*2)],$f[($i*2)+1]
					if ($nonrds)
					{
						$kill=@"
ALTER SYSTEM KILL SESSION '{0}, {1}' IMMEDIATE;
"@ -f $f[($i*2)],$f[($i*2)+1]
					}
					write-host $kill
					if (! $debug){
						$kill | sqlplus -S dbadmin/$env:passwd@$env:tns
					}
				}
				
			}
		} else {
			write-host ('No session detected')
		}
	} else {
		write-host 'no schema and or env specified'
	}
	
}

function read-dpfile
{ param($logfile)
	if ($logfile)
	{
		$sql=@"
set newpage 0; 
set echo off; 
set feedback off; 
set heading off; 
SET LINESIZE 500;
select * from table
    (rdsadmin.rds_file_util.read_text_file(
        p_directory => 'DATA_PUMP_DIR',
        p_filename  => '{0}'));
"@ -f $logfile
		if ($debug)
		{	
			$output = $debug
		}
		else
		{
			$output=($sql | sqlplus -S dbadmin/$env:passwd@$env:tns)
			$output
		}
	} else {
		write-host 'no logfile specified'
	}
	
}

function download-dump
{	param($dmp,$client,$count=0)
	if ( (! $dmp) -and (! $env:dmp) )
	{
		write-host "Neither dmp or environment dmp has been specified"
	} else 
	{
		$continue = $true
		if ($env:dmp)
		{
			$dumpfile = $env:dmp
		} 
		# want to override if param dmp is specified
		if ($dmp)
		{
			$dumpfile = $dmp
		}
		if ($env:client)
		{
			$client_prefix = $env:client
		} 
		# param client is specified to override env
		if ($client)
		{
			$client_prefix = $client
		}
		if ( ($dumpfile.contains('%U')) -and ($count -gt 0) )
		{
			$list=''
			1..$count | % {
				$file = $dumpfile -replace '%U',('{0:d2}' -f $_)

				if ($_ -eq 1) 
				{
					$list = $file 
				} else {
					$list = $list + ',' +$file
				}
			}
		} elseif ( -not ($dumpfile.contains('%U') )  )
		{
			$list = $dumpfile
		}
		else
		{
			write-host -foreground red ("Dump file has %U, need to specify -count nbr")
			$continue=$false
		}
		if ($continue)
		{	$env:taskid = ''
			foreach ( $f in ($list -split ',') )
			{
				# Transfer here
				$dwnld=@"
set pages 0
set lines 300
set heading off

SELECT rdsadmin.rdsadmin_s3_tasks.download_from_s3(
      p_bucket_name    =>  'rews-syda-dbdump1', 
      p_s3_prefix      =>  '{0}/{1}', 
      p_directory_name =>  'DATA_PUMP_DIR') 
   AS TASK_ID FROM DUAL;
   

exit;

"@ -f $client_prefix,$f

				## $dwnld | out-file -encoding ascii dwnload.sql
				$output=($dwnld | sqlplus -s $env:schema`/$env:passwd`@$env:tns )
				$taskid=($output -split '\r?\n')[0]
				#$env:taskid = $taskid
				$taskid
				if ($env:taskid){$env:taskid=$env:taskid + ',' + $taskid } else { $env:taskid=$taskid }
			}
		}
	}
}

function upload-dump
{	
	param($dmp,$client,$count=0)
	if ( (! $dmp) -and (! $env:dmp) )
	{
		write-host "Neither dmp or environment dmp has been specified"
	} else 
	{
		$continue = $true
		if ($env:dmp)
		{
			$dumpfile = $env:dmp
		} 
		# want to override if param dmp is specified
		if ($dmp)
		{
			$dumpfile = $dmp
		}
		if ($env:client)
		{
			$client_prefix = $env:client
		} 
		# param client is specified to override env
		if ($client)
		{
			$client_prefix = $client
		}
		if ( ($dumpfile.contains('%U')) -and ($count -gt 0) )
		{
			$list=''
			1..$count | % {
				$file = $dumpfile -replace '%U',('{0:d2}' -f $_)

				if ($_ -eq 1) 
				{
					$list = $file 
				} else {
					$list = $list + ',' +$file
				}
			}
		} elseif ( -not ($dumpfile.contains('%U') )  )
		{
			$list = $dumpfile
		}
		else
		{
			write-host -foreground red ("Dump file has %U, need to specify -count nbr")
			$continue=$false
		}
		if ($continue)
		{	$env:taskid = ''
			foreach ( $f in ($list -split ',') )
			{
				# Transfer here
				$upld=@"
set pages 0
set lines 300
set heading off
SELECT rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
      p_bucket_name    =>  'rews-syda-dbdump1', 
      p_prefix         =>  '{0}', 
      p_s3_prefix      =>  '{1}/', 
      p_directory_name =>  'DATA_PUMP_DIR') 
   AS TASK_ID FROM DUAL;

exit;

"@ -f $f,$client_prefix
				write-host -foreground white ("{0}" -f $upld)
				#  $upld | out-file -encoding ascii upload.sql
				$output=($upld | sqlplus -s $env:schema`/$env:passwd`@$env:tns )
				$taskid=($output -split '\r?\n')[0]
				$taskid
				#$env:taskid = $env:taskid + ',' + $taskid
				if ($env:taskid){$env:taskid=$env:taskid + ',' + $taskid } else { $env:taskid=$taskid }
			}
		}
	}
}


function transfer-status
{
	param($taskid)
	if ($env:taskid)
	{
		$tid = $env:taskid
	} 
	# param taskid is specified to override env
	if ($taskid)
	{
		$tid = $taskid
	}
	foreach ($t in ($tid -split ',') )
	{ # $t is task-id
		if ($t)
		{
			$status=@"
set pages 0
set lines 300
set heading off
SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-{0}.log'));    

exit;
"@ -f $t

			## $status | out-file -encoding ascii status.sql
			$output=($status | sqlplus -s $env:schema`/$env:passwd`@$env:tns )
			write-host -foreground yellow ('-'*80)
			write-host -foreground yellow $t
			write-host -foreground yellow ('-'*80)
			write-host -foreground green $output
			write-host -foreground yellow ('-'*80)
		}
	}
}

function put-file
{ 	param ($df)
$sql=@"
BEGIN
DBMS_FILE_TRANSFER.PUT_FILE(
source_directory_object       => 'DATA_PUMP_DIR',
source_file_name              => '{0}',
destination_directory_object  => 'DATA_PUMP_DIR',
destination_file_name         => '{0}', 
destination_database          => 'NONPROD' 
);
END;
/ 
"@ -f $df
	#$sql = "SELECT filename FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));"
	$env:sql=$sql
	#sqlexec $sql
	
}

function sqlexec{
	param($sqlsmnt)
	$sql = @"
set pages 0
set lines 300
set heading off
$sqlsmnt

exit;
"@

	$sql| out-file -encoding ascii sql.sql
	$output=(sqlplus -s $env:schema`/$env:passwd`@$env:tns `@sql.sql);$output

}

function list-dump
{ 	
	$sql = "SELECT filename FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));"
	sqlexec $sql
	
}

function remove-dump
{
	param($df)
	if ($df)
	{
		$remove="exec utl_file.fremove('DATA_PUMP_DIR','$df');"
		sqlexec $remove
	} else {
		'No file specified'
	}
}


#$schema="inlandrail_uat"
#$tgt_schema=$schema.toupper()


function set-targetschema
{
	param($schema)
	$env:tgt_schema=$schema.toupper()
	$host.ui.RawUI.WindowTitle = 'SRC;TGT;DMP: {0} ; {1} ; {2}' -f $env:src_schema, $env:tgt_schema, $env:dmp
}

function set-sourceschema
{
	param($schema)
	$env:src_schema=$schema.toupper()
	$host.ui.RawUI.WindowTitle = 'SRC;TGT;DMP: {0} ; {1} ; {2}' -f $env:src_schema, $env:tgt_schema, $env:dmp
}

function set-userdumpfile
{
	param($schema)
	if ($env:tgt_schema)
	{
		$tgt_schema=$env:tgt_schema
	}
	if ($schema)
	{
		$tgt_schema=$schema
	}
	if ($tgt_schema)
	{
		$env:user_dmp_prefix=('{0}-users-{1}' -f $tgt_schema,(Get-Date -UFormat "%Y%m%d")).tolower()
		$env:user_dmp='{0}.dmp' -f $env:user_dmp_prefix
		$env:user_dmp_exp_log='{0}-exp.log' -f $env:user_dmp_prefix
		$env:user_dmp_imp_log='{0}-imp.log' -f $env:user_dmp_prefix

	}
}

function exp-userdmp
{
	if ( ($env:user_dmp) -and  ( -not ($env:user_dmp_exp_log) ) )
	{
		$env:user_dmp_exp_log = '{0}-exp.log' -f ( ($env:user_dmp -split '\.')[0] )
		#{0}.usersa,{0}.users,{0}.USERSMENU,{0}.USERSGRP,{0}.contact,{0}.contacta,{0}.USERSR,{0}.SAMLATRIBMAP
		$expcmd=@"
expdp $env:schema`/$env:passwd`@$env:tns DIRECTORY=DATA_PUMP_DIR tables={0}.USERS,{0}.FMUSER,{0}.USERVAR,{0}.USERAPP,{0}.USERSMENU,{0}.USERS_MODULE,{0}.USERSDEP,{0}.GRIDUSER,{0}.PRUSER,{0}.USERSA,{0}.USERSGRP,{0}.CONTACT,{0}.USERS2CONTACTA,{0}.CONTACTA,{0}.USERSR,{0}.SAMLATRIBMAP EXCLUDE=STATISTICS DUMPFILE={1} logfile={2}
"@ -f $env:tgt_schema,$env:user_dmp,$env:user_dmp_exp_log

		$env:cmd = $expcmd

		iex $expcmd
	}
}

function imp-userdmp
{
	param($dmp)
	if ($dmp)
	{
		$df = $dmp
	}
	else
	{
		$df = $env:user_dmp
	}
	$log = '{0}-imp.log' -f  ( $df.Substring(0,$df.indexof('.')) )
	write-host ('log file name: {0} ' -f $log )

$impcmd=@"
impdp $env:schema`/$env:passwd`@$env:tns DIRECTORY=DATA_PUMP_DIR DUMPFILE={0} logfile={1} TABLE_EXISTS_ACTION=replace  
"@ -f $df,$log

$env:cmd = $impcmd

iex $impcmd
}

function create-schema
{
	param($schema, $db ,$run)
	if ($schema)
	{
		$i=(get-sqlenv -c1 $db -c2 $schema|select -first 1)
$env:sql=@'	
CREATE USER "{0}"  PROFILE "DEFAULT" 
    IDENTIFIED BY "{1}" DEFAULT TABLESPACE {0}
    TEMPORARY TABLESPACE "TEMP" 
    ACCOUNT UNLOCK;


grant CREATE SESSION to {0};
grant RESOURCE  to {0};
grant CREATE TYPE to {0};
grant CREATE INDEXTYPE to {0};
grant CREATE MATERIALIZED VIEW to {0};
grant CREATE OPERATOR to {0};
grant CREATE PROCEDURE to {0};
grant CREATE SEQUENCE to {0};
grant CREATE SESSION to {0};
grant CREATE TABLE to {0};
grant CREATE TRIGGER to {0};
grant CREATE TYPE to {0};
grant CREATE VIEW to {0};
GRANT EXECUTE ON SYS.DBMS_CRYPTO to {0};
GRANT SELECT ON V$SESSION to {0};
grant unlimited tablespace to {0};
'@ -f ($i.schema).toUpper(), $i.passwd

	} else {
		write-host 'No schema specified'
	}
	if ($run)
	{
		($env:sql | sqlplus -s $env:schema`/$env:passwd`@$env:tns )
	} else {
		$env:sql
	}
}
function set-dumpfile
{
	param($schema)

	if ($schema)
	{
		$env:src_schema=$schema.toUpper()
		$env:dmpn='{0}_{1}' -f $env:src_schema,(Get-Date -UFormat "%Y%m%d")
		$env:dmp=('{0}.dmp' -f $env:dmpn).tolower()
		$env:dmpimplog='{0}-imp.log' -f $env:dmpn
		$env:dmpexplog='{0}-exp.log' -f $env:dmpn
		write-host ('Schema: {0} , dmp file: {1} , log file: {2}'  -f $env:src_schema, $env:dmp, $env:dmpexplog)
		$host.ui.RawUI.WindowTitle = 'SRC;TGT;DMP: {0} ; {1} ; {2}' -f $env:src_schema, $env:tgt_schema, $env:dmp
	} else {
		write-host 'No schema specified'
	}
}

function export-dump
{
	param($schema,$consistent,$parallel)

	if ($schema)
	{
		$flashback_opt = ''
		$parallel_file = ''
		$env:src_schema=$schema.toUpper()
		$env:dmpn='{0}_{1}' -f $env:src_schema,(Get-Date -UFormat "%Y%m%d")
		if ($parallel) {$parallel_file = '-%U' ; $parallel_opt = ('parallel={0}' -f $parallel ) }
		if (-not ($env:dmp) ) {
			$env:dmp=('{0}{1}.dmp' -f ($env:dmpn).tolower() , $parallel_file )
		} else {
			$env:dmpn=($env:dmp -split '\.')[0]
		}
		$env:dmpimplog='{0}-imp.log' -f ($env:dmpn -replace '(-|_)%U','')
		$env:dmpexplog='{0}-exp.log' -f ($env:dmpn -replace '(-|_)%U','')
		if ($consistent) {$flashback_opt = 'flashback_time=systimestamp'}
		$exp_cmd = "expdp $env:schema`/$env:passwd`@$env:tns schemas=${env:src_schema} dumpfile=${env:dmp} logfile=${env:dmpexplog} directory=DATA_PUMP_DIR {0} {1}" -f $flashback_opt,$parallel_opt
		$env:cmd = $exp_cmd
		write-host ('Schema: {0} , dmp file: {1} , log file: {2}'  -f $env:src_schema, $env:dmp, $env:dmpexplog)
		write-host -foreground green (('{0}' -f $exp_cmd) )
		#if ($consistent){
		#	expdp $env:schema`/$env:passwd`@$env:tns schemas=${env:src_schema} flashback_time=systimestamp dumpfile=${env:dmp} logfile=${env:dmpexplog} directory=DATA_PUMP_DIR
		#} else {
		#	expdp $env:schema`/$env:passwd`@$env:tns schemas=${env:src_schema} dumpfile=${env:dmp} logfile=${env:dmpexplog} directory=DATA_PUMP_DIR
		#}
		
	}
}

function import-dump
{
	param($dump,$nomap,$parallel)
	if ($env:dmp)
	{
		$df = $env:dmp
		write-host ('Env:dmp is {0}' -f $env:dmp)
	}
	if ($dump)
	{
		$df = $dump
		write-host ('using specified dmp file {0}' -f $dump)
	}
	$log = '{0}-{1}-imp.log' -f  ( $df.Substring(0,$df.indexof('.')) ), (Get-Date -Format 'yyyyMMddHHmm')
	$log = $log -replace '-%U',''
	$log = $log -replace '_%U',''
	write-host ('log file name: {0} ' -f $log )
	$base_cmd = "impdp $env:schema`/$env:passwd`@$env:tns DIRECTORY=DATA_PUMP_DIR dumpfile=$df logfile=$log"
	if  ( ($nomap) -and ( -not ($parallel)) )
	{
		#impdp $env:schema`/$env:passwd`@$env:tns DIRECTORY=DATA_PUMP_DIR dumpfile=$df logfile=$log 
		$imp_cmd = $base_cmd
	}else{
		$imp_cmd = $base_cmd + " " + "remap_schema=${env:src_schema}:${env:tgt_schema} remap_tablespace=${env:src_schema}:${env:tgt_schema}"
	}
	if ( ($df.contains('%U')) -and ($parallel) )
	{
		$imp_cmd = $imp_cmd + ' ' + ('parallel={0}' -f $parallel)
	}
	$env:cmd = $imp_cmd
}
