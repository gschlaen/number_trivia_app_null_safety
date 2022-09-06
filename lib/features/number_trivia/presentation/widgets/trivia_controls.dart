import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  late String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            dipatchConcrete();
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
              child: const Text('Search'),
              onPressed: dipatchConcrete,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey.shade500),
              child: const Text('Get random trivia'),
              onPressed: dipatchRandom,
            )),
          ],
        ),
      ],
    );
  }

  void dipatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForConcreteNumber(inputStr));
  }

  void dipatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
