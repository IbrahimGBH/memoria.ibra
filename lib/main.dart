import 'package:flutter/material.dart';
import 'game_board.dart'; // Importamos el archivo que acabas de crear

void main() {
  runApp(const MemoriaApp());
}

class MemoriaApp extends StatelessWidget {
  const MemoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego de Memoria',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Memoria Ibrahim Barbar')),
        body: const GameBoard(),
      ),
    );
  }
}