import 'package:flutter/material.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/services/state_widget.dart';
import 'package:my_isekai/widgets/battleinfotable.dart';

class BattleHistoryChat extends StatefulWidget {

final Future statusBattle;
final String currentUserId;
final String peerId;
BattleHistoryChat({this.statusBattle,this.currentUserId,this.peerId});

  @override
  _BattleHistoryChatState createState() => _BattleHistoryChatState(statusBattle:statusBattle,currentUserId:currentUserId,peerId:peerId);
}

class _BattleHistoryChatState extends State<BattleHistoryChat> {
Future statusBattle;
String currentUserId;
String peerId;
_BattleHistoryChatState({this.statusBattle,this.currentUserId,this.peerId});
StateModel appState;

buildResult(data,id){

  Text textXp = Text(
  "Recebeu ${data['resultbattle'][0]['xp']} de xp ",
  style:TextStyle(
    fontSize: 25,
    color: Colors.green,
    fontWeight: FontWeight.w300));
  
  Text textDerrotado = Text(
  "Derrotado",
  style:TextStyle(
    fontSize: 30,
    color: Colors.red,
    fontWeight: FontWeight.w300));


  if(data['$id']['result']){
    return textXp;
  }else{
    return textDerrotado;
  }
  
}


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
           image: DecorationImage(image:new ExactAssetImage('assets/images/old-map-light.jpg'), fit: BoxFit.cover)             
                      ),
      child: Center(
            child: FutureBuilder(
        future: widget.statusBattle,
        builder: (context,snapshot){
                    if(snapshot.hasError)
                      print(snapshot.error);
                    return snapshot.hasData
                        ?Column(children: <Widget>[
                          buildResult(snapshot.data,currentUserId),
                          Expanded(child: BattleInfoHistory(history: snapshot.data, currentUserId: currentUserId,peerId:peerId))
                        ],)
                        :Container();
            },
        ),
      ),
    );
  }
}