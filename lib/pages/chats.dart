import 'package:agrilease/login_api.dart';
import 'package:agrilease/pages/calender_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
// import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
// import 'package:scrollable_clean_calendar/utils/enums.dart';
// import 'package:scrollable_clean_calendar/utils/extensions.dart';



class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {

Future<dynamic> someFunction()async{
  
try {
  print("someFunction");
  Map<String, dynamic> data = await Chats().chatRoomsIDs(FireBaseAuthentication.emailID);
  print("ChatsPage SomeFunction var data: $data");
  return data;
} catch (e) {print("ChatsPage SomeFunction error: $e");}
  }

@override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.white, title: Text(AppLocalizations.of(context)!.tagChat, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),), backgroundColor : Colors.green[300],),
      body: FutureBuilder(future: someFunction(), builder: (context, snapShot){late dynamic Data; try{ Data =  snapShot.data ; print("Data runtimeType: ${Data.runtimeType} Data = '$Data'");}catch(e){print(e);}
        if(snapShot.hasData){ //snapShot.hasData
          return ChatList(data: Data);
          
          
          }
        else{return Center(child: Text(AppLocalizations.of(context)!.tagChatLoadingMSG, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),),);}
         }),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.data,
  });

  final  Map<String, dynamic>  data;
  
  @override
  Widget build(BuildContext context) {
    print("ChatsList var data: $data runtime: ${data.runtimeType} " );
    final List dataList = data.values.toList();
    final List roomIDList = data.keys.toList();
    return Container(color: Colors.white,
      child: ListView.separated( separatorBuilder: (context, sep){return const Divider( indent: 15, endIndent: 15, height: 1, );}, itemCount:data.length, 
      itemBuilder: (context, index){return ChatUserBox(roomID: roomIDList[index], Data: dataList[index], index:index );},),
    );// Data.length  //ListView.builder( itemCount: Data.length, itemBuilder: (context, index){return ChatUserBox(Data: Data, index:index ) ;  });
  }
}

class ChatUserBox extends StatelessWidget {
  const ChatUserBox({
    super.key,
    required this.Data,
    required this.roomID,
    required this.index
  });
  final String roomID;
  final String Data; //Map<String, dynamic>
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context){return ChatSection(roomID: roomID, reciverEmail: Data,);}));}, 
    child: Container(padding: const EdgeInsets.all(20), child: Row(children: [const Padding(padding: EdgeInsets.only(right:10), child: InkWell(child: Icon(size: 40, Ionicons.person_circle_outline),)),   Text(Data)],  )));
  }
}


class ChatSection extends StatefulWidget {final String roomID; final String reciverEmail;
  const ChatSection({super.key, required this.roomID, required this.reciverEmail });
//CleanCalendarController get getCalendarController{return calendarController;}

static final CleanCalendarController calendarController = CleanCalendarController(initialDateSelected: DateTime.now(), endDateSelected: DateTime.now(), minDate: DateTime.now(), maxDate: DateTime.now().add(const Duration(days: 31)));

  @override
  State<ChatSection> createState() => _ChatSectionState( );
}

class _ChatSectionState extends State<ChatSection> {
final TextEditingController _messageController = TextEditingController();

  Widget _someWidget(){return StreamBuilder(stream: Chats().getMessage(widget.roomID, widget.reciverEmail )  , builder:(context , final snapshot){
    if(snapshot.connectionState == ConnectionState.waiting){return const Center(child: Text("Start a chat to connect and discuss further", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),);}
    
    if(snapshot.hasData){return ListView(children: 
    
      snapshot.data!.docs.map((e){
      final data = e.data() as  Map<String, dynamic>; 
      print("e: ${snapshot.data!.docs}");
      if(data["message"]!=null){  return messageBox(e.data());  }else{  return scheduleBox(e.id, e.data(), widget.roomID); }  }    ).toList(), ); }


    else{return const Center(child: Text("Error", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),);}
    
  }  ,);}

Widget scheduleBox(String docID, dynamic doc, String chatRoomID, ){
  print("docID: $docID doc: $doc");
  doc as Map<String, dynamic>;
  AlignmentGeometry alignment = Alignment.centerRight;  
  final Timestamp minDate = doc["minDate"] as Timestamp;
  final Timestamp maxDate = doc["maxDate"] as Timestamp;
  final bool? decision = doc["decision"];
  final String? productID = doc["productID"];
  final String? name = doc["name"];
  final String? image = doc["image"];
  final String? price = doc["price"];
  final String? senderEmail = doc["senderEmail"];
  print("senderEmail: $senderEmail, FireBaseAuthentication.emailID: ${FireBaseAuthentication.emailID}");
  print("decision: $decision, runtimeType: ${decision.runtimeType}");
  final List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  late Color? color;
  late Radius bottomLeftTeardrop;
  late Radius bottomRightTeardrop;
  Radius specialBottomRight = const Radius.circular(15);
  Radius specialBottomLeft  = const Radius.circular(15);
  
  Future<void> isAccepted(String? productID, bool value)async{
    if(productID == null){return ;}
    if(await CalenderTools.instance.isColliding(productID, minDate.toDate(), maxDate.toDate())){return ;}
    print("chatRoomID: $chatRoomID, docID: $docID, value: $value");
    await Chats().sendScheduleDecision(chatRoomID, docID, value);
    if(!value){return ;}
    await CalenderTools.instance.setBookingDate(productID, minDate.toDate(), maxDate.toDate());
  }

  
  String date  = DateFormat("dd/MM").format(doc['timeStamp'].toDate()).toString();
  String dateTitle = "";
  bool isDateChanged = false;
  if(date !=previousMsgTime){ isDateChanged = true; previousMsgTime=date; dateTitle= date;}
  print("today: ${DateFormat("dd/MM").format(Timestamp.now().toDate())}, date: ${date}");
  if(DateFormat("dd/MM").format(Timestamp.now().toDate().subtract(const Duration(days: 1))) == date){dateTitle = "yesterday";}
  if(DateFormat("dd/MM").format(Timestamp.now().toDate()) == date){dateTitle = "Today";}  


  if(doc["reciverID"]==widget.reciverEmail){  alignment = Alignment.centerRight; color = Colors.grey[200]; bottomLeftTeardrop = const Radius.circular(20) ; bottomRightTeardrop = const Radius.circular(0); specialBottomRight = const Radius.circular(0); }else{alignment = Alignment.centerLeft; color = Colors.grey[200]; bottomLeftTeardrop = const Radius.circular(0) ; bottomRightTeardrop = const Radius.circular(20); specialBottomLeft = const Radius.circular(0);}  
  return //const Text("Schedule Request\n from minDate\n to maxDate");
  Column(  children: [
      if(isDateChanged)...[Text(dateTitle)],


      Container(
        alignment: alignment,
        padding: const EdgeInsets.all(15),
        // color: Colors.amber,
        child: Row(  //crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if(alignment == Alignment.centerRight)...[const Expanded(flex:1,  child: AspectRatio(aspectRatio: 2, child: SizedBox()))],
            Expanded(flex: 3,
              child: AspectRatio(
                aspectRatio: 3/4,
                child: Container(padding: const EdgeInsets.all(10),  //constraints: const BoxConstraints(minWidth: 50),
                decoration: BoxDecoration(  boxShadow: null, color: color, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: bottomLeftTeardrop,  bottomRight: bottomRightTeardrop)  ), //BorderRadius.all(Radius.circular(18))
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(image != null)...[Expanded(flex: 1, child: AspectRatio(aspectRatio:4/3, child: Container( decoration: const BoxDecoration(color: Color.fromARGB(255,51,51,51), borderRadius: BorderRadius.all(Radius.circular(15))), child: Image.network(image, fit: BoxFit.fitHeight,))))],
                    Text( "$name \nRequested at \u20B9$price/Day\nfrom: ${minDate.toDate().day} ${months[minDate.toDate().month]}\nto:      ${maxDate.toDate().day} ${months[maxDate.toDate().month]}" , textAlign: TextAlign.start,style: const TextStyle(color: Colors.black87, fontSize: 16, ), ),
                    Row( //crossAxisAlignment: CrossAxisAlignment.center, 
                    // mainAxisSize: MainAxisSize.min,
                      children: [
                        if(decision == null && senderEmail != FireBaseAuthentication.emailID)... [
                        Expanded(flex:1, child: Padding(padding: const EdgeInsets.all(8.0), child: FilledButton(onPressed: ()async{  await isAccepted(productID, true ).then((value) => setState((){  decision; })); }, style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255,120,171,120)), surfaceTintColor: MaterialStatePropertyAll(Colors.transparent), shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),),   child: const Text("Accept")),)),
                        Expanded(flex:1, child: Padding(padding: const EdgeInsets.all(8.0), child: FilledButton(onPressed: ()async{  await isAccepted(productID, false).then((value) => setState((){  decision; })); }, style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255,249,244,244)), surfaceTintColor: MaterialStatePropertyAll(Colors.transparent), shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),),   child: const Text("Cancel", style: TextStyle(color: Color.fromARGB(255, 187, 85, 22)),)),)),
                        ],
                        if(decision == true )...[ Expanded(flex:1, child: SizedBox(height: 40, child: Container( decoration: BoxDecoration( borderRadius: BorderRadius.only(bottomLeft: specialBottomLeft, bottomRight: specialBottomRight, topLeft: const Radius.circular(6), topRight: const Radius.circular(6),), color: const Color.fromARGB(255,244,252,236),  ), child: const Center(child: Text("Accepted", style: TextStyle(color: Color.fromARGB(255,120,171,120)),))))),],
                        if(decision == false)...[ Expanded(flex:1, child: SizedBox(height: 40, child: Container( decoration: const BoxDecoration( borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topLeft: Radius.circular(6), topRight: Radius.circular(6)), color: Color.fromARGB(255,255,235,235),  ), child: const Center(child: Text("Rejected", style: TextStyle(color: Color.fromARGB(255,187,85,22)),))))),],
                        if(decision == null && senderEmail == FireBaseAuthentication.emailID)...[ Expanded(flex:1, child: SizedBox(height: 40, child: Container( decoration: const BoxDecoration( borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), topLeft: Radius.circular(6), topRight: Radius.circular(6)), color: Color.fromARGB(255,196,196,255),  ), child: const Center(child: Text("Pending", style: TextStyle(color: Color.fromARGB(255,0,55,180)),))))),],
                                    ])
                  ],
                )),
              ),
            ),
            if(alignment == Alignment.centerLeft)...[const Expanded(flex:1,  child: AspectRatio(aspectRatio: 2, child: SizedBox()))],
          ],
        ),
      ),
    ],
  );  
}
String previousMsgTime = "0/0";

Widget messageBox(doc){
  doc as Map<String, dynamic>;  
  AlignmentGeometry alignment = Alignment.centerRight;
  late Color? color;
  late Radius bottomLeftTeardrop;
  late Radius bottomRightTeardrop;
  if(doc["reciverID"]==widget.reciverEmail){  alignment = Alignment.centerRight; color = Colors.grey[200]; bottomLeftTeardrop = const Radius.circular(20) ; bottomRightTeardrop = const Radius.circular(0); }else{alignment = Alignment.centerLeft; color = Colors.green[100]; bottomLeftTeardrop = const Radius.circular(0) ; bottomRightTeardrop = const Radius.circular(20);}
  
  String date  = DateFormat("dd/MM").format(doc['timeStamp'].toDate()).toString();
  String dateTitle = "";
  bool isDateChanged = false;
  if(date !=previousMsgTime){ isDateChanged = true; previousMsgTime=date; dateTitle= date;}
  print("today: ${DateFormat("dd/MM").format(Timestamp.now().toDate())}, date: ${date}");
  if(DateFormat("dd/MM").format(Timestamp.now().toDate().subtract(const Duration(days: 1))) == date){dateTitle = "yesterday";}
  if(DateFormat("dd/MM").format(Timestamp.now().toDate()) == date){dateTitle = "Today";}
  return 
  Column(
    children: [
      if(isDateChanged)...[Text(dateTitle)],
      Container( alignment: alignment, padding: const EdgeInsets.all(15), child: messageBubbble(bottomLeftTeardrop, bottomRightTeardrop, color, doc),

      ),
    ],
  );  
  
}

Widget messageBubbble(Radius bottomLeftTeardrop,Radius bottomRightTeardrop, Color? color, Map<String, dynamic> doc) {
  Timestamp time = doc["timeStamp"];
  
  return 
  Container(padding: const EdgeInsets.all(10), constraints: const BoxConstraints(minWidth: 50),
decoration: BoxDecoration( boxShadow: null, color: color, borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: bottomLeftTeardrop,  bottomRight: bottomRightTeardrop)  ), //BorderRadius.all(Radius.circular(18))
child: Column( crossAxisAlignment: CrossAxisAlignment.center,
  children: [
        Text( doc["message"]??"none", textAlign: TextAlign.center,style: const TextStyle(color: Colors.black87, fontSize: 16, ), ),
        Text("${time.toDate().hour}:${time.toDate().minute}", style: const TextStyle(color: Colors.black54, fontSize: 10,), )
  ],
));
}



void sendMessage(){
print("_ChatSectionState Function sendMessage");
Chats().sendMessage(widget.reciverEmail, _messageController.text, widget.roomID);

}

  @override
  Widget build(BuildContext context) {
    
    return Scaffold( appBar: AppBar(title:  Text(widget.reciverEmail), backgroundColor: Colors.green[300],),
    body: Center(child: Column(children: [

          Expanded(child: Container(color: Colors.white, child: _someWidget())),
          const Divider(thickness: 1, indent: 10, endIndent: 10, height: 1),
          TextField( 
            cursorColor: Colors.black, controller: _messageController, 
            decoration: InputDecoration(
              fillColor: Colors.green[50], filled: true, 
              contentPadding: const EdgeInsets.all(20),border: InputBorder.none,   
              hintText: AppLocalizations.of(context)!.tagChatTypeamessage, 
              suffixIcon: 
              SizedBox( width: 100,
                child: Row(  mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    InkWell(onTap:(){sendMessage(); _messageController.clear();},child: const Icon(Ionicons.paper_plane_outline), ),
                    // InkWell(onTap: ()async{ await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    //   return CalenderPage(calendarController: ChatSection.calendarController, chatRoomID: widget.roomID, reciverEmail: widget.reciverEmail,);
                      
                    //   })).then((value){                       
                    //    print( "Calender minDate: ${ChatSection.calendarController.rangeMinDate!.day}, maxDate: ${ChatSection.calendarController.rangeMaxDate!.day}" );
                       
                    //    });},
                    //   child: const Icon(Icons.schedule),)
                  ],),
              )
               ),
              )
        ],
      ),
    ),

    );
  }
}
 



class Chats {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

void sendMessage(String reciverID, String message, String chatRoomID)async{
  


final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
final timeStamp = Timestamp.now();
//final reciverID = reciverID;

Message messageHeader = Message(senderEmail: currentUserEmail, reciverID: reciverID, message: message, timeStamp: timeStamp);




await _fireStore.collection("chat_rooms").doc(chatRoomID,).collection("message").add(messageHeader.toMap()); //await _fireStore.collection("chat_rooms").doc(chatRoomID).collection("message").add(messageHeader.toMap());
}

Stream<QuerySnapshot> getMessage(String chatRoomID, String reciverEmail){
return _fireStore.collection("chat_rooms").doc(chatRoomID).collection("message").orderBy("timeStamp", descending: false).snapshots(); 

}


Future<String> createChatRoom(final String user1, final String user2)async{
  print("$user1  $user2");
  final List<String> emails = [user1, user2];
  emails.sort();
  final String chatRoomID = emails.join("-");
  print("chatRoomID: $chatRoomID");


  await _fireStore.collection("user_chatroomID").doc(user1).set({chatRoomID:user2}, SetOptions(merge: true));
  await _fireStore.collection("user_chatroomID").doc(user2).set({chatRoomID:user1}, SetOptions(merge: true));

  return chatRoomID;


}

someFunction()async{ try {
  await _fireStore.collection( "chats" ).doc("roomID");
} catch (e) {print(e);}}

Future<Map<String, dynamic>> chatRoomsIDs(email)async{
late dynamic docSnap;
//try {
var docRef = await _fireStore.collection("user_chatroomID").doc(email);
await docRef.get().then((value) { docSnap = value.data() as Map<String, dynamic>;});
var chatRoomsIDs = docSnap;
print("docSnap: $docSnap, runtimeType:${docSnap.runtimeType} " );   //var chatRoomsIDs = docSnap.keys;
return chatRoomsIDs; 


}

Future<void> sendScheduleRequest(String reciverEmail,  String chatRoomID, String productID, String name, String image, String price, DateTime minDate,DateTime maxDate)async{
  final String senderEmail = _firebaseAuth.currentUser!.email.toString();
  final Timestamp timeStamp = Timestamp.now();
//print("sendScheduleRequest: $minDate, $maxDate");
  Map<String,dynamic> scheduleRequestMSG = {
    "productID":productID,
    "name":name,
    "image":image,
    "price":price,
    "senderEmail":senderEmail,
    "reciverID":reciverEmail,    
    "minDate":minDate,
    "maxDate":maxDate,
    "timeStamp":timeStamp,
    "decision":null
    };


  await _fireStore.collection("chat_rooms").doc(chatRoomID,).collection("message").add(scheduleRequestMSG); 

}

sendScheduleDecision(String chatRoomID, String docID, bool isAccepted){
  _fireStore.collection( "chat_rooms" ).doc(chatRoomID).collection("message").doc(docID).set({"decision":isAccepted}, SetOptions(merge: true)); //isAccepted?"accept":"reject"
}
  
}



class Message{ final String senderEmail; final String reciverID; final String message; final Timestamp timeStamp;
Message({required this.senderEmail, required this.reciverID, required this.message, required this.timeStamp});

Map<String, dynamic> toMap(){
  return{
    "senderEmail":senderEmail,
    "reciverID":reciverID,
    "message":message,
    "timeStamp":timeStamp,
  };
}
}