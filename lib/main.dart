import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_api_1/search-delegate.dart';
import 'package:quran_api_1/services/read_from_json.dart';
import 'package:quran_api_1/services/tafseer_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      routes: {
        '/': (context) => const MyHomePage(
              title: 'Quran',
            )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _items = [];
  int selectedAyah = -1;


  TextEditingController searchController = TextEditingController();
  PageController pageViewController = PageController();
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text(
    'القرآن الكريم',
    style: TextStyle(color: Color(0xff8c5824)),
  );
  bool selectNewAyah = false;

  void readJson() async {
    dynamic data = await JsonHelper().readJson();
    setState(() {
      _items = data;
    });
  }

  @override
  void initState() {
    readJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context)!.settings.arguments;

    Set surahsSet = <dynamic>{};
    List surahs = [];
    print(selectNewAyah);
    if (args != null && selectNewAyah == false) {
      int navigateToPage = 0;
      navigateToPage = args[0];
      selectedAyah = args[1];
      if (pageViewController.hasClients) {
        pageViewController.jumpToPage(navigateToPage - 1);
      }
    }

    if (_items.isNotEmpty) {
      _items.forEach((suraObject) {
        surahsSet.add(suraObject['sura_name_ar']);
      });

      surahsSet.forEach((element) {
        surahs.add(element);
      });
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    gradient: RadialGradient(
                        colors: [Color(0xfffdf7e9), Color(0xfff5dca2)])),
                height: 200,
                child: const Center(
                  child: Text(
                    'القرآن الكريم',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Color(0xff8c5824)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: surahs.length,
                    itemBuilder: (context, index) => ListTile(
                          onTap: () {
                            Navigator.pop(context);

                            int initialPage = 0;

                            initialPage = _items.firstWhere((element) =>
                                element['sura_name_ar'] ==
                                surahs[index])['page'];

                            pageViewController.jumpToPage(initialPage - 1);
                          },
                          title: Text(surahs[index]),
                        )),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          backgroundColor: const Color(0xfffdf7e9),
          title: customSearchBar,
          iconTheme: const IconThemeData(color: Color(0xff8c5824)),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(items: _items),
                );
              },
              icon: customIcon,
            ),
          ],
        ),
        backgroundColor: const Color(0xfffdf7e9),
        body: PageView.builder(
          itemCount: 604,
          controller: pageViewController,
          itemBuilder: (BuildContext context, int index) {
            if (_items.isNotEmpty) {
              List<TextSpan> ayahsByPage = [];
              String surahName = '';
              int jozzNum = 0;
              bool isBasmalahShown = false;

              for (Map ayahData in _items) {
                if (ayahData['page'] == index + 1) {
                  if (ayahData['aya_no'] == 1 &&
                      ayahData['sura_name_ar'] != 'الفَاتِحة' &&
                      ayahData['sura_name_ar'] != 'التوبَة') {
                    isBasmalahShown = true;
                  }
                  ayahsByPage.addAll([
                    if (isBasmalahShown) ...[
                      const TextSpan(
                        text: "\n\n‏ ‏‏ ‏‏‏‏ ‏‏‏‏‏‏\n\n",
                        style: TextStyle(
                            fontFamily: 'Hafs',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 2,
                            backgroundColor: Colors.black12),
                      )
                    ],
                    TextSpan(
                      recognizer: LongPressGestureRecognizer(
                          duration: const Duration(milliseconds: 200))
                        ..onLongPress = () async {
                          setState(() {
                            selectNewAyah = true;
                            selectedAyah = ayahData['id'];
                          });

                          dynamic tafseer = await TafseerService().getTafseer(
                              surahNum: ayahData['sura_no'].toString(),
                              ayahNum: ayahData['aya_no'].toString());

                          showModalBottomSheet<void>(
                            clipBehavior: Clip.hardEdge,
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                                // <-- SEE HERE
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0),
                            )),
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 270,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            child: Text(
                                              ayahData['aya_text'],
                                              textDirection: TextDirection.rtl,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily: 'Hafs',
                                                  fontSize: 18),
                                            ),
                                          ),
                                          tafseer != null
                                              ? Text(
                                                  tafseer['text'],
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      text: '${ayahData['aya_text'].toString()} ',
                      style: TextStyle(
                          backgroundColor: selectedAyah == ayahData['id']
                              ? Colors.black12
                              : null,
                          fontFamily: 'Hafs',
                          fontSize: 19),
                    ),
                  ]);
                  isBasmalahShown = false;

                  surahName = ayahData['sura_name_ar'];
                  jozzNum = ayahData['jozz'];
                }
              }

              return SafeArea(
                child: Container(
                  decoration: index % 2 == 0
                      ? const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                              Color(0x27000000),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.transparent
                            ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight))
                      : const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                              Color(0x27000000),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.transparent
                            ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height -
                                Scaffold.of(context).appBarMaxHeight! -
                                30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الجزء $jozzNum',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff8c5824),
                                        fontFamily: 'Kitab',
                                        fontSize: 20),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  Text(
                                    surahName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff8c5824),
                                        fontFamily: 'Kitab',
                                        fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 500),
                              child: AutoSizeText.rich(
                                minFontSize: 8,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: ayahsByPage),
                              ),
                            ),
                            Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Kitab', fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: Color(0xff915a13),
              ));
            }
          },
        ),
      ),
    );
  }
}
