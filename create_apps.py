import os

# Apps ki list (naam ke beech me space chalega, underscore nahi)
apps = [
    {
        "name": "Arrow Puzzle",
        "title": "Arrow Puzzle"
    },
    {
        "name": "Ludo Game",
        "title": "Ludo Game"
    }
]

def generate_apps():
    for app in apps:
        app_name = app["name"]
        app_title = app["title"]
        
        print(f"Creating files for: {app_name}")
        
        # 1. Lib folder aur main.dart banayein
        lib_path = os.path.join(app_name, "lib")
        os.makedirs(lib_path, exist_ok=True)
        
        main_code = f"""import 'package:flutter/material.dart';

void main() {{
  runApp(const MyApp());
}}

class MyApp extends StatelessWidget {{
  const MyApp({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return MaterialApp(
      title: '{app_title}',
      home: const HomeScreen(),
    );
  }}
}}

class HomeScreen extends StatelessWidget {{
  const HomeScreen({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{app_title}')),
      body: const Center(
        child: Text(
          'Welcome to {app_title}!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }}
}}
"""
        with open(os.path.join(lib_path, "main.dart"), "w") as f:
            f.write(main_code)
            
        # 2. pubspec.yaml file banayein
        pubspec_path = os.path.join(app_name, "pubspec.yaml")
        if not os.path.exists(pubspec_path):
            package_name = app_name.lower().replace(" ", "_")
            pubspec_code = f"""name: {package_name}
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

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
    print("Sabhi apps ki files bina underscore ke tayar ho chuki hain!")

