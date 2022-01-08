

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:my_isekai/battle_pages/battleInfo.dart';
import 'package:my_isekai/models/otherUser.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/services/auth.dart';
import 'package:my_isekai/services/state_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';




class ListBattles extends StatefulWidget {
  final Function loading;
ListBattles({Key key,this.loading}) : super(key: key);

  @override
  
  State<StatefulWidget> createState() {
    return _ListBattlesState();
  }
}

class _ListBattlesState extends State<ListBattles>{

_ListBattlesState({Key key});

  


  @override
  Widget build(BuildContext context) {
    return _body();
      
  }

  _body() {
    return Column(
      children: <Widget>[
        MessengerAppBar(
          title: 'Chat',
        ),
        _buildRootListView(),
      ],
    );
  }

  _buildRootListView() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            // return _buildSearchBar();
            return SizedBox(height: 50,);
          } else if (index == 1) {
            return ConversationList();
            //future builder
          } else {
            return Text('nada');//Stream builder
          }
        },
        itemCount: 2,
      ),
    );
  }

  _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: SearchBar(),
    );
  }


}

class MessengerAppBar extends StatefulWidget {
  
  String title;
  
  MessengerAppBar({this.title = ''});

  @override
  _MessengerAppBarState createState() => _MessengerAppBarState();
}

class _MessengerAppBarState extends State<MessengerAppBar> {
  SharedPreferences prefs;
  String fotoCurrtentUser;
  StateModel appState;


_buildImageCurrentUser(userfoto){
  if(userfoto != ''){
    return Material(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        clipBehavior: Clip.hardEdge,
    child: Image.network(
        userfoto,
        width: 35.0,
        height: 35.0,
        fit: BoxFit.cover,
      ),
  );
  }else{
    return Icon(Icons.person, size: 60,color: Colors.grey,);
  }
   
  
}
  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;

   
    final userfoto = appState?.user?.user_foto ?? '';
    return Container(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: 16.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  _buildImageCurrentUser(userfoto)
                ),
              Container(width: 8.0,),
              AppBarTitle(
                text: widget.title,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppBarNetworkRoundedImage extends StatelessWidget {
  
  final String imageUrl;
  
  AppBarNetworkRoundedImage({@required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl)
          )
        ),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  
  final String text;

  AppBarTitle({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w700
      ),
    );
  }
}



class ConversationList extends StatefulWidget {
  ConversationList({Key key,}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ConversationListState();
  }
}

class _ConversationListState extends State<ConversationList> {

  _ConversationListState({Key key});
  StateModel appState;
  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    GeoPoint userLocation = appState.user.coordinates;
    return Column(
      children: <Widget>[
        StreamBuilder(
                    stream: appState.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                          ),
                        );
                      } else {
                        return ListView.builder(
                          key: Key(UniqueKey().toString()),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ConversationListItem(battle:snapshot.data().documents[index],index: index,userLocation:userLocation),
                          itemCount: snapshot.data.documents.length,
                        );
                      }
                    },
                  ),
      ],
    );
  }
}

class ConversationListItem extends StatefulWidget {
  final int index;
  final Map battle;
  final GeoPoint userLocation;


  ConversationListItem({Key key, @required this.battle,@required this.index,@required this.userLocation}) : super(key: key);

  @override
  _ConversationListItemState createState() => _ConversationListItemState(key: key,index: index, battle: battle,userLocation:userLocation);
}
  
class _ConversationListItemState extends State<ConversationListItem>  with SingleTickerProviderStateMixin{
  final int index;
  final Map battle;
  final GeoPoint userLocation;
  final Key key;
_ConversationListItemState({this.key, @required this.battle,@required this.index,@required this.userLocation});

  SharedPreferences prefs;
  String peerAvatar;
  int secondsAnimation;
  Animation animation;
  Animation animation2;
  Animation animation3;
  Animation transformationAnim;
  AnimationController animationController;
  StateModel appState;

  Future<OtherUser> otherUserProfile;

  Future<OtherUser> getOtherUser() async{
     var otherUserExist = await Auth.getOtherUserLocal(battle['idPerson']);
     if(otherUserExist == null) {
      var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'getInfoUser'); // replace 'functionName' with the name of your function
              var response = await callable.call(<String, dynamic>{
                  "latitude":userLocation.latitude,
                  "longitude":userLocation.longitude,
                  "idOther":battle['idPerson'],
                }).catchError((onError) {
              });

              OtherUser otherUser = OtherUser.otherfromDocument(response.data);
              await Auth.storeOtherUserLocal(otherUser);
      return otherUser;
     }else{
      return otherUserExist;
     }
  }

    @override
  void initState() {
    print('${battle['idPerson']}');
    otherUserProfile = getOtherUser();
    super.initState();
  if(widget.index <= 4){
    secondsAnimation =  widget.index + 1;
  }else{
    secondsAnimation = 5;
  }
  animationController = AnimationController(duration: Duration(seconds: secondsAnimation), vsync: this);
  
  animation2 = Tween(begin: -1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));

  transformationAnim = BorderRadiusTween(
    begin:BorderRadius.circular(125.0),
    end: BorderRadius.circular(0.0)).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.ease
      )
    );
  
  animationController.forward();
  }


  @override
void dispose() {
  animationController.dispose();
  super.dispose();
}


_buildFoto(foto){
  if(foto != ''){
      return ClipRRect(
          borderRadius: new BorderRadius.circular(40.0),
          child:Image.network(foto,fit: BoxFit.cover,
                  width: 60.0,
                  height: 60.0,
                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null ? 
                            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    );
                  },
                ),       
        );
  }else{
      return Icon(Icons.person, size: 60,color: Colors.grey,);
  }
  
}

_buildNome(nome,titulo){
  return Column(
    children: <Widget>[
      Text(nome),
      Text(titulo,style: TextStyle(fontSize: 12,color: Colors.grey[500],fontStyle: FontStyle.italic))
    ],
  );
}

_buildResult(result){
  return RaisedButton(
                color: Colors.green,
                elevation: 5,
                shape: new CircleBorder(),
                padding: new EdgeInsets.all(0.0),
                onPressed: () {
                },
                child: ImageIcon(
               AssetImage("assets/images/lutar.png",),
                    color: Colors.white,
                    size: 30,
               ),
              );
}
_buildKm(distance){
 return Text('$distance km',style: TextStyle(fontSize: 12,color: Colors.grey[500],fontStyle: FontStyle.italic));
}
         
_buildItem(OtherUser data ){
  appState = StateWidget.of(context).state;
  final id = appState?.user?.id ?? '';

  return InkWell(
      splashColor: Colors.blue,
            onTap: () {
                return Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a1, a2) =>new BattleInfo( peerNome:data.user_nome,peerId: '${battle['idPerson']}',peerAvatar: data.user_foto,currentUserId: id,battleHash: '${battle['battleHash']}',idchallenged:'${battle['idChallenged']}'),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 400),
                  ),
                );
            },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
            Container(child:Row(
                children: <Widget>[
                  _buildFoto(data.user_foto),
                  _buildNome(data.user_nome,data.user_titulo),
                    ],
                  ),
                ),
            Column(children: <Widget>[
              _buildResult('Win'),
              _buildKm(data.distanceBetween)
            ],)

    ],),
      ),
  );
}
  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: Dismissible(  
  // Show a red background as the item is swiped away.
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [0.1,],
                              colors: [
                                Color.fromRGBO(63, 72, 203, 0.5),

                              ],
                            ),
                        borderRadius: new BorderRadius.circular(8.0),
                      ),
      ),
      key: Key(UniqueKey().toString()), 
      confirmDismiss: (direction) async {
          return false;
      },
      child:FutureBuilder(
          future: otherUserProfile,
          builder: (context,snapshot){
                  if(snapshot.hasError)
                    print(snapshot.error);
                  return snapshot.hasData
                      ?_buildItem(snapshot.data)
                      :Center(child: Column(children: <Widget>[
                        Text('Carregando',style: TextStyle(fontSize: 12,color: Colors.grey[500],fontStyle: FontStyle.italic)),
                        CircularProgressIndicator()
                      ],),);
                  },
              )
     )
    );
  }







}

class SearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200
      ),
      child: Row(
        children: <Widget>[
          Container(width: 10.0,),
          Icon(Icons.search),
          Container(width: 8.0,),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search'
              ),
            ),
          )
        ],
      ),
    );
  }
}





