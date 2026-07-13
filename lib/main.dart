import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main entry point of the Debt Management application.
///
/// Wraps the app with [ProviderScope] to enable Riverpod state management.
/// All providers throughout the app are accessible through this scope.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Root widget of the application.
///
/// Configures the app-wide settings:
/// - App title
/// - Material 3 theme with teal color scheme
/// - Initial home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debt Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Debt Management'),
    );
  }
}

/// Temporary home screen placeholder.
///
/// This will be replaced with the actual dashboard UI in future iterations.
/// Currently serves as a confirmation that the app builds and runs correctly.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Database layer ready. UI coming soon.'),
      ),
    );
  }
}
