---
title: QGAO Backup Script
author: danijel
date: 2023-02-17 11:00:00 +1000
categories: [Process]
tags: []
mermaid: true
comments: false
image:
  path: /assets/img/post-headers/refresh.jpg
  width: 845
  height: 321
  alt: Refresh-Image
---

userImages shortcut must be re-created:
E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_trn\generic\images\userImages
\\syda-n-fs\IWMS\clients\qgao_trn\Filestore\Documents


Backup files to S3 from QGAO Prod.

```powershell
$todayDate = (Get-Date).ToString("yyyyMMdd")
$cEnv = "qgao_prod"
$ePath = "C:\temp\${todayDate}\${cenv}"
$s3Bucket = "QGAO"


#region stuff
# 7-Zip
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}
Set-Alias 7za $7zipPath


#aws cli env
$Env:AWS_ACCESS_KEY_ID="ASIATM6E2P4KREYTXKNE"
$Env:AWS_SECRET_ACCESS_KEY="VSMHsy1DgI7N1UZy1R6v8vVXUCMaoSFsShZD1WNE"
$Env:AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjELn//////////wEaCXVzLWVhc3QtMSJIMEYCIQDqE2EO4ZPNTxr1jCwZFCutEzegmp8rC+Z+RjLy9LF5fQIhAOg/ypReMv5IeoNbUsy2mYWi0RcyReAJIa6u54d0UeotKp0DCFIQABoMMjMzOTUxNjI0OTgxIgzzgTbIRvGcj2LA0Iwq+gJ6pC3RS4XTgnFM4p3VZZwQi9eHVfUfQLiZCDIcpyguevpPbEp4KVRV9f7Ln4s3NLUZk2nZ/B1zoRG22pYyt6EgoK01z7BrONpmU+quxG9jqtD2Gv2Wjfu+385ofXBJytPbLq2h84Fz/a5lCCPEEY4rZktUqZ35W+UqppUprqeLk134t5DYYgnD4J3ujPSnAwUV1zB3wrpZivPP1MH0PXPQmoqVxSblFY7wNMRaHGEb/KqRsx1RIKcm9RTFMuIYo+FXrZBLy44vq3VPyImIwWYO9AGfMj0FAMa5wa+8Qd2cDb1ujLKauzMjgm11sDLzPae/yjnBQGLmZY3GcJCaBcL4oMmSSseBsVk+UAD+YafrScLn4gzGlI7CiYPvgct1Tg/a7k2QGURKMm/Y1jcHWjmapceISFrGNYJ9YkwF3DdwhrztiQAHYFwt8vZgLy/RjIX2uG6c6K2VWfc3eIQpgxMXTekw/Z+w2UwABJ6wiXYdRrUng3pGAdhMwAgwgJ27nwY6pQEEf0eGzhLfwJ1ynXNB2qoV0DJ8K5JNZI4M00QgqUaJgGFNlK9Ln8t1ZoLGgJia/YLChqM64SnK8Ms9J/ld0jRjoU+vGAtNWHIzJf7f5/aInVfcRB0EAL1PtOMFyrgZpzEU9UJoyzNDsjT19ayOf3jX0GV5c8dMcL8camocw6tvPtuiWySBZMMoY70RV238scSQkeTNF9G/9f8GCGp62JHC2CvkDmA="
#endregion stuff


# make folders
if (-not(Test-Path -Path $ePath))
{
  mkdir -p $ePath
}


# manii
$item = "manii"
$pItem = "E:\manhattan\forms\manii_qgao_prod"
7za a -t7z "${ePath}\${cEnv}_${todayDate}_${item}.7z" "${pItem}"
aws s3 cp "${ePath}\${cEnv}_${todayDate}_${item}.7z" "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z"
if ((aws s3 ls "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z").Count -eq 1)
{
  Remove-Item -Path "${ePath}\${cEnv}_${todayDate}_${item}.7z" -Confirm:$false -Force
}


# webapps
$item = "webapps"
$pItem = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod"
7za a -t7z "${ePath}\${cEnv}_${todayDate}_${item}.7z" "${pItem}"
aws s3 cp "${ePath}\${cEnv}_${todayDate}_${item}.7z" "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z"
if ((aws s3 ls "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z").Count -eq 1)
{
  Remove-Item -Path "${ePath}\${cEnv}_${todayDate}_${item}.7z" -Confirm:$false -Force
}


# mailmerge
$item = "mailmerge"
$pItem = "\\syda-p-fsx\share\IWMS\clients\qgao_prod\Filestore\Documents\Mailmerge"
7za a -t7z "${ePath}\${cEnv}_${todayDate}_${item}.7z" "${pItem}"
aws s3 cp "${ePath}\${cEnv}_${todayDate}_${item}.7z" "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z"
if ((aws s3 ls "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z").Count -eq 1)
{
  Remove-Item -Path "${ePath}\${cEnv}_${todayDate}_${item}.7z" -Confirm:$false -Force
}


# usergrids
$item = "usergrids"
$pItem = "E:\manhattan\forms\manii_${cEnv}\usergrids"
7za a -t7z "${ePath}\${cEnv}_${todayDate}_${item}.7z" "${pItem}"
aws s3 cp "${ePath}\${cEnv}_${todayDate}_${item}.7z" "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z"
if ((aws s3 ls "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z").Count -eq 1)
{
  Remove-Item -Path "${ePath}\${cEnv}_${todayDate}_${item}.7z" -Confirm:$false -Force
}


#files
$manhattan_htm = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\manhattan.htm"
$sso_logout = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\sso_logout.htm"
$web_xml = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\WEB-INF\web.xml"
$pathconstants_js = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\generic\jscript\constants\pathConstants.js"
$api_json = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\API\api.json"
$app_config = "E:\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\cafm\appConfig.json"

$manhattan_htm_tmp = "${ePath}\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod"
$sso_logout_tmp = "${ePath}\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod"
$web_xml_tmp = "${ePath}\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\WEB-INF"
$pathconstants_js_tmp = "${ePath}\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\generic\jscript\constants"
$api_json_tmp = "${ePath}\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\API"
$app_config_tmp = "${ePath}\manhattan\tomcat\Tomcat_IWMS\webapps\qgao_prod\cafm"

$manhattan_htm_tmp,$sso_logout_tmp,$web_xml_tmp,$pathconstants_js_tmp,$api_json_tmp,$app_config_tmp | ForEach-Object {
  if (-not(Test-Path -Path $_)) { mkdir -p $_ }
}

$manhattan_htm,$sso_logout,$web_xml,$pathconstants_js,$api_json,$app_config | ForEach-Object {
  $i = $_
  $d = $i.ToString().Replace('E:',$ePath)
  if (Test-Path -Path $i)
  {
    Copy-Item -Path $i -Destination $d -Confirm:$false -Force
  }
}
$item = "files"
$pItem = "${ePath}\manhattan"
7za a -t7z "${ePath}\${cEnv}_${todayDate}_${item}.7z" "${pItem}"
aws s3 cp "${ePath}\${cEnv}_${todayDate}_${item}.7z" "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z"
if ((aws s3 ls "s3://rews-syda-dbdump1/${s3Bucket}/${cEnv}_${todayDate}_${item}.7z").Count -eq 1)
{
  Remove-Item -Path "${ePath}\${cEnv}_${todayDate}_${item}.7z" -Confirm:$false -Force
}
```