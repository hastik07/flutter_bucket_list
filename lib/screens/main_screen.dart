import 'package:bucketlist/screens/add_screen.dart';
import 'package:bucketlist/screens/view_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<dynamic> bucketListData = [];
  bool isLoading = false;
  bool isError = false;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await Dio().get(
          'https://flutterapitest123-e4604-default-rtdb.firebaseio.com/bucketlist.json');
      if(response.data is List) {
        bucketListData = response.data;
      } else {
        bucketListData = [];
      }
      isLoading = false;
      isError = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      isError = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Widget errorWidget({required String errorText}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning),
          Text(errorText),
          ElevatedButton(
              onPressed: getData, child: const Text('Try again'))
        ],
      ),
    );
  }

  Widget listDataWidget() {
    List<dynamic> filteredList = bucketListData.where((element) => !(element ? ['completed'] ?? false)).toList();
    return filteredList.isEmpty ? const Center(child: Text('No data on bucket list')) : ListView.builder(
        itemCount: bucketListData.length,
        itemBuilder: (BuildContext context, int index) {
          return (bucketListData[index] is Map && (!(bucketListData[index] ? ['completed'] ?? false))) ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return ViewItemScreen(
                        index: index,
                        title: bucketListData[index] ? ['item'] ?? '',
                        image: bucketListData[index] ? ['image'] ?? '',
                      );
                    })).then((value) {
                      if(value == 'refresh') {
                        getData();
                      }
                });
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                    bucketListData[index] ? ['image'] ?? ''),
              ),
              title: Text(bucketListData[index] ? ['item'] ?? ''),
              trailing: Text(
                bucketListData[index] ? ['cost'].toString() ?? '',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ) : const SizedBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddBucketList(newIndex: bucketListData.length,))).then((value) => getData());
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bucket List'),
        actions: [
          InkWell(
            onTap: getData,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isError
                ? errorWidget(errorText: 'Error Connecting...')
                : listDataWidget()
      ),
    );
  }
}
