import os
import shutil

apps = [
    {"name": "arrowpuzzle", "title": "Arrow Puzzle", "code": "// Arrow Puzzle Main\nimport 'package:flutter/material.dart';\n\nvoid main() => runApp(const MyApp());\n\nclass MyApp extends StatelessWidget {\n  const MyApp({super.key});\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      home: Scaffold(\n        appBar: AppBar(title: const Text('Arrow Puzzle')),\n        body: const Center(child: Text('Welcome to Arrow Puzzle!')),\n      ),\n    );\n  }\n}"},
    {"name": "ludogame", "title": "Ludo Game", "code": "// Ludo Game Main\nimport 'package:flutter/material.dart';\n\nvoid main() => runApp(const MyApp());\n\nclass MyApp extends StatelessWidget {\n  const MyApp({super.key});\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      home: Scaffold(\n        appBar: AppBar(title: const Text('Ludo Game')),\n        body: const Center(child: Text('Welcome to Ludo Game!')),\n      ),\n    );\n  }\n}"}
]

def generate_apps():
    for app in apps:
        app_name = app["name"]

        if os.path.exists(app_name):
            shutil.rmtree(app_name)

        lib_path = os.path.join(app_name, "lib")
        os.makedirs(lib_path, exist_ok=True)

        with open(os.path.join(lib_path, "main.dart"), "w") as f:
            f.write(app["code"])

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
    print("Apps generated without underscore successfully!")
