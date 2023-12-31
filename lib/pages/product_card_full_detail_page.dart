import 'package:agrilease/login_api.dart';
import 'package:agrilease/pages/chats.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class FullProductDetail extends StatelessWidget {final Color? appBarBackGroundColor; final List<Color> gradientColor; final String image; final String price; final String title; final String description; final String email;  final String contact; final String location;
  const FullProductDetail({super.key,required this.appBarBackGroundColor, required this.gradientColor,  required  this.image, required this.price, required this.title, required this.description, required this.email, required this.location, required this.contact,});
final  backgroundcolor = const Color.fromARGB(255, 255, 249, 255,);


  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( backgroundColor: appBarBackGroundColor, surfaceTintColor: Colors.transparent,),
      body: Container(  color: Colors.white,
        child: ListView(padding: const EdgeInsets.only(left: 10, right: 10, top: 5,),
          children: [
            Card(clipBehavior: Clip.hardEdge, child: Image.network(image, fit: BoxFit.fitWidth,)),
            TitleCard(title: title, price: price, location: location, email: email,),//title price 
            DescriptionCard(description: description),// description
            AddressCard(address: location,),
            
          ],
        ),
      ),



    bottomNavigationBar: SafeArea(child: Container( color: Colors.white,
      child: AspectRatio(aspectRatio: 5.85, child:Padding( padding: const EdgeInsets.all(8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [ OutlinedButton( style: ButtonStyle(    shape: MaterialStateProperty.all<RoundedRectangleBorder>( RoundedRectangleBorder(side: const BorderSide( color: Color.fromRGBO(102, 187, 106, 1)), borderRadius: BorderRadius.circular(6.0),)),
           ),
                        
                        onPressed: ()async{ 
                          print("pressed chat button");
                          if(!FireBaseAuthentication.isSignedIn){
                            await FireBaseAuthentication().signInWithGooggle(); try{print("us: ${FireBaseAuthentication.emailID} them: ${email} ");}catch(e){print(e);}
                            }else{ try{print("us: ${FireBaseAuthentication.emailID} them: ${email} ");
                            await Chats().createChatRoom(FireBaseAuthentication.emailID, email).then((value){  
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){return ChatSection(roomID: value, reciverEmail: email);}));
                               });
                            }catch(e){print(e);} } 

                        }, child: Text(AppLocalizations.of(context)!.tagChat, style: TextStyle(color: Colors.green[400]),) ),
                      ElevatedButton( style: ButtonStyle( backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(102, 187, 106, 1)), foregroundColor: MaterialStateProperty.all<Color>(Colors.white),  shape: MaterialStateProperty.all<RoundedRectangleBorder>( RoundedRectangleBorder( borderRadius: BorderRadius.circular(6.0),))),
                        onPressed: (){ launchUrl(Uri(scheme: 'tel', path: contact)); }, child: Text(AppLocalizations.of(context)!.tagCall)),
           ]            
        ),
      ) ,),
    )),
    floatingActionButton: FloatingActionButton(onPressed: ()async{

        await Chats().createChatRoom(FireBaseAuthentication.emailID, email).then((value){  
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return CalenderPage(calendarController: ChatSection.calendarController, chatRoomID: value, reciverEmail: email);
          //ChatSection(roomID: value, reciverEmail: email);
          }  ));
        
        });


    }, backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), child: const Icon(Icons.schedule_outlined)),
    );
  }


}
class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 2.81, child: Container( decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
       margin: const EdgeInsets.fromLTRB(0, 3, 0, 0), padding: const EdgeInsets.all(15), 
       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Location', style: TextStyle(color: Colors.grey[850], fontSize: 20, fontWeight: FontWeight.normal ))],),));
  }
}



class DescriptionCard extends StatelessWidget {
  const DescriptionCard({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 2, child: //Container( decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
    Card( surfaceTintColor: Colors.transparent, color: Colors.white,
      child:Padding(  padding: const EdgeInsets.all(15), 
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(AppLocalizations.of(context)!.tagDescription, style: TextStyle(color: Colors.grey[850], fontSize: 20, fontWeight: FontWeight.normal )), 
        Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54, overflow: null), )]))));
  }
}



class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
    required this.title,
    required this.price,
    required this.location,
    required this.email,
  });

  final String title;
  final String price;
  final String location;
  final String email;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 2.5, 
      // child: Container( decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      // padding: const EdgeInsets.all(15), 
      child:
      Card( surfaceTintColor: Colors.transparent, color: Colors.white,
        child: Padding( 
          padding: const EdgeInsets.all(15), 
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly,  children: [
          AutoSizeText(title, style: TextStyle(color: Colors.grey[850], fontSize: 22, fontWeight: FontWeight.normal ),), 
          Text('\u20B9 $price', style: TextStyle(color: Colors.grey[850], fontSize: 20, fontWeight: FontWeight.w500 ),),
          Text(email,  style: const TextStyle(color: Colors.black38, overflow: TextOverflow.ellipsis), ), //maxFontSize: 12, minFontSize:10,
          //Text(location,  style: const TextStyle(color: Colors.black38, overflow: TextOverflow.ellipsis), ), //maxFontSize: 12, minFontSize:10,
          ],),
        ),
      ));
      //);
  }
}

class AddressCard extends StatelessWidget {final String address;
  const AddressCard({super.key,required this.address });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 2, child: Card( surfaceTintColor: Colors.transparent, color: Colors.white, 
    child: Padding(padding: const EdgeInsets.all(15), 
    child: Column( crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [ 
      Text(AppLocalizations.of(context)!.tagAddress, style: TextStyle(color: Colors.grey[850], fontWeight: FontWeight.normal, fontSize: 20),),
      Text(address, style: const TextStyle(fontSize: 12, color: Colors.black54, overflow: null), )
    ],),),),);
  }
}