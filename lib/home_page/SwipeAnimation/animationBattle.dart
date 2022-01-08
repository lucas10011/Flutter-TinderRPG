
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';





class AnimationBattle extends StatelessWidget {
    String nome;
    String img;
AnimationBattle({this.nome,this.img});
  @override
    

  TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Colors.grey[300],
      fontSize: 14.0,
    );

  Widget build(BuildContext context) {
     Size screenSize = MediaQuery.of(context).size;
     
    return new AnimatedContainer(
                      duration: Duration(seconds: 1),
                      width: screenSize.width/2.0,
                      height: screenSize.height / 2.2,
                      color: Colors.blue,
                      
                      child: Column(
                        children: <Widget>[
                          img != ''
                          ?
                          new ClipRRect(
                            borderRadius: new BorderRadius.circular(0.0),
                            child:Image.network(img,fit: BoxFit.cover,
                                    height: screenSize.height / 2.4,
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
                            :Container(color: Colors.white,height: screenSize.height/2.4,child: Icon(Icons.person, size: screenSize.height / 3.75,color: Colors.grey,),),
                            Text(nome,style:TextStyle(color: Colors.white),)
                        ],
                        
                      ),
                    );
  
  }
}


