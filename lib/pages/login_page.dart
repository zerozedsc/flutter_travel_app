import '../back_end/configs.dart';
import '../back_end/service.dart';
import '../back_end/page_controller.dart';

import 'package:http/http.dart' as http;

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LOCALIZATION.localize('register_account'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: LOCALIZATION.localize('email'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: LOCALIZATION.localize('password'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 新規作成処理をここに追加
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('アカウントが作成されました！')),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // foreground colour
                backgroundColor: secondaryColor,
                shadowColor: Colors.black, // Text color
              ),
              child: const Text('アカウント作成'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ようこそ！',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: LOCALIZATION.localize('email'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: LOCALIZATION.localize('password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // ログイン処理をここに追加
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ログインボタンが押されました')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PageControllerClass(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // foreground colour
                  backgroundColor: secondaryColor,
                  shadowColor: Colors.black, // Text color
                ),
                child: Text(LOCALIZATION.localize('login')),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // 新規作成ページへの遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(),
                    ),
                  );
                },
                child: const Text('新規作成'),
              ),
              TextButton(
                onPressed: () {
                  // パスワードリセット画面への遷移など
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('パスワードをお忘れですか？')),
                  );
                },
                child: const Text('パスワードをお忘れですか？'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
