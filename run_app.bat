@echo off
setlocal
:: Change this path to the installation path on your machine
set "RSCRIPT=C:\Program Files\R\R-4.5.2\bin\Rscript.exe"
:: Get folder path where this batch script is called from
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
:: Install all required R packages and start the app
"%RSCRIPT%" --vanilla "%ROOT%\R\install_packages.R"
"%RSCRIPT%" --vanilla "%ROOT%\R\app.R" "%ROOT%"
