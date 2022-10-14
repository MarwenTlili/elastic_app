import 'package:flutter/material.dart';

void main() {
  runApp(const LoginForm());
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State {
  final _formKey = GlobalKey<FormState>();
  bool _shoPw = true;
  Icon _pwIcon = const Icon(Icons.remove_red_eye);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login Form'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("login: "),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrer votre login!';
                      }
                      return null;
                    },
                  ),
                  
                  const Text("Mot de passe: "),
                  TextFormField(
                    obscureText: _shoPw,
                    validator: ( String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrer un mot de passe!';
                      }
                      return null;
                    },
                  ),
                  IconButton(
                    onPressed: (){
                      setState(() {
                        _shoPw = !_shoPw;
                        if (_shoPw) {
                          _pwIcon = const Icon(Icons.remove_red_eye);
                        }else{
                          _pwIcon = const Icon(Icons.remove_red_eye_outlined);
                        }
                      });
                    }, 
                    icon: _pwIcon
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      }
                    },
                    child: const Text("Submit")
                  )
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}