import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para guardar

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  
  final List<String> _emojis = [
    '🦁', '🦁', '🦊', '🦊', '🐼', '🐼', '🐨', '🐨', '🐯', '🐯',
    '🐸', '🐸', '🐙', '🐙', '🦄', '🦄', '🐷', '🐷', '🐵', '🐵',
    '🦉', '🦉', '🐧', '🐧', '🐥', '🐥', '🐝', '🐝', '🦋', '🦋',
    '🐞', '🐞', '🐠', '🐠', '🦖', '🦖' 
  ];
  
  List<String> _gameCards = [];
  List<bool> _cardFlipped = [];
  List<int> _selectedIndices = [];
  int _attempts = 0;
  int _bestScore = 0; 

  @override
  void initState() {
    super.initState();
    _loadBestScore(); // Cargar récord al iniciar
    _resetGame();
  }

  // Cargar el récord guardado en el celular
  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestScore = prefs.getInt('best_score') ?? 0;
    });
  }

  // Guardar nuevo récord si es necesario
  Future<void> _updateBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    // Si es el primer juego (0) o si superó el récord (menos intentos es mejor)
    if (_bestScore == 0 || score < _bestScore) {
      await prefs.setInt('best_score', score);
      setState(() {
        _bestScore = score;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _attempts = 0;
      _gameCards = List.from(_emojis);
      _gameCards.shuffle();
      _cardFlipped = List.generate(_gameCards.length, (index) => false);
      _selectedIndices = [];
    });
  }

  void _onCardTap(int index) {
    if (_cardFlipped[index] || _selectedIndices.length >= 2) return;

    setState(() {
      _cardFlipped[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    setState(() {
      _attempts++;
    });

    int index1 = _selectedIndices[0];
    int index2 = _selectedIndices[1];

    if (_gameCards[index1] == _gameCards[index2]) {
      _selectedIndices.clear();
      
      // Verificar victoria
      if (_cardFlipped.every((bool status) => status == true)) {
        _updateBestScore(_attempts); // Guardar récord al ganar
        _showWinDialog();
      }
    } else {
      Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          _cardFlipped[index1] = false;
          _cardFlipped[index2] = false;
          _selectedIndices.clear();
        });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Ganaste! 🎉'),
        content: Text('Intentos: $_attempts\nMejor Récord: $_bestScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Jugar otra vez'),
          ),
        ],
      ),
    );
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
              // Panel de info actualizado
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Intentos: $_attempts', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Récord: ${_bestScore == 0 ? '--' : _bestScore}', 
                       style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // ¡IMPORTANTE! 6 Columnas para cumplir requisito
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _gameCards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onCardTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cardFlipped[index] ? Colors.white : Colors.deepPurple,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      _cardFlipped[index] ? _gameCards[index] : '❓',
                      style: const TextStyle(fontSize: 24), // Emoji un poco más pequeño para que quepa
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