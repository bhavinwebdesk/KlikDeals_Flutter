import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_deals/ApiBloc/ApiBloc_event.dart';
import 'package:klik_deals/ApiBloc/ApiBloc_state.dart';
import 'package:klik_deals/ApiBloc/models/CouponListResponse.dart';
import 'package:klik_deals/History_bloc.dart';
import 'package:klik_deals/commons/KeyConstant.dart';
import 'package:klik_deals/mywidgets/BottomLoader.dart';
import 'package:klik_deals/mywidgets/CouponErrorWidget.dart';
import 'package:klik_deals/mywidgets/CouponHistoryItem.dart';
import 'package:klik_deals/mywidgets/CouponItem.dart';
import 'package:klik_deals/mywidgets/EmptyListWidget.dart';
import 'package:klik_deals/mywidgets/NoNetworkWidget.dart';
import 'package:klik_deals/mywidgets/RoundWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeState.dart';

var token = "";
SharedPreferences sharedPreferences;

class HistoryTabWidget extends StatefulWidget {
  bool isForHistory;

  HistoryTabWidget(this.isForHistory);

  @override
  State<StatefulWidget> createState() => new _HistoryTabState(isForHistory);
}

class _HistoryTabState extends State<HistoryTabWidget> {
  // with AutomaticKeepAliveClientMixin<HistoryTabWidget>{
  bool _isLoading;
  HistoryBloc auth;
  int _perpage = 10;
  var choices;
  bool isForHistory;
  ApiBlocEvent lastEvent;

//Pagination Stuff Start
  int currentPage = 1;
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  bool hasReachedEnd = false;
  bool inProcess = false;
//Pagination Stuff End

  _HistoryTabState(this.isForHistory);

  @override
  void initState() {
    super.initState();
    print("we are initstate _HistoryTabState");
    getToken();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if (!hasReachedEnd && !inProcess) {
        inProcess = true;
        print("Before current page : $currentPage");
        currentPage = currentPage + 1;
        print("current page : $currentPage");
        getCouponList();
      } else {
        // print("limit reahed : " + hasReachedEnd.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("we are build _HistoryTabState");
    auth = BlocProvider.of<HistoryBloc>(context);
    return Scaffold(
      body: BlocListener<HistoryBloc, ApiBlocState>(
        listener: (context, state) {
          if (state is ApiErrorState) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('error occurred during fetching history coupons..'),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );
          } else if (state is CouponListFetchedState) {}
        },
        child: BlocBuilder<HistoryBloc, ApiBlocState>(
            bloc: auth,
            builder: (
              BuildContext context,
              ApiBlocState currentState,
            ) {
              inProcess = false;
              if (currentState is ApiFetchingState) {
                print("Home Page :: We are in fetching state.....");
                return RoundWidget();
              } else if (currentState is CouponHistoryErroState) {
                print(
                    "Home Page :: We got error.....${currentState.couponlist.errorMessage.error[0]}");
                return CouponErrorWidget(
                    errorMessage:
                        currentState.couponlist.errorMessage.error.first);
              } else if (currentState is CouponHistoryListFetchedState) {
                return _couponList(currentState.couponlist.response);
              } else if (currentState is ApiEmptyState) {
                print("Home Page :: We got empty data.....");
                return EmptyListWidget(
                    emptyMessage: KeyConstant.ERROR_NO_COUPON_HISTORY);
              } else if (currentState is NoInternetState) {
                return NoNetworkWidget(
                  retry: () {
                    retryCall();
                  },
                );
              } else {
                return EmptyListWidget(
                    emptyMessage: KeyConstant.ERROR_NO_COUPON_HISTORY);
              }
            }),
      ),
    );
    // return null;
  }

  Widget _couponList(Response data) {
    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/splash_bg.png'),
                fit: BoxFit.cover)),
      ),
      _gridView(data),
    ]);
  }

  Widget _gridView(Response data) {
    return CustomScrollView(controller: _scrollController, slivers: <Widget>[
      new SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 10.0 / 12.5,
              crossAxisCount: 2,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              var listData = data.data[index];
              listData.isFromHistory = isForHistory;
              return CouponHistoryItem(data: listData);
            },
            childCount: getTotalCount(data),
          )),
      new SliverToBoxAdapter(
        child: hasReachedEnd ? Container() : BottomLoader(),
      )
    ]);
  }

  int getTotalCount(Response vendorList) {
    var responseData = vendorList;
    hasReachedEnd = responseData.currentPage == responseData.lastPage;
    print(
        "CategoriesListScreen We need Data ::: $hasReachedEnd :: ${responseData.currentPage} :: ${responseData.lastPage}");
    // BottomLoader();
    // print("CategoriesListScreen we are in bottom of::$BottomLoader()");
    // return vendorList == null ? 0 : resppnse.data.length + (hasReachedEnd? 0 : 1);
    var totalLength = responseData.data.length; // + (hasReachedEnd ? 0 : 1);
    print("We are returning totalLength : $totalLength");
    return totalLength;
  }

  getToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString("token");
    if (token != null && token.isNotEmpty) {
      getCouponList();
    } else {}
    print("Home Page :: We got Token $token");
  }

  void getCouponList() {
    try {
      lastEvent = CouponListEvent(_perpage, "history", currentPage);
      auth.add(lastEvent);
    } catch (e) {
      print("Home Page :: We got error in catch.....${e.toString()}");
    }
  }

  void retryCall() {
    if (lastEvent != null) {
      auth.add(lastEvent);
    }
  }

  // @override
  // bool get wantKeepAlive => true;
}
