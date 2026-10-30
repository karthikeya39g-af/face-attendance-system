@echo off
title Attendance Backend Server
cd backend
if not exist ".venv" (
    echo Virtual environment not found. Please run setup_windows.bat first.
    pause
    exit /b 1
)
call .venv\Scripts\activate.bat
echo Starting Backend on http://127.0.0.1:8000 ...
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
pause
