# App-Icon zu senat.png ändern - Manuelle Anleitung

## ✅ Konfiguration ist fertig!

Die `pubspec.yaml` wurde bereits konfiguriert. Führen Sie jetzt folgende Schritte aus:

## 🚀 Schritt 1: Icons generieren

Öffnen Sie ein **neues Terminal** (PowerShell oder CMD) und führen Sie aus:

```bash
cd "C:\Users\rayan\Documents\programmierenn\flutter\rechnung-sys2000"
dart run flutter_launcher_icons
```

**WICHTIG:** Warten Sie, bis der Befehl vollständig durchgelaufen ist. Es kann einige Sekunden dauern.

## 🔍 Schritt 2: Prüfen ob Icons generiert wurden

Nach dem Befehl sollten Sie eine Ausgabe sehen wie:
```
✓ Successfully generated launcher icons
```

## 🧹 Schritt 3: App neu bauen

```bash
flutter clean
flutter pub get
flutter build apk
```

oder für Debug:

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Schritt 4: App neu installieren

**WICHTIG:** Sie müssen die App **komplett deinstallieren** und dann **neu installieren**, damit das neue Icon angezeigt wird!

1. App vom Gerät deinstallieren
2. Neue APK installieren oder `flutter run` ausführen

## ⚠️ Falls das Package nicht funktioniert

Falls `dart run flutter_launcher_icons` nicht funktioniert, können Sie die Icons manuell ersetzen:

1. Öffnen Sie `assets/senat.png` in einem Bildbearbeitungsprogramm
2. Erstellen Sie folgende Größen:
   - **hdpi**: 72x72 px
   - **mdpi**: 48x48 px
   - **xhdpi**: 96x96 px
   - **xxhdpi**: 144x144 px
   - **xxxhdpi**: 192x192 px
3. Kopieren Sie die entsprechenden Größen in:
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

## 🎯 Für iOS

Die iOS-Icons werden automatisch generiert, wenn das Package funktioniert. Sie befinden sich in:
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`


