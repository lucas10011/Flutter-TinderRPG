import 'dart:async';
import 'dart:math';
import 'package:flushbar/flushbar.dart';
import 'package:my_isekai/home_page/SwipeAnimation/activeMonster.dart';
import 'package:my_isekai/home_page/SwipeAnimation/animationBattle.dart';
import 'package:my_isekai/home_page/SwipeAnimation/activeCard.dart';
//import 'package:animation_exp/PageReveal/page_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:my_isekai/home_page/battleFunction/battlesFunction.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/models/todo.dart';
import 'package:my_isekai/services/calculo.dart';
import 'package:my_isekai/services/getmonster.dart';
import 'package:my_isekai/services/state_widget.dart';
import 'package:my_isekai/widgets/atributo.dart';
import 'package:my_isekai/widgets/battleinfotable.dart';
import 'package:my_isekai/widgets/element.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CardDemo extends StatefulWidget {
  final String userId;
  final GlobalKey scaffoldstate;
  final Function loading;
  final int distance;
  final Map monsters;
  
  CardDemo({this.userId,this.loading,this.scaffoldstate,this.distance,this.monsters});
  @override
  CardDemoState createState() => new CardDemoState(scaffoldstate:scaffoldstate,distance:distance);
}

class CardDemoState extends State<CardDemo> with SingleTickerProviderStateMixin {
  int distance;
  GlobalKey scaffoldstate;
  CardDemoState({this.scaffoldstate,this.distance});

  Map<String,Map<String,int>> level = {'level': {'1': 150, '2': 225, '3': 337, '4': 506, '5': 759, '6': 1139, '7': 1708, '8': 2562, '9': 3844, '10': 5766, '11': 8649, '12': 12974, '13': 19461, '14': 29192, '15': 43789, '16': 65684, '17': 98526, '18': 147789, '19': 221683, '20': 332525, '21': 498788, '22': 748182, '23': 1122274, '24': 1683411, '25': 2525116, '26': 3787675}}; 

  StateModel appState;
  int flag = 0;
  double opacityvalue = 0;
  
  bool isLoading = false;
  double heightValue = 1;

  AnimationController controller;
  Animation animation;
  Animation animation2;






  String idOther;
  Map dataBattle;
  bool exibedataBattle = false;


  String imgBattle = '';
  String nameBattle = '';

  bool loadingBattle = false;
  
  bool disableMatch = false;




void initState() { 
    super.initState();


    controller = AnimationController(duration: const Duration(seconds: 4), vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {            
          // controller.reverse();            
        }else if(status == AnimationStatus.dismissed){
          setState(() {
            disableMatch = false;
          });
        } 
      });
    animation = Tween<Offset>(begin:Offset(-2,0), end:Offset(0,0)).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.9, curve: Curves.bounceOut),
    ));
    animation2 = Tween<Offset>(begin:Offset(2,0), end:Offset(0,0)).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.9, curve: Curves.bounceOut),
    ));

    
    

  }


@override
void dispose() {
    
    controller.dispose();
    super.dispose();
  }


void attMonsters() async {
  

  if(isLoading != true ){
      setState(() {
      isLoading = true;
    });
    }
  
  appState = StateWidget.of(context).state;
  var level = appState.user.user_level;
  var coordinates = appState.user.coordinates;
 
  var getmonsters = await Monsters.getMonsters(level,coordinates);
  Map monsters = await Monsters.getListMonsters(distance,widget.userId,getmonsters);
  setState(() {
           StateWidget.of(context).state.monsters = monsters;
           isLoading = false;
          });
}

void removebattle(item) {
    appState = StateWidget.of(context).state;
    // item.remove('monster');
    setState(() {
     StateWidget.of(context).removeMonster(item);
    });
    BattleFunction.battleRun(item,appState) ;
  }

void addbattle(item) async {
  if (disableMatch != true) {
      appState = StateWidget.of(context).state;
      var myid = appState.user.id;
      final userlevel = appState?.user?.user_level ?? '';
      final levelup = level['level']['$userlevel']; 

      // item.remove('monster'); //remove a key monster dizendo se é monstro ou nao pra poder remover da lista se nao,nao funciona
      setState(() {
        StateWidget.of(context).removeMonster(item);
        disableMatch = true;
        idOther = item['id'];
        imgBattle = item['user_foto'];
        nameBattle = item['user_nome'];
      });

     controller.forward();

      /////////////////////////////////////Battle/////////////////////////////////////////////
    try{
     await BattleFunction.battleMatch(item,appState).then((resultado){
       if(resultado != false){
         setState(() {
          dataBattle = resultado;
          exibedataBattle = true;
        });
      if(resultado['$myid']['result'] == true){
        setState(() {
          StateWidget.of(context).state.status['xp'] += resultado['resultbattle'][0]['xp'];
        });

        if(StateWidget.of(context).state.status['xp'] > levelup){
            StateWidget.of(context).state.user.user_level += 1;
            StateWidget.of(context).state.status['strenght'] += 5;
            StateWidget.of(context).state.status['agility'] +=5;
            StateWidget.of(context).state.status['inteligence'] +=5;

        }

        }else{
          if (StateWidget.of(context).state.status['xp'] < resultado['resultbattle'][0]['xp']){
            setState(() {
              StateWidget.of(context).state.status['xp'] = 0;
            });
          
          }else{
            setState(() {
              StateWidget.of(context).state.status['xp'] -= resultado['resultbattle'][0]['xp'];
            });
          }
          
        }
       }else{
         closeBattle();
         print('sem batle');
       }
        
      });
    }catch(e){
      Flushbar(
          title: "Error",
          message: "$e",
          duration: Duration(seconds: 5),
        )..show(context);
    }

    }else{
      print('disable');
    }
  }

void removebattleMonster(item,BuildContext context) {
  setState(() {
    StateWidget.of(context).removeMonster(item);
  });
    
  }

void addbattleMonster(item) async {
  if (disableMatch != true){
    appState = StateWidget.of(context).state;
    var status = appState.status;
    var myid = appState.user.id;
    var otherid = item['id'];
    final userlevel = appState?.user?.user_level ?? '';
    final levelup = level['level']['$userlevel']; 
   
    
    setState(() {
      StateWidget.of(context).removeMonster(item);
      disableMatch = true;
      idOther = '${item['id']}';
      imgBattle = item['img'];
      nameBattle = item['name'];
     });
     
    controller.forward();


   try{

    await Calculo.calculoBatalha(status,item,item['name'],myid,otherid,int.parse(item['level']),item['difficulty'],false,null).then((resultado) async {
      print(resultado['resultbattle'][0]['drop']);
      resultado['dice'] = false;
       setState(() {
          dataBattle = resultado;
          exibedataBattle = true;
        });

      if(resultado['$myid']['result'] == true){
        setState(() {
          StateWidget.of(context).state.status['xp'] += resultado['resultbattle'][0]['xp'];
        });

        if(StateWidget.of(context).state.status['xp'] > levelup){
            StateWidget.of(context).state.user.user_level += 1;
            StateWidget.of(context).state.status['strenght'] += 5;
            StateWidget.of(context).state.status['agility'] +=5;
            StateWidget.of(context).state.status['inteligence'] +=5;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                //aprender como passar as cordernadas para string
                String storeUser = userToJson(StateWidget.of(context).state.user);
                await prefs.setString('user', storeUser);
        }

      }else{
        if (StateWidget.of(context).state.status['xp'] < resultado['resultbattle'][0]['xp']){
          setState(() {
            StateWidget.of(context).state.status['xp'] = 0;
          });
         
        }else{
          setState(() {
            StateWidget.of(context).state.status['xp'] -= resultado['resultbattle'][0]['xp'];
          });
        }
        
      }
      });
   }catch(e){
     Flushbar(
          title: "Error",
          message: "$e",
          duration: Duration(seconds: 5),
        )..show(context);
   }
    }else{
      print('disable');
    }
  }

void addbattleDiceMonster(item) async {
  if (disableMatch != true){
    appState = StateWidget.of(context).state;
    var status = appState.status;
    var myid = appState.user.id;
    var otherid = item['id'];
    final userlevel = appState?.user?.user_level ?? '';
    final levelup = level['level']['$userlevel']; 
   
    
    setState(() {
      StateWidget.of(context).removeMonster(item);
      disableMatch = true;
      idOther = '${item['id']}';
      imgBattle = item['img'];
      nameBattle = item['name'];
     });
    Random rnd = new Random();
    var diceValue = rnd.nextInt(20) + 1;
     
    controller.forward();


   try{

    await Calculo.calculoBatalha(status,item,item['name'],myid,otherid,int.parse(item['level']),item['difficulty'],diceValue,null).then((resultado) async {
        resultado['dice'] = diceValue;

       setState(() {
          dataBattle = resultado;
          exibedataBattle = true;
        });

      if(resultado['$myid']['result'] == true){
        setState(() {
          StateWidget.of(context).state.status['xp'] += resultado['resultbattle'][0]['xp'];
        });

        if(StateWidget.of(context).state.status['xp'] > levelup){
            StateWidget.of(context).state.user.user_level += 1;
            StateWidget.of(context).state.status['strenght'] += 5;
            StateWidget.of(context).state.status['agility'] +=5;
            StateWidget.of(context).state.status['inteligence'] +=5;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                //aprender como passar as cordernadas para string
                String storeUser = userToJson(StateWidget.of(context).state.user);
                await prefs.setString('user', storeUser);
        }

      }else{
        if (StateWidget.of(context).state.status['xp'] < resultado['resultbattle'][0]['xp']){
          setState(() {
            StateWidget.of(context).state.status['xp'] = 0;
          });
         
        }else{
          setState(() {
            StateWidget.of(context).state.status['xp'] -= resultado['resultbattle'][0]['xp'];
          });
        }
        
      }
      });
   }catch(e){
     Flushbar(
          title: "Error",
          message: "$e",
          duration: Duration(seconds: 5),
        )..show(context);
   }
    }else{
      print('disable');
    }
  }


void closeBattle(){
  setState(() {
    dataBattle = null;
    exibedataBattle = false;
  });
  controller.reverse();  
}

void changeOpacity(){
  if(opacityvalue == 1){
    setState(() {
      opacityvalue = 0;
      heightValue = 1;
    });
  }else{
    setState(() {
      opacityvalue = 1;
      heightValue = 215;
    });
  }
 
}


Widget listView(context,monstersAndPlayers){ 

    timeDilation = 0.4;
    double initialBottom = 15.0;
    var dataLength = monstersAndPlayers.length;
    double backCardPosition = initialBottom + (dataLength - 1) * 10 + 10;
    double backCardWidth = 0;
  return monstersAndPlayers.isNotEmpty
              ? ListView.builder(
                  // physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                      return  
                      monstersAndPlayers[index]['monster'] 
                      ? cardMonster(
                          monstersAndPlayers[index],
                          backCardWidth + 10,
                          context,
                          removebattleMonster,
                          addbattleMonster,
                          addbattleDiceMonster,
                          index,
                          
                        )
                      
                      :cardDemo(
                          monstersAndPlayers[index],
                          backCardWidth + 10,
                          context,
                          removebattle,
                          addbattle,
                          index,
                          
                      );                   
                  },
                  itemCount: monstersAndPlayers.length,
                ) : Text('Nenhum  monstro na area');
}

Widget buildAnimatedOpacity(status){
  return AnimatedContainer(
    duration: Duration(seconds: 1),
    height: heightValue,
    child: AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: opacityvalue,
                child: Container(
                    padding: EdgeInsets.only(left: 5,right: 5),
                    decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [0.1,],
                                colors: [
                                  Color.fromRGBO(60, 100, 200, 0.5),

                                ],
                              ),
                          borderRadius: new BorderRadius.circular(8.0),
                        ),
                    child: ListView(
                            children:<Widget>[Column(children: <Widget>[
                              Elemento(item:status,name:''),
                              Atributo.buildAtributo(status),
                              Container(child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Image.asset('assets/images/water.png',fit: BoxFit.cover, height: 25,),
                                  Text('>>>>',style: TextStyle(color: Colors.white),),
                                   Image.asset('assets/images/fire.png',fit: BoxFit.cover, height: 25,),
                                  Text('>>>>',style: TextStyle(color: Colors.white),),
                                   Image.asset('assets/images/air.png',fit: BoxFit.cover, height: 25,),
                                  Text('>>>>',style: TextStyle(color: Colors.white),),
                                  Image.asset('assets/images/earth.png',fit: BoxFit.cover, height: 25,),
                                  Text('>>>>',style: TextStyle(color: Colors.white),),
                                
                              ],
                            ),                        
                          ),
                          Container(child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                            Image.asset('assets/images/water.png',fit: BoxFit.cover, height: 25,),
                            Text('≠',style: TextStyle(color: Colors.white,fontSize: 20),),
                            Image.asset('assets/images/air.png',fit: BoxFit.cover, height: 25,),
                              
                          ],
                          
                        ),),
                        Container(child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                            Image.asset('assets/images/fire.png',fit: BoxFit.cover, height: 25,),
                            Text('≠',style: TextStyle(color: Colors.white,fontSize: 20),),
                            Image.asset('assets/images/earth.png',fit: BoxFit.cover, height: 25,),    
                              
                          ],
                          
                            )
                          ,),

                          Container(
                            padding: EdgeInsets.all(5),
                            child:Text('v',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300),) ,),
                           
                          Container(
                            padding: EdgeInsets.all(5),
                            child:Text('Empates e elementos divergentes levam em consideração a força do seu signo, quanto mais próximo do mês, mais forte será!',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300),) ,)
                            ],
                          ),
                        ]
                    ),
                    ),
                     
              ),
  );
}

Widget buttonInfo(height){
  return Positioned(
              left: -10,
              top: (height - 150),
              child: RaisedButton(
                color: Colors.blue,
                elevation: 5,
                shape: new CircleBorder(),
                padding: new EdgeInsets.all(0.0),
                onPressed: () {
                    changeOpacity();
                },
                child: Icon(Icons.info,color: Colors.white,size: 30,)
              )
              
              );
}

Widget buttonAtualiza(){
  return RaisedButton(
          color: Colors.green,
          onPressed: ()=> attMonsters(),
          child: Text('Atualizar mapa da area',style:TextStyle(color: Colors.white) ,)
          );
}

Widget animationBattle(img,nome){
  return  Column(
              children: <Widget>[
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) => FractionalTranslation(
                            translation: animation.value,
                            child: AnimationBattle(img: img,nome: nome,),
                          ), 
                    ),
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) => FractionalTranslation(
                            translation: animation2.value,
                            child: AnimationBattle(img: imgBattle,nome: nameBattle,),
                          ), 
                    ),
                    ],
                  ),
                  AnimatedContainer(
                    height: exibedataBattle != false ? 318 : 0 ,
                    duration: Duration(seconds: 1),
                    child: exibedataBattle ? BattleInfoTable(currentUserId:'${widget.userId}',history:dataBattle,peerId:'$idOther',closeBattle:closeBattle) : Container()
                  )
                
              ],
            );
}
Widget buildStack(status,height,monstersAndPlayers){
    Size screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;

    appState = StateWidget.of(context).state;
    var status = appState.status;
    var img = appState.user.user_foto;
    var nome = appState.user.user_nome;
  return Stack(children: <Widget>[
            listView(context,monstersAndPlayers),
            buildAnimatedOpacity(status),
            buttonInfo(height),
                     
          ],
        );
}


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    appState = StateWidget.of(context).state;
    var status = appState.status;
    var img = appState.user.user_foto;
    var nome = appState.user.user_nome;
    return Stack(
      children: <Widget>[
        new Center(
              child: StateWidget.of(context).state.monsters['monstersAndPlayers'].isNotEmpty
              ? buildStack(status,height,StateWidget.of(context).state.monsters['monstersAndPlayers']) 
              : StateWidget.of(context).state.monsters['monstersAndPlayers'].isEmpty && isLoading == true 
                ?CircularProgressIndicator() 
                :buttonAtualiza()
            ),
         animationBattle(img,nome)
      ],
    );
  }
}


