import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_isekai/battle_pages/battles.dart';
import 'package:my_isekai/home_page/SwipeAnimation/index.dart';
import 'package:my_isekai/inventario_pages/inventory.dart';
import 'package:my_isekai/loading.dart';
import 'package:my_isekai/maps_page/googlemaps.dart';
import 'package:my_isekai/models/equipamento.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/models/todo.dart';
import 'package:my_isekai/models/zodiacos.dart';
import 'package:my_isekai/option_page/option.dart';
import 'package:my_isekai/services/state_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
 bool _loadingVisible = false;
 
 GlobalKey _scaffold = GlobalKey();

  StateModel appState;
  int _selectedIndex = 0;
  Stream stream;
  
 
  @override
  void initState() {

    super.initState();
  }

 void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
        });
  }

  Widget _bottomnavigationWidget(){
  return BottomNavigationBar(
         type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people,color: Colors.white),
            title: Text('Perfil',style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,color: Colors.white),
            title: Text('Explorar',style: TextStyle(color: Colors.white),),
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.map,color: Colors.white),
            title: Text('Mapa',style: TextStyle(color: Colors.white),),
          ),
           BottomNavigationBarItem(
            icon: ImageIcon(
               AssetImage("assets/images/lutar.png",),
                    color: Colors.white,
               ),
            title: Text('Battles',style: TextStyle(color: Colors.white),),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.black
      );
}
 
 Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
   return false;// return true if the route to be popped
}



Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    UserPersonagem userLocal = appState?.user ?? null;


    final id = appState?.user?.id ?? '';
    final distance = appState?.user?.user_distance ?? 100;
    var monsters = appState?.monsters ?? '';

    List<Widget> _widgetOptions = <Widget>[
      MyHomePage(userId: id,loading:_changeLoadingVisible),
      CardDemo(userId: id,loading:_changeLoadingVisible,scaffoldstate:_scaffold,distance:distance,monsters: monsters,),
      GoogleMaps(user: userLocal,loading:_changeLoadingVisible,distance:distance,monsters: monsters,),
      ListBattles(loading:_changeLoadingVisible)
  ];
    return WillPopScope(
          onWillPop: _willPopCallback,
          child:LoadingScreen(
                inAsyncCall: _loadingVisible,
                child: Scaffold(
                   key: _scaffold,
                  body: Container(
                          decoration:BoxDecoration(
                          image: DecorationImage(image:new ExactAssetImage('assets/images/isekai.jpg'), fit: BoxFit.cover)             
                            ),
                          child:new BackdropFilter(
                  filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: new Container(
                    decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                    child: SafeArea(
                      child: AnimatedSwitcher(
                              duration:Duration(milliseconds: 400),
                              child:_widgetOptions.elementAt(_selectedIndex),
                              ),
                    ),
                  ),
                ),
            ),
            bottomNavigationBar: _bottomnavigationWidget(),
          ),
        ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  final String userId;
  final Function loading;
  MyHomePage({this.userId,this.loading});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);
 
  bool _myProfile = true;
  
  
  StateModel appState;
  SharedPreferences prefs;


  String id;
  String status;
  String photoUrl;

  String idprofile;
  String imageprofile;

  bool isLoading = false;
  File avatarImageFile;

  double screenDivideHeight = 2;
  double screenDivideWidth = 1.5;
  double heightImageDivide = 2.5;
  double paddingImage = 30;





TabController tabController;

@override
  void initState(){
  tabController = TabController(vsync: this, length: 3);
  tabController.addListener(_setActiveTabIndex);
  super.initState();
}

void _setActiveTabIndex() {
  if(tabController.index > 0){
    setState(() {
    screenDivideHeight = 3.5;
    screenDivideWidth = 1.75;
    heightImageDivide = 3.5;
    paddingImage = 100;
  });
  }else{
    setState(() {
    screenDivideHeight = 2.0;
    screenDivideWidth = 1.5;
    heightImageDivide = 2.5; 
    paddingImage = 30;
  });
  }
  
  print(tabController.index);
}

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

 void attStateModelFoto(link){
  try{
  setState(() {
    StateWidget.of(context).state.user.user_foto = link;
  });
  }catch(e){
    Flushbar(
          title: "Sign In Error",
          message: "$e",
          duration: Duration(seconds: 5),
        )..show(context);
  }
}


  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    // appState = StateWidget.of(context).state;
    // UserPersonagem userLocal = appState.user;
    // String fileName = userLocal.id;

    // List<firebase_storage.UploadTask> _uploadTasks = [];

    // StorageReference reference = FirebaseStorage.instance.ref().child('users/$fileName/$fileName');
    // StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    // StorageTaskSnapshot storageTaskSnapshot;
    // uploadTask.onComplete.then((value) {
    //   if (value.error == null) {
    //     storageTaskSnapshot = value;
    //     storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
    //       photoUrl = downloadUrl;
    //       Firestore.instance
    //           .collection('userPositions')
    //           .document(userLocal.id)
    //           .updateData({'d.user_foto':photoUrl}).then((data){
              
    //           attStateModelFoto(downloadUrl);
    //         setState(() {
    //           isLoading = false;
    //         });
      
    //       }).catchError((err) {
    //         setState(() {
    //           isLoading = false;
    //         });
    //           Flushbar(
    //           title: "Sign In Error",
    //           message: "$err",
    //           duration: Duration(seconds: 5),
    //         )..show(context);
         
    //       });
    //     }, onError: (err) {
    //       setState(() {
    //         isLoading = false;
    //       });
    //      Flushbar(
    //           title: "Sign In Error",
    //           message: "$err",
    //           duration: Duration(seconds: 5),
    //         )..show(context);
    //     });
    //   } else {
    //     setState(() {
    //       isLoading = false;
    //     });

    //     Flushbar(
    //           title: "Sign In Error",
    //           message: "${value.error}",
    //           duration: Duration(seconds: 5),
    //         )..show(context);
        
    //   }
    // }, onError: (err) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   Flushbar(
    //           title: "Sign In Error",
    //           message: "$err",
    //           duration: Duration(seconds: 5),
    //         )..show(context);

    // });
  }


Widget _buildCoverImage(Size screenSize) {
    return Container(
      decoration: BoxDecoration(
           image: DecorationImage(image:new ExactAssetImage('assets/images/treasuremap.jpg'), fit: BoxFit.cover)             
                      ),
    );
  }


Widget _buttons(userDistance,id){
 return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                Material(
                  elevation: 5,
                  shape: new CircleBorder(),
                   child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: primaryColor.withOpacity(0.5),
                          ),
                          onPressed: getImage,
                          splashColor: Colors.transparent,
                          highlightColor: greyColor,
                          iconSize: 40.0,
                        ),
                    ),
                SizedBox(height: 20,),
                Material(
                    elevation: 5,
                    shape: new CircleBorder(),
                     child: IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: primaryColor.withOpacity(0.5),
                            ),
                            onPressed: ()=> Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => Options(userDistance:userDistance),
                                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                transitionDuration: Duration(milliseconds: 400),
                              ),
                            ),
                            splashColor: Colors.transparent,
                            highlightColor: greyColor,
                            iconSize: 40.0,
                          ),
                ),
                SizedBox(height: 15,),
                GestureDetector(
                    onTap: ()=> Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (c, a1, a2) => Inventory(id:id),
                                transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                                transitionDuration: Duration(milliseconds: 400),
                              ),
                            ),
                    child: Container(
                    padding: const EdgeInsets.all(0.0),
                    width: 60,
                    height: 60,

                    decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white,             
                        ),
                     child: Image.asset('assets/images/backpack.png',width: 60,height: 60,)
                              
                  ),
                ),
              ],
            );
              
}

Widget _buildProfileImage() {
    Size screenSize = MediaQuery.of(context).size;
    appState = StateWidget.of(context).state;
    final foto = appState?.user?.user_foto ?? '';
    final id = appState?.user?.id ?? '';
    final userDistance = appState?.user?.user_distance ?? 0;
  return Center(
    child: ListView(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.only(left: paddingImage,right: paddingImage),
            height:screenSize.height / heightImageDivide,
            child: isLoading 
                      ?Container(
                        padding: EdgeInsets.all(20.0),
                        child:CircularProgressIndicator(
                        strokeWidth: 2.0,
                        ),
                      )
                      : foto != '' 
                          ? ClipRRect(
                            borderRadius: new BorderRadius.circular(40.0),
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
                                ),
                              )
                          : Icon(Icons.person, size: screenSize.height / 2.5,color: Colors.grey,)
                  ),

              _buttons(userDistance,id)
              
        ],
      ),
  );
              
  }



Widget _profileBody(Size screenSize,context){
   appState = StateWidget.of(context).state;
   UserPersonagem userLocal = appState.user;
   return Column(
          children: <Widget>[
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height:screenSize.height / screenDivideHeight,
                    child: Stack(children: <Widget>[
                    _buildCoverImage(screenSize),
                    _buildProfileImage(),
              ],
            ),
                  ),
              Expanded(
                child: TabBarView(
                    controller: tabController,
                    children: [
                      ProfileInfo(),
                      ProfileStats(),
                      ProfileDescricao(userLocal:userLocal),
                    ],
                  )
                ,)
            
          ],
        );
  
 }
  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
                )
              ],
              indicatorColor: Colors.white,
              controller: tabController,
            ),
          )
        ),
      body: SafeArea(
            child: Center(
            child: Container(
              width:(screenSize.width) ,
              child:_profileBody(screenSize,context),
            ),
          ),
      ),
    ); 
      
  }
}





class ProfileInfo extends StatefulWidget {

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {

  StateModel appState;
  bool _changeProfile = false;
  bool isLoading = false;
  String descricao;

  
  Map<String,Map<String,int>> level = {'level': {'1': 150, '2': 225, '3': 337, '4': 506, '5': 759, '6': 1139, '7': 1708, '8': 2562, '9': 3844, '10': 5766, '11': 8649, '12': 12974, '13': 19461, '14': 29192, '15': 43789, '16': 65684, '17': 98526, '18': 147789, '19': 221683, '20': 332525, '21': 498788, '22': 748182, '23': 1122274, '24': 1683411, '25': 2525116, '26': 3787675}}; 



Widget _buildFullName() {

    appState = StateWidget.of(context).state;
    final nome = appState?.user?.user_nome ?? '';
    final lvl = appState?.user?.user_level ?? '';

    TextStyle _nameTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w300,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Container(
            child: new Text(nome,overflow: TextOverflow.ellipsis, style: _nameTextStyle,),
            )
          ),
          Padding(
                     padding: const EdgeInsets.all(12.0),
                     child: Text("Lvl:$lvl",style: TextStyle(fontSize: 20),),
                   )
        
      ],
    );
  }


Widget _buildAtributoItem(atribute,value,int bonus,valueTextStyle){
  return Padding(
    padding: const EdgeInsets.only(right: 10,bottom:30.0,top:30,left: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
      Text('$atribute',style: valueTextStyle,),
      Row(
        children: <Widget>[
          Text('${value.toInt()}'),
         bonus != null ? bonus != 0 ?  Text('+$bonus',style: TextStyle(color: Colors.green[500]),) : Text('') : Text('')
        ],
      ),
    ],),
  );

}

  


Widget _buildAtributo(status) {
      int bonusStr = 0;
      int bonusAgi = 0;
      int bonusInt = 0;

     Equipamento equipamento  = Equipamento.fromJson(status['equipamento']);

    if(equipamento.weapon != null){
       bonusStr += equipamento.weapon['strenght'];
       bonusAgi += equipamento.weapon['agility'];
       bonusInt += equipamento.weapon['inteligence'];
    }
    if(equipamento.body != null){
       bonusStr += equipamento.body['strenght'];
       bonusAgi += equipamento.body['agility'];
       bonusInt += equipamento.body['inteligence'];
    }
    if(equipamento.cape != null){
       bonusStr += equipamento.cape['strenght'];
       bonusAgi += equipamento.cape['agility'];
       bonusInt += equipamento.cape['inteligence'];
    }
    if(equipamento.feet != null){
       bonusStr += equipamento.feet['strenght'];
       bonusAgi += equipamento.feet['agility'];
       bonusInt += equipamento.feet['inteligence'];
    }
    if(equipamento.head != null){
       bonusStr += equipamento.head['strenght'];
       bonusAgi += equipamento.head['agility'];
       bonusInt += equipamento.head['inteligence'];
    }
    if(equipamento.legs != null){
       bonusStr += equipamento.legs['strenght'];
       bonusAgi += equipamento.legs['agility'];
       bonusInt += equipamento.legs['inteligence'];
    }
    if(equipamento.neck != null){
       bonusStr += equipamento.neck['strenght'];
       bonusAgi += equipamento.neck['agility'];
       bonusInt += equipamento.neck['inteligence'];
    }

    if(equipamento.ring != null){
       bonusStr += equipamento.ring['strenght'];
       bonusAgi += equipamento.ring['agility'];
       bonusInt += equipamento.ring['inteligence'];
    }
    if(equipamento.shield != null){
       bonusStr += equipamento.shield['strenght'];
       bonusAgi += equipamento.shield['agility'];
       bonusInt += equipamento.shield['inteligence'];
    }

    TextStyle valueTextStyle = TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.grey,
      fontSize: 17.0,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
      _buildAtributoItem('Força',status['strenght'],bonusStr,valueTextStyle),
      _buildAtributoItem('Agilidade',status['agility'],bonusAgi,valueTextStyle),
      _buildAtributoItem('Inteligência',status['inteligence'],bonusInt,valueTextStyle),
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
Widget _buildTitulo(context){
Zodiaco signo =  new Zodiaco();
appState = StateWidget.of(context).state;
Map<String,dynamic> status = appState?.status ?? '';
var idzodiac = status['zodiac'];
final titulo = appState?.user?.user_titulo ?? '';
 return Column(children: <Widget>[
      Text('$titulo',style: TextStyle(fontSize: 17),),
      Text(signo.zodiac['$idzodiac'])
  ],
);
  
}

 Widget _buildElementItem(status,context) {

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
        _buildTitulo(context),
        _buildElementImage(status['elementsecondary']),
      ]
    );
  }

  Widget _buildElementContainer(status,screensize) {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child:_buildElementItem(status,context)  
    );
  }



Widget _buildStatusProfile(status,screenSize){
  return Column(children: <Widget>[
      _buildElementContainer(status,screenSize),
      _buildAtributo(status),
  ],);
}

Widget _buildXpBar(context,diference){

 return LinearProgressIndicator(value: diference, valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),backgroundColor: Colors.white,);
 
}

Widget _buildXpLvl(context,xpuser,levelup,Size screenSize){

 return Text("$xpuser/$levelup");
 
}

Widget _profileWidgets(Size screenSize,context){
    appState = StateWidget.of(context).state;
    Map status = appState?.status ?? '';

    final userlevel = appState?.user?.user_level ?? '';
    
    final levelup = level['level']['$userlevel'] != null ? level['level']['$userlevel'] : 999; 
    var xpuser = status['xp'];    
    var diference = (xpuser/ levelup);

  return Material(
        elevation: 5,
        child: Container(
          child: Column(
                    children: <Widget>[
                      _buildFullName(),
                      SizedBox(height: 2,),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                          _buildXpBar(context,diference),
                          _buildXpLvl(context,xpuser,levelup,screenSize),
                        ],),
                      ),
                      _buildStatusProfile(status,screenSize)
                    
                    ],
                  ),
        ),
  );
 
}


  @override
  Widget build(BuildContext context) {
   Size screenSize = MediaQuery.of(context).size;
    return _profileWidgets(screenSize,context);  
  }


}



class ProfileStats extends StatefulWidget {
  @override
  _ProfileStatsState createState() => _ProfileStatsState();
}

class _ProfileStatsState extends State<ProfileStats> {
  StateModel appState;


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
    appState = StateWidget.of(context).state;
    Map<dynamic, dynamic> equipamentos = appState.status;
    // List<Widget> equipado = [];
    // equipamentos.forEach((slot,equipamento){ 
    //     if(equipamento != null){ 
    //       equipado.add(buildEquip(equipamento));
    //     }
    //   }
    // );

    // List<Widget> widgets = equipamentos.map((equipamento) => new Text(equipamento['name'])).toList();
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



class ProfileDescricao extends StatefulWidget {
  final UserPersonagem userLocal;
  ProfileDescricao({this.userLocal});
  @override
  _ProfileDescricaoState createState() => _ProfileDescricaoState();
}

class _ProfileDescricaoState extends State<ProfileDescricao> {
  StateModel appState;
  bool isLoading = false;
  bool _changeProfile = false;
  String descricao;

  TextEditingController controllerDescricao = new TextEditingController();
  String currentRaca;
  String currentProfissao;
  String currentPontoForte;
  String currentPontoFraco;
  TextEditingController controllerIdade = new TextEditingController();

  List _racas =
  ["HUMANO", "NEKOS", "ELFO", "DWARF", "VAMPIRO",'ESPÍRITO','ANGELUS','NEPHILIM','DOGUINHO CARAMELO'];

  List<DropdownMenuItem<String>> _dropDownMenuItemsRacas;


    List _profissoes =
  ["Artista", "Bardo", "Caçador de recompensas", "Dama de Companhia", "Ferreiro", 'Taverneiro', 'Mercenário','Defensor'];


 List<DropdownMenuItem<String>> _dropDownMenuItemsProfissoes;


     List _pontosfortes =
  ["Otimismo", "Coragem", "Integridade", "Honestidade", "Humildade", "Generosidade", "Criatividade","Compaixão", "Humor"];


 List<DropdownMenuItem<String>> _dropDownMenuItemsPontosFortes;

     List _pontosfracos =
  ["Introvertido", "Obsessão", "Teimosia", "Pessimismo", "Desorganizado", "Preguiçoso", "Inseguro", "Sedentário", "Indeciso"];


 List<DropdownMenuItem<String>> _dropDownMenuItemsPontosFracos;
   

  List<DropdownMenuItem<String>> getDropDownMenuItems(list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String itemlist in list) {
      items.add(new DropdownMenuItem(
          value: itemlist,
          child: new Text(itemlist)
      ));
    }
    return items;
  }

  loadDropDownItemMyValues(){
    if(widget.userLocal.user_raca == null || widget.userLocal.user_raca == ''){
      currentRaca =  _dropDownMenuItemsRacas[0].value;
    }else{
      currentRaca =  widget.userLocal.user_raca;
    }

    if(widget.userLocal.user_profissao == null || widget.userLocal.user_profissao == ''){
      currentProfissao =  _dropDownMenuItemsProfissoes[0].value;
    }else{
      currentProfissao =  widget.userLocal.user_profissao;
    }

    if(widget.userLocal.user_pontoforte == null || widget.userLocal.user_pontoforte == ''){
      currentPontoForte =  _dropDownMenuItemsPontosFortes[0].value;
    }else{
      currentPontoForte =  widget.userLocal.user_pontoforte;
    }

    if(widget.userLocal.user_pontofraco == null || widget.userLocal.user_pontofraco == ''){
      currentPontoFraco =  _dropDownMenuItemsPontosFracos[0].value;
    }else{
      currentPontoFraco =  widget.userLocal.user_pontofraco;
    }

    if(widget.userLocal.user_descricao == null || widget.userLocal.user_descricao == ''){
      controllerDescricao = new TextEditingController(text:'');
    }else{
      controllerDescricao = new TextEditingController(text:widget.userLocal.user_descricao);
    }

    if(widget.userLocal.user_idade == null || widget.userLocal.user_idade == ''){
      controllerIdade = new TextEditingController(text:'0');
    }else{
      controllerIdade = new TextEditingController(text:widget.userLocal.user_idade);
    }
  

  }

 @override
  void initState() {
      _dropDownMenuItemsRacas = getDropDownMenuItems(_racas);   
      _dropDownMenuItemsProfissoes = getDropDownMenuItems(_profissoes);
      _dropDownMenuItemsPontosFortes = getDropDownMenuItems(_pontosfortes);   
      _dropDownMenuItemsPontosFracos = getDropDownMenuItems(_pontosfracos);

      loadDropDownItemMyValues();
    super.initState();
  }


void changedDropDownItemRaca(String selectedRaca) {
  print(selectedRaca);
    setState(() {
      currentRaca = selectedRaca;
    });
  }
void changedDropDownItemProfissao(String selectedProfissao) {
    setState(() {
      currentProfissao = selectedProfissao;
    });
  }

void changedDropDownItemPontoForte(String selectedPontoForte) {
    setState(() {
      currentPontoForte = selectedPontoForte;
    });
  }

void changedDropDownItemPontoFraco(String selectedPontoFraco) {
    setState(() {
      currentPontoFraco = selectedPontoFraco;
    });
  }
     

void updateDescricaoClass(){
  setState(() {
    StateWidget.of(context).state.user.user_descricao = controllerDescricao.text;
    StateWidget.of(context).state.user.user_raca = currentRaca;
    StateWidget.of(context).state.user.user_profissao = currentProfissao;
    StateWidget.of(context).state.user.user_pontoforte = currentPontoForte;
    StateWidget.of(context).state.user.user_pontofraco = currentPontoFraco;
    StateWidget.of(context).state.user.user_idade= controllerIdade.text;
  });
}


void handleUpdateData() async {
   appState = StateWidget.of(context).state;
   UserPersonagem userLocal = appState.user;
    changeStatus();
    updateDescricaoClass();
    setState(() {
      isLoading = true;
    });
   try{
      await Firestore.instance
            .collection('userPositions')
            .document(userLocal.id)
            .updateData({
              'd.user_descricao':controllerDescricao.text,
              'd.user_raca':currentRaca,
              'd.user_profissao':currentProfissao,
              'd.user_idade':controllerIdade.text,
              'd.user_pontoforte':currentPontoForte,
              'd.user_pontofraco':currentPontoFraco,
              });
    }catch(e){
      Flushbar(
              title: "Error",
              message: "$e",
              duration: Duration(seconds: 5),
            )..show(context);
    }
     
    setState(() {
      isLoading = false;
    });

  }

  void changeStatus(){
  if (_changeProfile == false){
    setState(() {
      _changeProfile = true;
    });
  }else{
    setState(() {
      _changeProfile = false;
    });
  }
}

 

  Widget _descricaoFormField(){
    Size screenSize = MediaQuery.of(context).size;

    TextStyle style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        );


  final raca =  new DropdownButton(
              iconSize: 0,
              value: currentRaca,
              items: _dropDownMenuItemsRacas,
              onChanged: changedDropDownItemRaca,
            );


  final profissao = new DropdownButton(
          isExpanded: true,
          iconSize: 0,
          value: currentProfissao,
          items: _dropDownMenuItemsProfissoes,
          onChanged: changedDropDownItemProfissao,
        );
       
  final idade = TextFormField(
    maxLength: 4,
    keyboardType: TextInputType.number,
    autofocus: false,
    controller: controllerIdade,
    inputFormatters: <TextInputFormatter>[
      WhitelistingTextInputFormatter.digitsOnly
    ],
    decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15, bottom: 16, top: 11, right: 15),
                counterText: "",
              ),
    
  );


  final pontoforte = new DropdownButton(
          isExpanded: true,
          iconSize: 0,
          value: currentPontoForte,
          items: _dropDownMenuItemsPontosFortes,
          onChanged: changedDropDownItemPontoForte,
        );


  final pontofraco = new DropdownButton(
          isExpanded: true,
          iconSize: 0,
          value: currentPontoFraco,
          items: _dropDownMenuItemsPontosFracos,
          onChanged: changedDropDownItemPontoFraco,
        );

  final descricaoInput = TextField(
          maxLength: 450,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          controller:controllerDescricao,
          onChanged: (value) {
                      descricao = value;
                    },
          decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            counterText: "",
          ),
          style: TextStyle(fontSize: 20,color: Colors.black),
        );




    return ListView(
        children: <Widget>[
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
          ],),
              ),
            )
          ],
        ),
               
          
          Column(
            children:<Widget> [
               Text("Descrição:",style: style,),
              descricaoInput
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                color: Colors.black,
                onPressed: changeStatus,
                child: Text('Cancelar',style:TextStyle(color: Colors.white) ,)
                ,),
            RaisedButton(
                color: Colors.black,
                onPressed: handleUpdateData,
                child: Text('Salvar',style:TextStyle(color: Colors.white) ,)
                ,),
           
          ],)
        ],
    );
  }

Widget _descricaoWidget(){
   Size screenSize = MediaQuery.of(context).size;
   appState = StateWidget.of(context).state;
   UserPersonagem user = appState?.user ?? null;
     
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
    "${user.user_raca}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final profissao = Text(
    "${user.user_profissao}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final idade = Text(
    "${user.user_idade}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

 final pontoforte = Text(
    "${user.user_pontoforte}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final pontofraco= Text(
    "${user.user_pontofraco}",
    textAlign: TextAlign.center,
    style: bioTextStyle);

  final descricao= Text(
    "${user.user_descricao}",
    textAlign: TextAlign.center,
    style: bioTextStyle);



    return GestureDetector(
        onDoubleTap: changeStatus,
        child: Container(
        height: (screenSize.height/2.5),
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(8.0),
        child: ListView(children: <Widget>[
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
          
        ],)
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return _changeProfile ? _descricaoFormField() : _descricaoWidget();
  }
}