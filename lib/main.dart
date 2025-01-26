import 'package:flutter/material.dart';
import 'package:speechx/components/api.dart';
import 'package:speechx/components/item.dart';
import 'package:speechx/components/shimmerwid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Two-Way Paginated List with Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ItemListView(),
    );
  }
}

class ItemListView extends StatefulWidget {
  @override
  _ItemListViewState createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  final MockApiService _apiService = MockApiService();
  final ScrollController _scrollController = ScrollController();

  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoadingUp = false;
  bool _isLoadingDown = false;
  bool _hasMoreUp = true;
  bool _hasMoreDown = true;
  String _searchQuery = '';
  double _scrollPercentage = 0.0;  // Variable to track scroll progress
  double _draggedPosition = 0.0;  // Variable to track dragged position of scroll tracker

  @override
  void initState() {
    super.initState();
    _fetchInitialItems();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialItems() async {
    setState(() {
      _isLoadingDown = true;
    });

    final response = await _apiService.fetchItems(100, "down");
    final fetchedItems = (response['data'] as List)
        .map((item) => Item.fromJson(item))
        .toList();

    setState(() {
      _items = fetchedItems;
      _filteredItems = fetchedItems;
      _hasMoreDown = response['hasMore'];
      _isLoadingDown = false;
    });

    if (_items.length < 15) {
      final lastId = _items.isNotEmpty ? _items.last.id : 0;
      _fetchItems(id: lastId, direction: "down");
    }
  }

  void _fetchItems({required int id, required String direction}) async {
    if ((direction == "up" && _isLoadingUp) || (direction == "down" && _isLoadingDown)) return;

    setState(() {
      if (direction == "up") {
        _isLoadingUp = true;
      } else {
        _isLoadingDown = true;
      }
    });

    final response = await _apiService.fetchItems(id, direction);
    final fetchedItems = (response['data'] as List)
        .map((item) => Item.fromJson(item))
        .toList();

    setState(() {
      if (direction == "up") {
        _hasMoreUp = response['hasMore'];
        _items = [...fetchedItems, ..._items];
        _filteredItems = _items;
        _isLoadingUp = false;
      } else {
        _hasMoreDown = response['hasMore'];
        _items = [..._items, ...fetchedItems];
        _filteredItems = _items;
        _isLoadingDown = false;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredItems = _items
          .where((item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _onScroll() {
    double position = _scrollController.position.pixels;
    double maxScroll = _scrollController.position.maxScrollExtent;
    double minScroll = _scrollController.position.minScrollExtent;

    double scrollProgress = (position - minScroll) / (maxScroll - minScroll);

    setState(() {
      _scrollPercentage = scrollProgress;
    });

    if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent + 20 && _hasMoreUp) {
      final firstId = _items.isNotEmpty ? _items.first.id : 0;
      _fetchItems(id: firstId, direction: "up");
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20 && _hasMoreDown) {
      final lastId = _items.isNotEmpty ? _items.last.id : 0;
      _fetchItems(id: lastId, direction: "down");
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _draggedPosition += details.primaryDelta!;
      
      _draggedPosition = _draggedPosition.clamp(0.0, MediaQuery.of(context).size.height - 50);

    
      _scrollPercentage = _draggedPosition / (MediaQuery.of(context).size.height - 50);
      
      
      double maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(_scrollPercentage * maxScroll);
    });
  }

  void _onTapScrollTracker() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double targetScrollPosition = _scrollPercentage * maxScroll;
    _scrollController.jumpTo(targetScrollPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Two-Way Paginated List with Search'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width : double.infinity,
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: _filteredItems.length + (_isLoadingUp ? 1 : 0) + (_isLoadingDown ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoadingUp && index == 0) {
                      return ShimmerWidget();
                    }
                    if (_isLoadingDown && index == _filteredItems.length + (_isLoadingUp ? 1 : 0)) {
                      return ShimmerWidget();
                    }

                    final item = _filteredItems[_isLoadingUp ? index - 1 : index];
                    return Card(
                      shape: Border.all(width: 1),
                      child: ListTile(
                        title: _buildHighlightedText(item.title),
                        tileColor: Colors.lightBlue.shade50,
                        leading: Icon(Icons.arrow_circle_right, color: Colors.black),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Newpage()),);
                        },
                      ),
                    );
                  },
                ),
                if (_filteredItems.isEmpty && !_isLoadingDown)
                  Center(child: Text('No items to display.')),
                
                Positioned(
                  top: _scrollPercentage * MediaQuery.of(context).size.height,
                  right: 10,
                  child: GestureDetector(
                    onVerticalDragUpdate: _onDragUpdate,
                    onTap: _onTapScrollTracker,
                  
                    child: Container(
                      width: 9,
                      height: 40,  
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    final pattern = RegExp(_searchQuery, caseSensitive: false);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 18));
    }

    final children = <TextSpan>[];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        children.add(TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(color: Colors.black, fontSize: 18)));
      }

      children.add(TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)));

      start = match.end;
    }

    if (start < text.length) {
      children.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(color: Colors.black, fontSize: 18)));
    }

    return RichText(text: TextSpan(children: children));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class Newpage extends StatelessWidget {
  const Newpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text("This is Item")),
    );
  }
}
