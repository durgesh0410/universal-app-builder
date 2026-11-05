import os
import shutil

apps = [
    {"name": "arrow_puzzle", "title": "Arrow Puzzle", "type": "arrow"},
    {"name": "ludo_game", "title": "Ludo King Clone", "type": "ludo"}
]

def generate_apps():
    for app in apps:
        app_name = app["name"]
        app_title = app["title"]

        if os.path.exists(app_name):
            shutil.rmtree(app_name)

        lib_path = os.path.join(app_name, "lib")
        os.makedirs(lib_path, exist_ok=True)

        manifest_dir = os.path.join(app_name, "android", "app", "src", "main")
        os.makedirs(manifest_dir, exist_ok=True)

        manifest_path = os.path.join(manifest_dir, "AndroidManifest.xml")
        manifest_code = f"""<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.{app_name}">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:label="{app_title}"
        android:name="${{applicationName}}"
        android:icon="@mipmap/ic_launcher">

        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
"""
        with open(manifest_path, "w") as f:
            f.write(manifest_code)

        kotlin_dir = os.path.join(app_name, "android", "app", "src", "main", "kotlin", "com", "example", app_name)
        os.makedirs(kotlin_dir, exist_ok=True)

        main_activity_path = os.path.join(kotlin_dir, "MainActivity.kt")
        main_activity_code = f"""package com.example.{app_name}

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {{
}}
"""
        with open(main_activity_path, "w") as f:
            f.write(main_activity_code)

        pubspec_path = os.path.join(app_name, "pubspec.yaml")
        pubspec_code = f"""name: {app_name}
description: Mobile game with AdMob.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_mobile_ads: ^5.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
"""
        with open(pubspec_path, "w") as f:
            f.write(pubspec_code)

if __name__ == "__main__":
    generate_apps()
    print("Fresh lowercase apps generated successfully!")
