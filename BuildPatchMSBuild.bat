@echo off

REM cause Environment variable changes to be lost after this process dies:
setlocal

call SetBuildVars.bat

REM Run the next target only if the previous target succeeded
(
	MSBuild Sample.targets /t:DownloadBuildTasks
) && (
	MSBuild Sample.targets /t:BuildPatch
)