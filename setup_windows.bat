@echo off
title Face Attendance & Payroll - Windows Automatic Setup
color 0B

echo =====================================================================
echo      FACE ATTENDANCE & PAYROLL SYSTEM - 1-CLICK WINDOWS SETUP
echo =====================================================================
echo.

:: 1. Check Python
echo [Step 1/5] Checking Python...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [ERROR] Python is NOT installed or NOT added to PATH!
    echo Please install Python 3.10 - 3.13 from https://www.python.org/downloads/
    echo IMPORTANT: Make sure to check the box "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)
python --version
echo [OK] Python is installed!
echo.

:: 2. Check Node.js
echo [Step 2/5] Checking Node.js and npm...
node -v >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color 0C
    echo [ERROR] Node.js is NOT installed!
    echo Please download and install the LTS version from https://nodejs.org/
    echo.
    pause
    exit /b 1
)
node -v
npm -v
echo [OK] Node.js and npm are installed!
echo.

:: 3. Setup Backend
echo [Step 3/5] Setting up Backend Python environment...
cd backend
if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

echo Installing backend Python packages (FastAPI, OpenCV, ONNX Runtime, etc.)...
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt

if not exist ".env" (
    echo Creating backend .env file...
    copy .env.example .env
)
cd ..
echo [OK] Backend setup complete!
echo.

:: 4. Setup Frontend
echo [Step 4/5] Setting up Frontend...
cd frontend
if not exist ".env" (
    echo Creating frontend .env file...
    copy .env.example .env
)
echo Installing frontend dependencies (React, Vite, Tailwind, etc.)...
call npm install
cd ..
echo [OK] Frontend setup complete!
echo.

:: 5. Setup Database
echo [Step 5/5] Database Setup...
echo.
echo Have you installed PostgreSQL and is it running?
echo Default user is 'postgres', port is '5432'.
echo.
set /p DBPASS="Enter your PostgreSQL password for user 'postgres' (or press Enter if blank): "
set PGPASSWORD=%DBPASS%

echo Creating database 'attendance_v3' if it doesn't already exist...
createdb -U postgres -h localhost -p 5432 attendance_v3 >nul 2>&1

echo Restoring complete pre-loaded data (employees, shifts, holidays, attendance, payroll)...
psql -U postgres -h localhost -p 5432 -d attendance_v3 -f backend\seed_data.sql >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Database restored successfully with all realistic records!
) else (
    echo [NOTE] If createdb or psql command was not recognized, please add PostgreSQL bin folder to PATH,
    echo or create 'attendance_v3' in pgAdmin and run backend\seed_data.sql.
)

echo.
echo =====================================================================
echo                SETUP COMPLETED SUCCESSFULLY!
echo =====================================================================
echo You can now run 'start_windows.bat' to launch the entire application!
echo.
pause
