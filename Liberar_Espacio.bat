@echo off
color a

echo: ############    ##   ##   ########    #######      ############    ##     ##
echo:      ##         ##  ##    ##          ##    ##          ##         ##     ##
echo:      ##         ## ##     ##          #######           ##         ##     ##
echo:      ##         ###       ####        ##  ##            ##         #########
echo:      ##         ###       ##          ##   ##           ##         ##     ##
echo:      ##         ## ##     ##          ##    ##          ##         ##     ##
echo: ############    ##  ##    ########    ##     ##         ##         ##     ##
timeout /t 4 >nul
echo: 
echo: 
echo: 
echo: 
echo:
echo:
echo:
echo:
echo: ////////////////////////////////////AVISO/////////////////////////////////////////////
echo: //////////MUY IMPORTANTE EJECUTAR COMO ADMINISTRADOR//////////////////////////////////
echo: //////////UNA VEZ INICIADO NO INTERRUMPIR PARA PREVENIR ERRORES DE SO/////////////////
echo: //////////EJECUTAR CUANDO NO SE ESTE REALIZANDO NINGUN USO DE WINDOWS UPDATE//////////
echo: //////////CERRAR TODOS LOS SERVICIOS POSIBLES EN PRIMER Y SEGUNDO PLANO///////////////
echo: //////////TODO LO UBICADO EN LA PAPELERA SE ELIMINARA/////////////////////////////////
echo: //////////SEGUIDAMENTE SE MOSTRARA TODO LO QUE SE PROCEDE A ELIMINAR//////////////////
echo: //////////////////////////////////////////////////////////////////////////////////////
echo:
echo:
echo: Espacio libre expresado en MB en C:\ antes de la limpieza:
powershell -command "& {(Get-PSDrive C).Free / 1MB -as [int]} MB"
echo: SI PRESIONA CUALQUIER TECLA SE PROSEGUIRA CON LA ELIMINACION DE ARCHIVOS
pause
echo:OBJETOS A ELIMINAR:
echo:	-Archivos Temporales de Windows
echo:	-Actualizaciones Antiguas de Windows
echo:	-Registros de Errores en el SO
echo:	-Borrado de Temporales en el Usuario Ejecutado
timeout /t 5 >nul

echo: ELIMINANDO EN 5
timeout /t 1 >nul
echo: ELIMINANDO EN 4
timeout /t 1 >nul
echo: ELIMINANDO EN 3
timeout /t 1 >nul
echo: ELIMINANDO EN 2
timeout /t 1 >nul
echo: ELIMINANDO EN 1
timeout /t 1 >nul

:: for /f hace que capture la salida del comando que se va a ejecutar
:: "delims=" %%i in ('whoami')le dice que guarde todo lo que devuelva en la variable %%i del comando whoami
:: do le dices que quieres hacer, aquí es guardar la variable %%i (Usuario Obtenido) en usuario_resultante

for /f "delims=" %%i in ('whoami') do set "usuario_resultante=%%i"

:: Si al hacer whoami devuelte DOMINIO\itesta hay que separar el DOMINIO\
:: "tokens=2 delims=\" delims=\ se encarga de separar lo de antes del \ y después, tokens=2 dice que coja la parte después del \

for /f "tokens=2 delims=\" %%a in ("%usuario_resultante%") do set "usuario_sindominio=%%a"

:: Del borra, /s para que borre carpetas y subcarpetas, /q quiet mode, no pide confirmación
:: Significa que para los directorios (carpetas) de la ruta haga rd (Remove Directory)
:: Borra temporales, Archivos antiguos de actualizaciones de Windows, En Minidump hay ficheros informativos de errores ocurridos

del /s /q C:\Windows\Temp\*.*
for /d %%x in (C:\Windows\Temp\*) do rd /s /q "%%x"

del /s /q C:\Windows\SoftwareDistribution\Download\*.*
for /d %%x in (C:\Windows\SoftwareDistribution\Download\*) do rd /s /q "%%x"

del /s /q C:\Windows\Minidump\*.*

del /s /q C:\Users\%usuario_sindominio%\AppData\Local\Temp\*.*
for /d %%x in (C:\Users\%usuario_sindominio%\AppData\Local\Temp\*) do rd /s /q "%%x"

::Borrar archivos de actualizaciones antiguas
dism.exe /online /cleanup-image /startcomponentcleanup /quiet

:: Borra la cache de paquetes temporales
del /s /q C:\Windows\Downloaded Program Files\*.*
for /d %%x in (C:\Windows\Downloaded Program Files\*) do rd /s /q "%%x"

:: Borra la papelera de Reciclaje
PowerShell -Command "& {(New-Object -ComObject Shell.Application).NameSpace(10).Items() | ForEach-Object {Remove-Item $_.Path -Recurse -Force}}"

echo:
echo: TODOS LOS ARCHIVOS SE HAN ELIMINADO EXITOSAMENTE
echo Espacio libre expresado en MB en C:\ despues de la limpieza:
powershell -command "& {(Get-PSDrive C).Free / 1MB -as [int]} MB"
pause