import 'package:flutter/material.dart';
import 'dart:async';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Configuración del juego: 6x6 = 36 cartas (18 pares)
  final int rows = 6;
  final int cols = 6;
  
  // Variables de estado
  late List<String> cardContent;     // El contenido (emojis)
  late List<bool> cardFlipped;       // Si la carta está volteada
  late List<bool> cardMatched;       // Si ya se encontró la pareja
  int? firstFlippedIndex;            // Índice de la primera carta volteada
  bool isProcessing = false;         // Para evitar toques rápidos
  int attempts = 0;                  // Contador de intentos

  // Lista de emojis para usar como cartas (18 emojis para 18 pares)
  final List<String> iconsSource = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', 
    '🐻', '🐼', '🐨', '🐯', '🦁', 'dV',
    '🐸', '🐵', '🐔', '🐧', '🐦', '🐤'
  ];

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    // 1. Crear pares y barajar
    List<String> cards = [...iconsSource, ...iconsSource]; // Duplicar
    cards.shuffle(); // Barajar aleatoriamente

    setState(() {
      cardContent = cards;
      // Inicializar todas las cartas como "no volteadas" y "no emparejadas"
      cardFlipped = List.generate(36, (index) => false);
      cardMatched = List.generate(36, (index) => false);
      firstFlippedIndex = null;
      isProcessing = false;
      attempts = 0;
    });
  }

  void onCardTap(int index) {
    // Bloqueos de seguridad:
    // Si ya está procesando, si la carta ya está volteada o si ya está emparejada, no hacer nada.
    if (isProcessing || cardFlipped[index] || cardMatched[index]) return;

    setState(() {
      cardFlipped[index] = true; // Voltear la carta actual
    });

    if (firstFlippedIndex == null) {
      // Es la primera carta del par
      firstFlippedIndex = index;
    } else {
      // Es la segunda carta: comparar
      int firstIndex = firstFlippedIndex!;
      attempts++; // Contar el intento

      if (cardContent[firstIndex] == cardContent[index]) {
        // ¡Coincidencia!
        setState(() {
          cardMatched[firstIndex] = true;
          cardMatched[index] = true;
          firstFlippedIndex = null;
        });
        checkWinCondition();
      } else {
        // No coinciden: Esperar un momento y voltear ambas
        isProcessing = true;
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            cardFlipped[firstIndex] = false;
            cardFlipped[index] = false;
            firstFlippedIndex = null;
            isProcessing = false;
          });
        });
      }
    }
  }

  void checkWinCondition() {
    // Si todas las cartas están emparejadas, ganaste
    if (cardMatched.every((element) => element)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Felicidades! 🎉'),
          content: Text('Ganaste en $attempts intentos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startNewGame();
              },
              child: const Text('Jugar de nuevo'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Intentos: $attempts', style: const TextStyle(fontSize: 20)),
              ElevatedButton.icon(
                onPressed: startNewGame,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: rows, // 6 columnas
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: rows * cols,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onCardTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardFlipped[index] || cardMatched[index] 
                        ? Colors.blue 
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      cardFlipped[index] || cardMatched[index] 
                          ? cardContent[index] 
                          : '',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}