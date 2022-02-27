import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(), // 主页
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = StreamController.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text('你按的是 ${snapshot.data} 我是不是猜对了');
              }
              return const Text('...');
          },
        )
      ),
      body: Stack(
        children: [
          ...List.generate(5, (index) => Puzzle(_controller.stream)),
          Align(
            alignment: Alignment.bottomCenter,
            child: KeyPad(_controller),
          ),
        ],
      ),
    );
  }
}

// 键盘
class KeyPad extends StatelessWidget {
  const KeyPad(this._controller, {Key? key}) : super(key: key);

  final StreamController  _controller;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2 / 1,
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.primaries[index][200],
            shape: const RoundedRectangleBorder(),
          ),
          child: Text('${index + 1}',
              style: const TextStyle(
                fontSize: 30,
                color: Colors.black,
              )),
          onPressed: () {
            _controller.add(index + 1);
          },
        );
      }),
    );
  }
}

// 出题
class Puzzle extends StatefulWidget {
  final Stream<dynamic> inputStream;

  const Puzzle(this.inputStream, {Key? key}) : super(key: key);

  @override
  _PuzzleState createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> with SingleTickerProviderStateMixin {
  late int a, b;
  late Color? color;
  late AnimationController _controller;
  late double x;

  void reset() {
    a = Random().nextInt(5) + 1;
    b = Random().nextInt(5);
    x = Random().nextDouble() * 300;
    _controller.duration = Duration(milliseconds: Random().nextInt(5000) + 5000);
    color = Colors.primaries[Random().nextInt(Colors.primaries.length)][200];
  }

  @override
  void initState() {

    _controller = AnimationController(
      vsync: this,
    );

    reset();
    _controller.forward(from: Random().nextDouble());
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        reset();
        _controller.forward(from: 0.0);
      }
    });

    widget.inputStream.listen((dynamic input) {
      if(input == a + b) {
        reset();
        _controller.forward(from: 0.0);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * _controller.value - 100,
          left: x,
          child: Container(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
            child: Text('$a + $b', style: const TextStyle(fontSize: 40)),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        );
      },
    );
  }
}
