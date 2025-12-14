@echo off
echo ========================================
echo   App-Icon zu senat.png aendern
echo ========================================
echo.
echo Bitte warten, Icons werden generiert...
echo.

dart run flutter_launcher_icons

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   Icons erfolgreich generiert!
    echo ========================================
    echo.
    echo Naechste Schritte:
    echo 1. flutter clean
    echo 2. flutter pub get
    echo 3. flutter build apk (oder flutter run)
    echo 4. App NEU installieren (wichtig!)
    echo.
) else (
    echo.
    echo ========================================
    echo   Fehler beim Generieren der Icons
    echo ========================================
    echo.
)

pause


