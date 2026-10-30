@echo off
title Face Attendance & Payroll - Launcher
color 0A

echo =====================================================================
echo           STARTING FACE ATTENDANCE & PAYROLL SYSTEM
echo =====================================================================
echo.

:: Check if backend virtual environment exists
if not exist "backend\.venv" (
    color 0C
    echo [ERROR] Setup has not been run yet!
    echo Please double-click 'setup_windows.bat' first to install everything.
    echo.
    pause
    exit /b 1
)

echo Starting Backend API Server (Port 8000)...
start "Attendance Backend (FastAPI)" cmd /k "cd backend && call .venv\Scripts\activate.bat && uvicorn app.main:app --host 127.0.0.1 --port 8000"

echo Waiting 3 seconds for backend to start...
timeout /t 3 /nobreak >nul

echo Starting Frontend Web App (Port 5173)...
start "Attendance Frontend (React + Vite)" cmd /k "cd frontend && npm run dev"

echo Waiting 2 seconds for frontend to start...
timeout /t 2 /nobreak >nul

echo Opening App in your web browser...
start http://localhost:5173

echo.
echo =====================================================================
echo                SYSTEM IS NOW RUNNING!
echo =====================================================================
echo.
echo 1. Frontend Web App: http://localhost:5173
echo 2. Backend API Docs: http://localhost:8000/docs
echo.
echo To STOP the application:
echo Simply close the two black command windows ("Attendance Backend" and "Attendance Frontend").
echo.
pause
