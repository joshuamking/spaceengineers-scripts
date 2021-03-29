@ECHO off
REM This script used as the external tool in Visual Studio to export ingame 
REM scripts for Space Engineers game.
REM ARGUMENTS:
REM     %1 - Project name, or $(TargetName) in Visual Studio
SET SOURCES_ROOT=E:\reksar\creation\SpaceEngineers\scripts
SET DESTINATION_ROOT=C:\Users\reksar\AppData\Roaming\SpaceEngineers\IngameScripts\local
SET SED=E:\reksar\soft\portable\git\usr\bin\sed.exe
SET STRART_LINE_PATTERN="/^\s*\/\/ INGAME SCRIPT START/="
SET END_LINE_PATTERN="/^\s*\/\/ INGAME SCRIPT END/="
SET FILENAME=Script.cs


REM Sanitizes the quoted argument.
SET project_name=%~1

IF [%project_name%] == [] (
    ECHO C# project name is not specified.
    EXIT /B 1
)
SET source_file=%SOURCES_ROOT%\%project_name%\%FILENAME%
IF NOT EXIST %source_file% (
    ECHO Source file is not found: %source_file%
    EXIT /B 2
)
IF NOT EXIST %DESTINATION_ROOT% (
    ECHO Space Engineers destination folder is not found: %DESTINATION_ROOT%
    EXIT /B 3
)
SET destination_dir=%DESTINATION_ROOT%\%project_name%
IF NOT EXIST %destination_dir% MKDIR %destination_dir%

REM Find first and last line of ingame script in the source file, and
REM save the numbers of these lines.
SET tmp_file=%destination_dir%\tmp
%SED% -n %STRART_LINE_PATTERN% %source_file% > %tmp_file%
SET /P start_line_num= < %tmp_file%
%SED% -n %END_LINE_PATTERN% %source_file% > %tmp_file%
SET /P end_line_num= < %tmp_file%

REM Copy ingame part of the source file into Space Engineers game dir.
%SED% -n "%start_line_num%,%end_line_num%p" %source_file% > %tmp_file%

REM Remove first code indent (tabulation or 4 spaces) at start of each line.
REM Save script into original file.
SET TAB_STOP=4
SET script=%destination_dir%\%FILENAME%
%SED% "s/^\(\s\{%TAB_STOP%\}\|\t\)//" %tmp_file% > %script%
DEL %tmp_file%

ECHO "%project_name%" script has been exported.
EXIT /B 0
