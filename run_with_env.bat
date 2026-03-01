@echo off
REM Run Flutter with keys from .env. Copy .env.example to .env and add your keys.
REM Requires PowerShell. Or run: flutter run --dart-define=GROQ_API_KEY=yourkey --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_with_env.ps1" %*
if errorlevel 1 exit /b 1
