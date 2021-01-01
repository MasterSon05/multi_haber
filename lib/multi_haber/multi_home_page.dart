import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_haber/config.dart';
import 'package:multi_haber/main.dart';
import 'package:multi_haber/multi_haber/haber_detay.dart';
import 'package:multi_haber/ui/utils/helper.dart';

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

class MultiHomePage extends StatefulWidget {
  @override
  _MultiHomePageState createState() => _MultiHomePageState();
}

class _MultiHomePageState extends State<MultiHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController searchCtrl = TextEditingController();

  Future<bool> _onWillPop() async {
    return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => MultiHomePage()), (route) => false);
  }

  Future _signOut() async {
    await FirebaseAuth.instance.signOut();

    pushAndRemoveUntil(context, MyApp(), false);
  }

  Future<bool> _hakDialog() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Multi Haber'),
        content: new Text(
            'Geliştirici: Mehmet Ali USTAOĞLU\nİletişim: ali.ustaoglu@icloud.com\nCopyright © 2020 Tüm Hakları Saklıdır.'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
            },
            child: new Text('Tamam'),
          ),
        ],
      ),
    ));
  }

  Future<RssFeed> haberGet() async {
    var client = http.Client();

    // RSS feed
    var response =
        await client.get('https://www.aa.com.tr/tr/rss/default?cat=guncel');
    var channel = RssFeed.parse(response.body);

    client.close();
    return channel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Hoşgeldin\n${MyAppState.currentUser.firstName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    RaisedButton(child: Text("Çıkış Yap"), onPressed: _signOut)
                  ],
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListTile(
                leading: Icon(Icons.switch_right),
                title: Text('Tema Değiştir'),
                onTap: () async {
                  setState(() {
                    currentTheme.switchTheme();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Uygulama Hakkında'),
                onTap: _hakDialog,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Container(
            height: 40,
            child: TextField(
              onChanged: (text) {
                setState(() {});
              },
              textAlign: TextAlign.center,
              controller: searchCtrl,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Haber Ara....',
                hintStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                filled: true,
                contentPadding: EdgeInsets.all(16),
                fillColor: Colors.white24,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    setState(() {});
                  }),
            )
          ],
        ),
        body: FutureBuilder<RssFeed>(
            future: haberGet(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<RssItem> news = snapshot.data.items;
                List<RssItem> tumHaber = List<RssItem>();
                if (searchCtrl.text == "" || searchCtrl.text == null) {
                  tumHaber.addAll(news);
                } else {
                  for (RssItem i in news) {
                    if (i.title.toLowerCase().contains(searchCtrl.text)) {
                      tumHaber.add(i);
                    }
                  }
                }

                return tumHaber.length > 0
                    ? GridView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: tumHaber.length,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          var haber = tumHaber[index];

                          return InkWell(
                            onTap: () {
                              push(context,
                                  WebViewContainer(haber.link, haber.title));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    //   alignment: Alignment.topCenter,
                                    image: NetworkImage(haber.imageUrl),

                                    fit: BoxFit.contain,
                                  ),
                                ),
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.red.withAlpha(220),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    haber.title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text("Aramanıza Uygun Haber Bulunamadı"),
                      );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
