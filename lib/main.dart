import 'package:chat_demo/import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPUtil.init();

  final auth = AuthProvider();
  final chat = ChatProvider();
  final contact = ContactProvider();
  AppProviders.bind(auth: auth, chat: chat, contact: contact);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: chat),
        ChangeNotifierProvider.value(value: contact),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      child: MaterialApp(
        locale: Locale('zh', 'CN'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [Locale('zh', 'CN'), Locale('en', 'US')],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromRGBO(244, 244, 244, 1),
          sliderTheme: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white38,
            thumbColor: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color.fromRGBO(230, 230, 230, 1),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: FontStyleUtils.blackTitle,
            shape: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.green,
            selectionColor: Colors.green.withValues(alpha: 0.2),
            selectionHandleColor: Colors.green,
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
