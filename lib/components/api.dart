import 'dart:async';

class MockApiService {
  Future<Map<String, dynamic>> fetchItems(int id, String dir) async {
    await Future.delayed(Duration(seconds: 2)); 

    List<Map<String, dynamic>> items = [];
    List<int> rev = [];

    if (dir == "up") {
      for (int i = id - 1; i >= id - 10 && i > 0; i--) {
        rev.add(i); 
      }
    
      for (int i = rev.length - 1; i >= 0; i--) {
        items.add({"id": rev[i], "title": "Item ${rev[i]}"}); 
      }
    } else if (dir == "down") {
     
      for (int i = id + 1; i <= id + 10; i++) {
        if (i > 2000) break;  
        items.add({"id": i, "title": "Item $i"});
      }
    }


    return {
      "data": items,
      "hasMore": items.isNotEmpty && (id > 0 && id < 2000),
    };
  }
}
