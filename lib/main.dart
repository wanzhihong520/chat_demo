import 'package:chat_demo/import.dart';
import 'package:chat_demo/page/startUp_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPUtil.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Color.fromRGBO(230, 230, 230, 1),
            elevation: 0,
            centerTitle: true,
          ),
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: StartupPage(),
      ),
    );
  }
}
