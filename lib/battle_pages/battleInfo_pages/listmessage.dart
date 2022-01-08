import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ListMessages extends StatefulWidget {



  final String peerNome;
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final String idchallenged;
  final String battleHash;

  ListMessages({Key key, @required this.peerNome,@required this.peerId, @required this.peerAvatar,@required this.currentUserId,this.idchallenged,this.battleHash}) : super(key: key);

  @override
  _ListMessagesState createState() => _ListMessagesState(peerNome: peerNome,peerId: peerId, peerAvatar: peerAvatar,currentUserId: currentUserId,battleHash: battleHash,idchallenged:idchallenged);
}

class _ListMessagesState extends State<ListMessages> {

  final String peerNome;
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final String idchallenged;
  final String battleHash;

  _ListMessagesState({Key key, @required this.peerNome,@required this.peerId, @required this.peerAvatar,@required this.currentUserId,this.idchallenged,this.battleHash});

  final themeColor = Color(0xfff5a623);

  final primaryColor = Color(0xff203152);

  final greyColor = Color(0xffaeaeae);

  final greyColor2 = Color(0xffE8E8E8);

  var listMessage;

  File imageFile;

  bool isLoading;

  bool isShowSticker;

  String imageUrl;

  List userDocument;

  final TextEditingController textEditingController = new TextEditingController();

  final ScrollController listScrollController = new ScrollController();

  final FocusNode focusNode = new FocusNode();

 Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = false;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // StorageReference reference = FirebaseStorage.instance.ref().child('messages/$battleHash/$fileName');
    // StorageUploadTask uploadTask = reference.putFile(imageFile);
    // StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    // storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
    //   imageUrl = downloadUrl;
    //   setState(() {
    //     isLoading = false;
    //     onSendMessage(imageUrl, 1);
    //   });
    // }, onError: (err) {
    //   setState(() {
    //     isLoading = false;
    //   });

    // });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(battleHash)
          .collection(battleHash)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': widget.currentUserId,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      DateTime timestamp = DateTime.now();



    } else {

    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    var documentdata = document.data();
    if (documentdata['idFrom'] == widget.currentUserId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          documentdata['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                )
              : documentdata['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: Container(
                            padding: EdgeInsets.all(70.0),
                            child: Image.network(documentdata['content'],fit: BoxFit.fill,
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
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'images/${document['content']}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: Image.network(peerAvatar,fit: BoxFit.cover,
                          width: 35.0,
                          height: 35.0,
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
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                documentdata['type'] == 0
                    ? Container(
                        child: Text(
                          documentdata['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : documentdata['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: Container(
                                  padding: EdgeInsets.all(70.0),
                                  child: 
                                  Image.network(documentdata['content'],fit: BoxFit.cover,
                                    width: 200.0,
                                    height: 200.0,
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
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                               
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: new Image.asset(
                              'images/${documentdata['content']}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(documentdata['timestamp']))),
                      style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == widget.currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != widget.currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Firestore.instance.collection('users').document(widget.currentUserId).updateData({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          // Material(
          //   child: new Container(
          //     margin: new EdgeInsets.symmetric(horizontal: 1.0),
          //     child: new IconButton(
          //       icon: new Icon(Icons.face),
          //       onPressed: getSticker,
          //       color: primaryColor,
          //     ),
          //   ),
          //   color: Colors.white,
          // ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width);
    final double itemHeight = (size.height);
    return SizedBox(
      child: battleHash == ''
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(battleHash)
                  .collection(battleHash)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.documents;             
                  return ListView.builder(
                        key:Key(UniqueKey().toString()),
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                        reverse: true,
                        controller: listScrollController,
                    );
                }
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
        Expanded(child: buildListMessage(context)),
        buildInput()
    ],);
  }
}