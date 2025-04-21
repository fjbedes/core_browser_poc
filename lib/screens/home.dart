import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart'; // Import the package
import 'package:webview_flutter/webview_flutter.dart'; // Import the webview package

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _url = 'https://stg1.webassessor.com/'; // Default URL
  WebViewController? _webViewController; // Nullable WebViewController
  bool _isWebViewReady = false; // Track if the WebView is ready
  bool _isLoading = false; // Track if the WebView is loading
  final FocusNode _searchFocusNode =
      FocusNode(); // FocusNode for the search bar
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search bar

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();

    // Initialize the search bar with the default URL
    _searchController.text = _url;

    // Listen for focus changes on the search bar
    _searchFocusNode.addListener(() {
      setState(() {}); // Trigger rebuild to reflect focus changes
    });
  }

  Future<void> _initializeWebViewController() async {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() {
                  _isLoading = true; // Show loading spinner
                  _url = url;
                  _searchController.text =
                      url; // Update the search bar with the current URL
                });
              },
              onPageFinished: (url) {
                setState(() {
                  _isLoading = false; // Hide loading spinner
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(_url));
    setState(() {
      _isWebViewReady = true; // Mark WebView as ready
    });
  }

  bool _isValidUrl(String url) {
    final urlPattern =
        r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(url);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensure taps are detected anywhere
      onTap: () {
        // Unfocus the search bar when tapping outside
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (!_searchFocusNode.hasFocus) ...[
                IconButton(
                  icon: const Icon(Ionicons.arrow_back),
                  onPressed: () async {
                    if (_webViewController != null &&
                        await _webViewController!.canGoBack()) {
                      _webViewController!.goBack(); // Navigate back
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Ionicons.arrow_forward),
                  onPressed: () async {
                    if (_webViewController != null &&
                        await _webViewController!.canGoForward()) {
                      _webViewController!.goForward(); // Navigate forward
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Ionicons.lock_closed),
                  onPressed: () {
                    // Handle lock action
                  },
                ),
              ],
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller:
                        _searchController, // Attach the TextEditingController
                    focusNode: _searchFocusNode, // Attach the FocusNode
                    textInputAction:
                        TextInputAction.go, // Show "Go" on the keyboard
                    decoration: InputDecoration(
                      hintText:
                          _searchController.text, // Dynamically update hintText
                      prefixIcon: const Icon(
                        Ionicons.search,
                        color: Colors.grey,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController
                                        .clear(); // Clear the search bar
                                  });
                                },
                              )
                              : null, // Show "X" icon only when there is text
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                    ),
                    onSubmitted: (value) {
                      String newUrl;
                      if (_isValidUrl(value)) {
                        newUrl =
                            value.startsWith('http')
                                ? value
                                : 'https://$value'; // Ensure valid URL
                      } else {
                        newUrl =
                            'https://www.google.com/search?q=${Uri.encodeComponent(value)}'; // Google search
                      }
                      setState(() {
                        _url = newUrl;
                      });
                      _webViewController?.loadRequest(
                        Uri.parse(newUrl),
                      ); // Load the new URL
                    },
                  ),
                ),
              ),
              if (!_searchFocusNode.hasFocus)
                IconButton(
                  icon: const Icon(Ionicons.refresh),
                  onPressed: () {
                    _webViewController?.reload(); // Reload the current page
                  },
                ),
            ],
          ),
        ),
        body: Stack(
          children: [
            if (_isWebViewReady)
              WebViewWidget(
                controller:
                    _webViewController!, // Use the initialized controller
              ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(), // Show a loading spinner
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // Dispose the FocusNode to avoid memory leaks
    _searchController.dispose(); // Dispose the TextEditingController
    super.dispose();
  }
}
