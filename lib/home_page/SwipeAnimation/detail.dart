import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';
import 'package:my_isekai/models/equipamento.dart';
import 'package:my_isekai/models/otherUser.dart';
import 'package:my_isekai/models/zodiacos.dart';

class DetailPage extends StatefulWidget {
  final Map item;
  const DetailPage({Key key, this.item}) : super(key: key);
  @override
  _DetailPageState createState() => new _DetailPageState(item: item);
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  Map item;
  _DetailPageState({this.item});
 

  TabController tabController;

  Future status;

  double screenDivideHeightImage = 1.5;
  double screenDivideHeightProfile = 3.5;
  double paddingImage = 30;
  double radiusImage = 0;

  void initState() { 
    super.initState();
     tabController = TabController(vsync: this, length: 3);
      tabController.addListener(_setActiveTabIndex);
     status = getStatusOther();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

void _setActiveTabIndex() {
  if(tabController.index > 0){
    setState(() {
    screenDivideHeightImage = 3.5;
    screenDivideHeightProfile = 1.5;
    radiusImage = 150;
  });
  }else{
    setState(() {
    screenDivideHeightImage = 1.5;
    screenDivideHeightProfile = 3.5;
    radiusImage = 0;
  });
  }
  
  print(tabController.index);
}

Future getStatusOther() async {
    var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'getStatusUser'); // replace 'functionName' with the name of your function
                var response = await callable.call(<String, dynamic>{
                    "idOther": item['id'],
                  }).catchError((onError) {
                });

            var result = response.data;
            print(result);
            return result;
}


buildFoto(foto){
    Size screenSize = MediaQuery.of(context).size;
   return foto != '' 
    ? new ClipRRect( 
      borderRadius: new BorderRadius.circular(radiusImage),
      child:Image.network(foto,fit: BoxFit.fill,
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
      ),)     
    : Icon(Icons.person, size: screenSize.height/2.5,color: Colors.grey,);
}



  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double timeDilation = 0.7;
    //print("detail");
    return new Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0), // here the desired height
          child: AppBar(
            backgroundColor: Colors.black,
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(''),
                ),
                Tab(
                  child: Text(''),
                ),
                Tab(
                  child: Text(''),
                ),
              ],
              indicatorColor: Colors.white,
              controller: tabController,
            ),
          )
        ),
      body: new Container(
        height: double.infinity,
          decoration:BoxDecoration(
                      image: DecorationImage(image:new ExactAssetImage('assets/images/isekai.jpg'), fit: BoxFit.cover)             
                        ),

          child: new Hero(
            tag: '${item['id']}',
            child: new Card(
              color: Colors.transparent,
              child: new Container(
                decoration: BoxDecoration(
           image: DecorationImage(image:new ExactAssetImage('assets/images/old-map-light.jpg'), fit: BoxFit.cover)             
                      ),
                
                child:SingleChildScrollView(
                  child: Column(children: <Widget>[
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        height: screenSize.height/screenDivideHeightImage,
                        width: screenSize.width,
                        child: buildFoto(item['user_foto']),       
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        height: screenSize.height/screenDivideHeightProfile,
                        child: FutureBuilder(
                                  builder: (context, snapshot) {
                                  if(snapshot.hasError)
                                  print(snapshot.error);
                                  return snapshot.hasData
                                    ?TabBarView(
                                      controller: tabController,
                                      children:[
                                          ProfileOtherInfo(other:item,status:snapshot.data),
                                          ProfileOtherStats(equipamentos:snapshot.data['equipamento']),
                                          BioOther(item: item,)
                                      ]
                                    )
                                    
                                    :Container(height: 16,child: Text('Carregando informações...'),);
                                  },
                                  future:status
                                ),
                      )
                      
                   

                  ],),
                )
              ),
            ),
          ),
        ),
      );
    
  }
}



class ProfileOtherInfo extends StatefulWidget {
  final Map other;
  final Map status;
  ProfileOtherInfo({this.other,this.status});
  @override
  _ProfileOtherInfoState createState() => _ProfileOtherInfoState(other:other,status: status);
}

class _ProfileOtherInfoState extends State<ProfileOtherInfo> {
   Map other;
   Map status;
  _ProfileOtherInfoState({this.other,this.status});

Widget _buildFullName() {

    TextStyle _nameTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w300,
    );

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Container(
              child: new Text("${other['user_nome']}",overflow: TextOverflow.ellipsis, style: _nameTextStyle,),
              )
            ),
            Padding(
                       padding: const EdgeInsets.all(12.0),
                       child: Text("Lvl:${other['user_level']}",style: TextStyle(fontSize: 20),),
                     )
          
        ],
      ),
    );
  }


Widget _buildAtributoItem(atribute,valueTextStyle){
  return Padding(
    padding: const EdgeInsets.only(right: 10,bottom:10.0,top:10,left: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
      Text('$atribute',style: valueTextStyle,),
      Text('???')
    ],),
  );

}

  


Widget _buildAtributo() {

    TextStyle valueTextStyle = TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.black,
      fontSize: 17.0,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
      _buildAtributoItem('Força',valueTextStyle),
      _buildAtributoItem('Agilidade',valueTextStyle),
      _buildAtributoItem('Inteligência',valueTextStyle),
    ],);

  }


 _buildElementImage(int value){
  switch(value){
    case 0:
      return Image.asset('assets/images/water.png',fit: BoxFit.cover, height: 50,);
      break;
    case 1:
      return Image.asset('assets/images/fire.png',fit: BoxFit.cover, height: 50,);
      break;
    case 2:
      return Image.asset('assets/images/earth.png',fit: BoxFit.cover, height: 50,);
      break;
    case 3:
      return Image.asset('assets/images/air.png',fit: BoxFit.cover, height: 50,);
      break;
  }
}
Widget _buildTitulo(){
Zodiaco signo =  new Zodiaco();
 return Column(children: <Widget>[
      Text('${other['user_titulo']}',style: TextStyle(fontSize: 17),),
       Text(signo.zodiac['${status['zodiac']}'])
  ],
);
  
}

 Widget _buildElementItem() {

    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildElementImage(status['elementprimary']),
        _buildTitulo(),
        _buildElementImage(status['elementsecondary']),
      ]
    );
  }

  Widget _buildElementContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child:_buildElementItem()  
    );
  }



Widget _buildStatusProfile(){
  return Column(children: <Widget>[
      _buildElementContainer(),
      _buildAtributo(),
  ],);
}


Widget _profileWidgets(){
  return Column(
            children: <Widget>[
              _buildFullName(),
              SizedBox(height: 2,),
              _buildStatusProfile()
            
            ],
          );
 
}


  @override
  Widget build(BuildContext context) {
    return _profileWidgets();  
  }


}



class ProfileOtherStats extends StatefulWidget {
  final Map equipamentos;
  ProfileOtherStats({this.equipamentos});
  @override
  _ProfileOtherStatsState createState() => _ProfileOtherStatsState(equipamentos:equipamentos);
}

class _ProfileOtherStatsState extends State<ProfileOtherStats> {
 final Map equipamentos;
  _ProfileOtherStatsState({this.equipamentos});

Widget buildEquip(equipamento,slot){
  Color color;
  String name;
  TextStyle style;
    if(equipamento != null){
      name = equipamento['name'];
      if (equipamento['rarity'] == 1) {
        color =  Colors.green[900];

      }else if(equipamento['rarity'] == 2){
        color =  Colors.yellow[700];

      }else{
        color =  Colors.orange[900]; 
      }
        style = TextStyle(
        color: color,
        fontSize: 15,
        shadows: [
                Shadow(
                    blurRadius: 15.0,
                    color: color,
                    offset: Offset(5.0, 5.0),
                    ),
                ],
      );
    }else{
      name = 'Desequipado';
      color =  Colors.grey[400]; 
       style = TextStyle(
        color: color,
        fontSize: 15,
        shadows: [
                Shadow(
                    blurRadius: 15.0,
                    color: color,
                    offset: Offset(5.0, 5.0),
                    ),
                ],
      );
    }


  return Card(
         child: ListTile(
              leading: Image.asset('assets/images/$slot.png',scale: 2,color: Colors.black,height: 40,),
              title: Text("$name",style: style,),
              subtitle: equipamento != null ? buildAtributos(equipamento,color) : Container(),
              onTap: null,
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


  @override
  Widget build(BuildContext context) {

    return ListView(children:<Widget>[
      buildEquip(equipamentos['head'],'head'),
      buildEquip(equipamentos['neck'],'neck'),
      buildEquip(equipamentos['body'],'body'),
      buildEquip(equipamentos['cape'],'cape'),
      buildEquip(equipamentos['weapon'],'weapon'),
      buildEquip(equipamentos['shield'],'shield'),
      buildEquip(equipamentos['hands'],'hands'),
      buildEquip(equipamentos['ring'],'ring'),
      buildEquip(equipamentos['legs'],'legs'),
      buildEquip(equipamentos['feet'],'feet'),   

    ]);
  }
}


class BioOther extends StatelessWidget {
  final Map item;
  BioOther({this.item});
  
final TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
     ); 


Widget _descricaoWidget(){
     OtherUser otherUser = OtherUser.otherfromDocument(item);

     TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w300,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

  TextStyle style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.w300,
      fontSize: 15,
    );

  final raca = Text(
    "${otherUser.user_raca}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final profissao = Text(
    "${otherUser.user_profissao}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final idade = Text(
    "${otherUser.user_idade}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

 final pontoforte = Text(
    "${otherUser.user_pontoforte}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final pontofraco= Text(
    "${otherUser.user_pontofraco}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final descricao= Text(
    "${otherUser.user_descricao}",
    textAlign: TextAlign.center,
    style: bioTextStyle);



    return ListView(children: <Widget>[
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Text("Raça:",style: style,),
              raca,
            ]),
          ),
           
          Row(children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                Text("Idade:",style: style,),
                idade,
                SizedBox(height: 15,),
                Text("Ponto Forte:",style: style,),
                pontoforte,
                ],),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                Text("Profissão:",style: style,),
                profissao,
                SizedBox(height: 15,),
                Text("Ponto Fraco:",style: style,),
                pontofraco,
                ],
              ),
              ),
            )
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Text("Descrição:",style: style,),
              descricao,
            ]),
          ),
          
        ],);
  }


@override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(8.0),
        child: _descricaoWidget(),
      );
  }
}