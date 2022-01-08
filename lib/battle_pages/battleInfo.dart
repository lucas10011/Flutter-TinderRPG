import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:my_isekai/battle_pages/battleInfo_pages/historybattle.dart';
import 'package:my_isekai/battle_pages/battleInfo_pages/listmessage.dart';
import 'package:my_isekai/models/otherUser.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/services/auth.dart';


class BattleInfo extends StatefulWidget {
  final String peerNome;
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final String idchallenged;
  final String battleHash;

  BattleInfo({Key key, @required this.peerNome,@required this.peerId, @required this.peerAvatar,@required this.currentUserId,this.idchallenged,this.battleHash}) : super(key: key);

  @override
  State createState() => new BattleInfoState(peerNome: peerNome,peerId: peerId, peerAvatar: peerAvatar,currentUserId: currentUserId,battleHash: battleHash,idchallenged:idchallenged);
}

class BattleInfoState extends State<BattleInfo> with SingleTickerProviderStateMixin {
  String peerNome;
  String battleHash;
  String currentUserId;
  String idchallenged;
  String peerId;
  String peerAvatar;
  String peerName;
  StateModel appState;
  BattleInfoState({Key key, @required this.peerNome,@required this.peerId, @required this.peerAvatar,@required this.currentUserId,this.idchallenged,@required this.battleHash});
  
  Color whatsAppGreen = Color.fromRGBO(0, 0, 0, 1.0);
  Color whatsAppGreenLight = Color.fromRGBO(37, 211, 102, 1.0);

  Future statusBattle;

  TabController tabController;

    Future<OtherUser> attOtherUser() async{
     var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'getInfoUser'); // replace 'functionName' with the name of your function
              var response = await callable.call(<String, dynamic>{
                  "idOther":peerId,
                }).catchError((onError) {
              });

              OtherUser otherUser = OtherUser.otherfromDocument(response.data);
              await Auth.storeOtherUserLocal(otherUser);
      return otherUser;
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      statusBattle = Firestore.instance.collection("battles").document("$battleHash").collection('result').document("$battleHash").get();
    });
    
    tabController = TabController(vsync: this, length: 2)
      // ..addListener(() {
      //   setState(() {
      //     switch (tabController.index) {
      //       case 0:
      //         break;
      //       case 1:
      //         fabIcon = Icons.message;
      //         break;
      //     }
      //   });
      // })
      ;
  }




_buildFoto(foto){
  if(foto != ''){
      return ClipRRect(
          borderRadius: new BorderRadius.circular(40.0),
          child: Image.network(foto,fit: BoxFit.cover,
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


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Row(children: <Widget>[
          _buildFoto(peerAvatar),
          Text('$peerNome',style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w600,)),
          ],
        ),
        backgroundColor: whatsAppGreen,
        bottom: TabBar(
          tabs: [
            Tab(
              child: Text('Chat'),
            ),
            Tab(
              icon: ImageIcon(
               AssetImage("assets/images/lutar.png",),
                    color: Colors.white,
               ),
            ),
          ],
          indicatorColor: Colors.white,
          controller: tabController,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ListMessages(peerNome: peerNome,peerId: peerId, peerAvatar: peerAvatar,currentUserId: currentUserId,battleHash: battleHash,idchallenged:idchallenged),
          BattleHistoryChat(statusBattle:statusBattle,currentUserId:currentUserId,peerId: peerId,),     
        ],
      ),
    );
  }
}

