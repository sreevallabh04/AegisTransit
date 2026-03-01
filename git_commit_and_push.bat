@echo off
cd /d "%~dp0"
echo Staged files are already added. Committing...
git commit -m "Add RAG Supabase admin premium UI and notifications"
if errorlevel 1 (
  echo.
  echo If you see "Permission denied": close Cursor/VS Code, then run this again.
  echo Or move the project out of OneDrive and run git there.
  pause
  exit /b 1
)
echo Pushing to GitHub...
git push origin main
echo Done.
pause
