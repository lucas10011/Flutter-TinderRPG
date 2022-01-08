import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_isekai/models/state.dart';
import 'dart:ui' as ui;

import 'package:my_isekai/services/state_widget.dart';

class Inventory extends StatefulWidget {
  final String id;
  Inventory({this.id});
  @override
  _InventoryState createState() => _InventoryState(id:id);
}
class _InventoryState extends State<Inventory> with SingleTickerProviderStateMixin {
   final String id;
  _InventoryState({this.id});

  StateModel appState;
  TabController tabController;
  Future<List> querySnapshotItens() async {
   final QuerySnapshot result  = await Firestore.instance.collection('userPositions').document('$id').collection('equipamento').orderBy('rarity', descending: true).getDocuments();
   final List<DocumentSnapshot> documents = result.documents;
   print('$id');
   return documents;
  }
  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 10);
  }

  buildColumn(data,img){
    return Column(children: <Widget>[
        buildListView(data,img)
      ]   
    );
  }

  buildListView(data,img){
      return data.length > 0 ?
      Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {

                        return buildCard(data[index],img);
                                                       
                    },
                    itemCount: data.length,
                  ),
        )
        :Center(child: Text('Nenhum item no inventario',style: TextStyle(color: Colors.black,fontSize: 40,fontWeight: FontWeight.w300),),);
  }

  buildCard(DocumentSnapshot item,img){
      var itemdata = item.data();
      String itemSlot = itemdata["slot"];
      String equipado = '';
      if(StateWidget.of(context).state.status['equipamento']['$itemSlot'] != null){
        if(StateWidget.of(context).state.status['equipamento']['$itemSlot']['idunique'] == item['idunique']){
          print('equipado');
          equipado = 'Equipado';  
      }
      
      }
      
    

    Color color;

      if (item['rarity'] == 1) {
        color =  Colors.green[900];

      }else if(item['rarity'] == 2){
        color =  Colors.yellow[700];

      }else{
        color =  Colors.orange[900]; 
      }
      return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: Image.asset('assets/images/$img.png',scale: 2,color: Colors.black),
                      title: Text("${item["name"]}",style: TextStyle(color: color),),
                      subtitle: buildAtributos(item,color),
                      onTap: () async{

                        Map<String,dynamic> equipamento ={
                          'agility':item['agility'],
                          'id':item['id'],
                          'idunique':item['idunique'],
                          'inteligence':item['inteligence'],
                          'name':item['name'],
                          'rarity':item['rarity'],
                          'slot':item['slot'],
                          'strenght':item['strenght']
                          };
                        
                         
                          await Firestore.instance.collection('userPositions').document('$id').collection('status').document('$id').updateData({
                          'equipamento.$itemSlot':equipamento
                        }).then((onValue){
                           setState(() {
                             StateWidget.of(context).state.status['equipamento']['$itemSlot'] = equipamento;
                           });
                           
                        });
                        
                        
                        
                      },
                    ),
                  ),
                  Text('$equipado',style: TextStyle(color: Colors.black),)
                ],
              ),
            
            ],
          ),
        );
}

  buildAtributos(item,color){

  List<Widget> widget = [];

 if(item['strenght'] != 0){
    widget.add(Text('Força: +${item['strenght']}',style: TextStyle(color: color,fontSize: 12)));
  }
  if(item['agility'] != 0){
    widget.add(Text('Agilidade: +${item['agility']}',style: TextStyle(color: color,fontSize: 12)));
  }
  if(item['inteligence'] != 0){
      widget.add(Text('Inteligencia: +${item['inteligence']}',style: TextStyle(color: color,fontSize: 12)));
  }

   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: widget );
  }




buildInventory(listaequipamentos,search){
    
    List<DocumentSnapshot> newList =  listaequipamentos.where((item) => item['slot'] == search).toList();
    return buildColumn(newList,search);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        bottom: TabBar(
          tabs: [
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/head.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
              icon: ImageIcon(
               AssetImage("assets/images/neck.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/body.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
               icon: ImageIcon(
               AssetImage("assets/images/cape.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/weapon.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/shield.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/hands.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/ring.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/legs.png",),
                    color: Colors.white,
               ),
            ),
            Tab(
                icon: ImageIcon(
               AssetImage("assets/images/feet.png",),
                    color: Colors.white,
               ),
            ),
          ],
          indicatorColor: Colors.white,
          controller: tabController,
        ),
      ),
      body: Center(
        child: Container(
          decoration:BoxDecoration(
            image: DecorationImage(image:new ExactAssetImage('assets/images/isekai.jpg'), fit: BoxFit.cover)             
          ),
          child: new BackdropFilter(
                filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
                decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
              child: 
              FutureBuilder(
                        future:querySnapshotItens(),
                        builder: (context,snapshot){
                                if(snapshot.hasError)
                                  print(snapshot.error);
                                return snapshot.hasData
                                ?TabBarView(
                                  controller: tabController,
                                  children: [
                                    buildInventory(snapshot.data,'head'),
                                    buildInventory(snapshot.data,'neck'),
                                    buildInventory(snapshot.data,'body'),
                                    buildInventory(snapshot.data,'cape'),
                                    buildInventory(snapshot.data,'weapon'),
                                    buildInventory(snapshot.data,'shield'),
                                    buildInventory(snapshot.data,'hands'),
                                    buildInventory(snapshot.data,'ring'),
                                    buildInventory(snapshot.data,'legs'),
                                    buildInventory(snapshot.data,'feet'),
                                  ],
                                )
                                :Container(height: double.infinity,);
                              }
                        )
              
              
            ),
          ),
        ),
      ),
    );
  }
}
