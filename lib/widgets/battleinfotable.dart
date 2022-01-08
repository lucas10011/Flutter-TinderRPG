
import 'package:flutter/material.dart';

class BattleInfoTable extends StatefulWidget {
  final dynamic history;
  final String currentUserId;
  final String peerId;
  final Function closeBattle;

  BattleInfoTable({this.history,this.currentUserId,this.peerId,this.closeBattle});

  @override
  _BattleInfoTableState createState() => _BattleInfoTableState();
}

class _BattleInfoTableState extends State<BattleInfoTable> with SingleTickerProviderStateMixin {


  TabController tabController;

void initState(){
  tabController = TabController(vsync: this, length: 2);
  super.initState();
}


  @override
  Widget build(BuildContext context) {
    return _buildBody(widget.history);  
  }


_buildBody(history){
  return Scaffold(
    appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // here the desired height
          child: AppBar(
            backgroundColor: Colors.black,
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text('Resultado'),
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
          )
        ),
    body: TabBarView(
          controller: tabController,
          children: [
            _buildResult(history),
            BattleInfoHistory(history:history,currentUserId: widget.currentUserId,peerId: widget.peerId,),
          ],
        ),
  floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.black,
    child: Icon(Icons.close),
    onPressed: widget.closeBattle,),
  );
}
Widget _buildResult(history){
  Text textXp = Text(
    "Recebeu ",
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
    Text xpWin = Text(
    "+${history['resultbattle'][0]['xp']} de xp ",
    style:TextStyle(
      fontSize: 20,
      color: Colors.green,
      fontWeight: FontWeight.w300));
    
    Text xpLose = Text(
    "-${history['resultbattle'][0]['xp']} de xp  ",
    style:TextStyle(
      fontSize: 20,
      color: Colors.red,
      fontWeight: FontWeight.w300));

  return Container(
      decoration: BoxDecoration(
           image: DecorationImage(image:new ExactAssetImage('assets/images/old-map-light.jpg'), fit: BoxFit.cover)             
                      ),
    child: ListView(
      children: <Widget>[
        Column(
        
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
          SizedBox(height: 10,),
          history['${widget.currentUserId}']['result'] ? textXp : textDerrotado,
          history['${widget.currentUserId}']['result'] ? xpWin : xpLose,
          SizedBox(height: 20,),
          buildDrop(history['resultbattle'][0]['drop']),
        ],)
    
      // _buildComparacaoZodiac(history),
      
    ],),
  );
}


buildDrop(drop){
  //  var drop = [{'inteligence': 4, 'name': 'Kodai wand', 'id': 781, 'slot': 'weapon', 'strenght': 6, 'agility': 5, 'idunique': 1575727398, 'rarity': 3}];
  TextStyle style;
  Color colorRarity;
  

  List<Widget> widget = [
    ];


  if (drop != null){
    widget.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
      Image.asset('assets/images/drop.jpg',fit: BoxFit.cover, height: 50,),
      Text('Drop:'),
      ]));
    switch (drop[0]['rarity']) {
    case 1:
      style = TextStyle(color: Colors.green[900]);
      colorRarity = Colors.green[900];
      break;
    case 2:
      style = TextStyle(color: Colors.yellow[700]);
      colorRarity = Colors.yellow[700];
      break;
    case 3:
       style = TextStyle(color: Colors.orange[900]);
       colorRarity = Colors.orange[900];
      break;
  }
  TextStyle styleTitulo = TextStyle(
    color: colorRarity,
    fontSize: 20,
    shadows: [
            Shadow(
                blurRadius: 15.0,
                color: colorRarity,
                offset: Offset(5.0, 5.0),
                ),
            ],
    );  

    widget.add(Image.asset('assets/images/${drop[0]['slot']}.png',height: 25,color: Colors.black),);
    widget.add(Text('${drop[0]['name']}',style: styleTitulo));

  if(drop[0]['strenght'] != 0){
    widget.add(Text('Força: +${drop[0]['strenght']}',style: style,));
  }
  if(drop[0]['agility'] != 0){
    widget.add(Text('Agilidade: +${drop[0]['agility']}',style: style));
  }
  if(drop[0]['inteligence'] != 0){
      widget.add(Text('Inteligencia: +${drop[0]['inteligence']}',style: style));
  }
   
        

}else{
  widget.add(Container());
}
  



   return Column(children: widget );
}


}


class BattleInfoHistory extends StatelessWidget {
  final dynamic history;
  final String currentUserId;
  final String peerId;

  BattleInfoHistory({this.history,this.currentUserId,this.peerId});

  final TextStyle styleletter = TextStyle(color: Colors.black,fontSize: 12);
  final TextStyle styleletterwon = TextStyle(color: Colors.green[600],fontSize: 30);
  final TextStyle styleletterlose = TextStyle(color: Colors.red[600],fontSize: 30);


Widget _buildComparacao(history,field){

  if(history['$currentUserId']['$field']){
    return Text('>',style: styleletterwon,);
  }else{
    return Text('<',style: styleletterlose,);
  }
}

_buildComparacaoZodiac(history){

  TextStyle stylezodiac = TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: Colors.black);

    if(history['$currentUserId']['zodiac'] < history['$peerId']['zodiac']){
      return Text('Você está mais próximo do mês do seu zodíaco o que lhe garante vantagem nos empates e elementos divergentes',style: stylezodiac);
    }else if (history['$currentUserId']['zodiac'] == history['$peerId']['zodiac']){
        return Text('');
    }else{
      return  Text('O inimigo esta mais próximo do zodíaco, garantindo vantagem em empates e elementos divergentes',style: stylezodiac);
    }
    
     
}

_buildElementImage(int value,String type){
  TextStyle elementstyle = TextStyle(fontStyle: FontStyle.italic,fontSize: 10,color: Colors.black);
  switch(value){
    case 0:
      return Column(
        children: <Widget>[
          Image.asset('assets/images/water.png',fit: BoxFit.cover, height: 40,),
          Text('$type',style:elementstyle)
        ],
      );
      break;
    case 1:
      return Column(
        children: <Widget>[
          Image.asset('assets/images/fire.png',fit: BoxFit.cover, height: 40,),
          Text('$type',style:elementstyle)
        ],
      );
      break;
    case 2:
      return Column(
        children: <Widget>[
          Image.asset('assets/images/earth.png',fit: BoxFit.cover, height: 40,),
          Text('$type',style:elementstyle)
        ],
      );
      break;
    case 3:
      return Column(
        children: <Widget>[
          Image.asset('assets/images/air.png',fit: BoxFit.cover, height: 40,),
          Text('$type',style:elementstyle)
        ],
      );
      break;
  }
}


_buildCircle(stat,color){
return OutlineButton(
                    borderSide: BorderSide(color: color),
                    shape: CircleBorder(),
                    
                    child: Text('$stat',style: styleletter,),
                    onPressed: () {   
                    },
                  );

}

_buildDice(){

  Text text;

  if (history['dice'] < 10){
    var porcentagem =  (10 - history['dice']) * 10;
    text = Text("Tirou ${history['dice']} nos dados, perdendo $porcentagem% nos atributos ");
  }else if(history['dice'] > 10){
    var porcentagem = (history['dice'] - 10) * 10;
    text = Text("Tirou ${history['dice']} nos dados, ganhando $porcentagem% nos atributos ");
  }else{
    text = Text("Tirou ${history['dice']} nos dados, nenhum bonus aplicado");
  }
  

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children:<Widget>[
      ImageIcon(
        AssetImage("assets/images/dice.png",),
            color: Colors.white,
            size: 50,
        ),
      text,
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
           image: DecorationImage(image:new ExactAssetImage('assets/images/old-map-light.jpg'), fit: BoxFit.cover)             
                      ),
      child: ListView(children: <Widget>[
                    history['dice'] != false ? _buildDice():Container(),
                     
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                    _buildCircle('${history[currentUserId]['strenght']}',Colors.red),
                    _buildComparacao(history,'resultstrenght'),
                    _buildCircle('${(history[peerId]['strenght']).toInt()}',Colors.red),
                      ]
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[

                    _buildCircle('${history[currentUserId]['agility']}',Colors.green),
                    _buildComparacao(history,'resultagility'),
                    _buildCircle('${(history[peerId]['agility']).toInt()}',Colors.green),         

                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[

                    _buildCircle('${history[currentUserId]['inteligence']}',Colors.blue),
                    _buildComparacao(history,'resultinteligence'),
                    _buildCircle('${(history[peerId]['inteligence']).toInt()}',Colors.blue),         

                  ],),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                    _buildElementImage(history['$currentUserId']['elementprimary'],'Pri'),
                    history['$currentUserId']['elementprimaryresult'] ? Text('>',style: styleletterwon,) : Text('<',style: styleletterlose,),
                    _buildElementImage(history['$peerId']['elementprimary'],'Pri'),
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                    _buildElementImage(history['$currentUserId']['elementsecondary'],'Sec'),
                    history['$currentUserId']['elementsecondaryresult'] ? Text('>',style: styleletterwon,) : Text('<',style: styleletterlose,),
                      _buildElementImage(history['$peerId']['elementsecondary'],'Sec'),
                  ],),
                _buildComparacaoZodiac(history), 

                  
              ]
            ,),
    );
  }
}