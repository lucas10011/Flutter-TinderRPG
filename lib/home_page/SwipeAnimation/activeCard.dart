import 'dart:math' as math; 

import 'package:my_isekai/home_page/SwipeAnimation/detail.dart';
import 'package:flutter/material.dart';


Widget cardDemo(
    Map item,
    double cardWidth,
    BuildContext context,
    Function removebattle,
    Function addbatle,
    int index
    ) {
  Size screenSize = MediaQuery.of(context).size;

  TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Colors.black,
      fontSize: 14.0,
    );
  // print("Card");
  return Column(
    children: <Widget>[
      new Dismissible(
        
          key: Key(UniqueKey().toString()), 
          crossAxisEndOffset: -0.3,
          confirmDismiss: (direction) async {
            // if (direction == DismissDirection.startToEnd) {
            //   await addbatle(item);
            //   return true;
            // } else if (direction == DismissDirection.endToStart) {
            //   await removebattle(item);
            //   return true;
            // }
            return false;
          },
          child: new GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(new PageRouteBuilder(
                          pageBuilder: (_, __, ___) => new DetailPage(item:item),
                        ));
                  },
                  child: new Card(
                    color: Colors.transparent,
                    elevation: 4.0,
                    child: new Container(
                      
                      alignment: Alignment.center,
                      width: screenSize.width / 1.05 + cardWidth,
                      height: screenSize.height / 1.35,
                     decoration: BoxDecoration(
                      image: DecorationImage(image:new ExactAssetImage('assets/images/old-map-light.jpg'), fit: BoxFit.cover)             
                      ),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                           Hero(
                              tag: '${item['id']}',
                              child: new Container(
                              width: screenSize.width / 1.05 + cardWidth,
                              height: screenSize.height / 1.8,
                              
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.only(
                                    topLeft: new Radius.circular(8.0),
                                    topRight: new Radius.circular(8.0)),
                               image: item['user_foto'] != ''
                               ?DecorationImage(image: new NetworkImage(item['user_foto']),fit: BoxFit.cover,)
                               :DecorationImage(image:new ExactAssetImage('assets/images/default.jpg'), fit: BoxFit.cover) 
                              ),
                            ),
                          ),
                          Column(children: <Widget>[
                           new Container(
                            child: Text(item['user_nome'],style: TextStyle(fontSize: 30,color: Colors.black,fontWeight: FontWeight.w300),), 
                            ),
                            new Container(
                              padding: EdgeInsets.all(5),
                            child: Text("${item['user_raca']}",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w300),), 
                            ),

                            new Container(
                              padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                              Text("${item['user_pontoforte']}",style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w300),),
                              Text("${item['user_pontofraco']}",style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w300),), 
                            ],)
                            ),
                          
                            
                           item['user_descricao'] != ''
                            ? new Container(
                                child: Text(item['user_descricao'],style: bioTextStyle,overflow: TextOverflow.ellipsis,),
                              )
                            : new Container(
                                child: Text('',style: bioTextStyle,),
                              ) 
                          ],),
                          
                        ],
                      ),
                    ),
                  ),
                ),
      ),
      new Container(
        width: screenSize.width / 1.2 + cardWidth,
        height:screenSize.height / 1.7 - screenSize.height / 2.2,
        alignment: Alignment.center,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
             new RaisedButton(
                color: Colors.red,
                elevation: 5,
                shape: new CircleBorder(),
                padding: new EdgeInsets.all(0.0),
                onPressed: () {
                  removebattle(item);
                },
                child:Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: ImageIcon(
                    AssetImage("assets/images/run.png",),
                          color: Colors.white,
                          size: 60,
                    ),
                  )
                
              ),
            new RaisedButton(
                color: Colors.green,
                elevation: 5,
                shape: new CircleBorder(),
                padding: new EdgeInsets.all(0.0),
                onPressed: () {
                  addbatle(item);
                },
                child: ImageIcon(
               AssetImage("assets/images/lutar.png",),
                    color: Colors.white,
                    size: 60,
               ),
              )
          ],
        ))
      
    ],
  );
}
