import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pagination/model/user.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

int currentPage = 1;
 int totalPage = 0;
bool isLoad = true;
bool isGrid = false;

List<Users> userList = [];
final RefreshController refreshController =
    RefreshController(initialRefresh: false);
_isLoad() {
  return Center(
    child: Container(
      child: CircularProgressIndicator.adaptive(),
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  Future<bool> _getData({bool isRefresh = false}) async {
    if (!isRefresh) {
      currentPage = 1;
    }else{
         if (currentPage > totalPage) {
          refreshController.loadNoData();
          // return false;
        }
    }
    final Uri uri = Uri.parse('https://reqres.in/api/users?page=$currentPage');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      isLoad = false;
      final result = userFromJson(response.body);

      if (!isRefresh) {
        
        userList = result.data;

      } else {
        userList.addAll(result.data);
       
      }
      currentPage++;
        totalPage = result.totalPages;


      // userList = result.data;

      print(response.body);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // showCupertinoDialog(context: context, builder: builder)
    // _isLoad();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pagination View"),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isGrid = !isGrid;
                  });
                },
                icon: isGrid ? Icon(Icons.grid_view) : Icon(Icons.list))
          ],
        ),
        body: isLoad
            ? _isLoad()
            : SmartRefresher(
                controller: refreshController,
                enablePullDown: true,
                enablePullUp: true,
                // scrollController: ScrollController(initialScrollOffset: 20),
                onRefresh: () async {
                  final result = await _getData();
                  if (result) {
                    refreshController.refreshCompleted();
                  } else {
                    refreshController.refreshFailed();
                  }
                },
                onLoading: () async {
                 
                  final result = await _getData(isRefresh: true);
                  if (result) {
                    refreshController.loadComplete();
                  } else {
                    refreshController.loadFailed();
                  }
                },
                child: !isGrid
                    ? ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          final user = userList[index];
                          return ListTile(
                              trailing: Text(user.id.toString()),
                              title: Text('${user.firstName} ${user.lastName}'),
                              subtitle: Text(user.email),
                              leading: Image.network(user.avatar));
                        })
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          final user = userList[index];

                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(user.avatar),
                                Text(user.firstName),
                                Text(user.email),
                              ],
                            ),
                          );
                        }),
              ));
  }
}
