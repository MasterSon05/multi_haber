import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  final url;
  final title;

  WebViewContainer(this.url, this.title);

  @override
  createState() => _WebViewContainerState(this.url, this.title);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  var title;
  final _key = UniqueKey();

  _WebViewContainerState(this._url, this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(_url);
                })
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: _url))
          ],
        ));
  }
}
