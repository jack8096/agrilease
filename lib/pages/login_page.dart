import 'package:agrilease/login_api.dart';
import 'package:agrilease/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
      

    return     WillPopScope(
      onWillPop: () {return Future.delayed(Duration.zero, (){  if(FireBaseAuthentication.isSignedIn){return true;}else{return false;} });},
      child: Scaffold(
        body: Container( padding: const EdgeInsets.all(20), decoration: const BoxDecoration( image: DecorationImage( fit: BoxFit.cover,  image: AssetImage("assets/loginScreen01.jpg")) ), 
          child: ListView(children: [AspectRatio(aspectRatio: 1, child: Container(  decoration: const BoxDecoration(image: DecorationImage( image: AssetImage("assets/LoginLogo.png"))),)),
                  
          //const AspectRatio(aspectRatio: 2, child: Text(style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1 ), "Unlock Possibilities, Share Tools: \nWelcome to Agrilease - Where Equipment Finds Its Next Adventure")).animate(effects: [const ShimmerEffect(duration: Duration(seconds: 2))]),

          const Text( style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 1.3 ), textAlign: TextAlign.center, maxLines: 1, "Agrilease", ),
          

          FilledButton(onPressed: ()async{ await Navigator.of(context).push(MaterialPageRoute(builder: (context){return const PhoneLogin();})   ).then((value){ if(FirebaseAuth.instance.currentUser != null){return Navigator.of(context).pop(); }}    );
   }, 
              
              
              
              child: const Text("phone sign in")),

          AspectRatio(aspectRatio: 3, child: Center(child: FilledButton(  onPressed: ()async{await FireBaseAuthentication().signInWithGooggle().then( (value){if(FireBaseAuthentication.isSignedIn){Navigator.of(context).pop(); ProfileInfo.setProfileInfo();} ProfileInfo.setProfileInfo();  }  );  },  style: ButtonStyle(shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),   backgroundColor: MaterialStateProperty.all(Colors.transparent,) ),child: const Image(height: 40, image: AssetImage("assets/android_neutral_sq_SI@4x.png")) ) )), //const Text("Sign in with Google"),
            ],
          ),
        ),
      ),
    );
  }

}


class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key, });

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool otpSend = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController smsOTP = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: AspectRatio( aspectRatio: 1,
          child: Form( key: formkey,
            child: Column(children: [
              //!otpSend?
              TextFormField(keyboardType: TextInputType.number, controller: phoneNumberController,inputFormatters: [FilteringTextInputFormatter.digitsOnly,], maxLength: 10, decoration: const InputDecoration( hintText: "Enter Phone Number"),  ),
              //:TextFormField(keyboardType: TextInputType.number, controller: smsOTP, inputFormatters: [FilteringTextInputFormatter.digitsOnly,], maxLength: 6, decoration: const InputDecoration(hintText: "Enter OTP"),),
              //!otpSend?
              FilledButton(onPressed: (){  
        
              auth.verifyPhoneNumber( phoneNumber: "+91${phoneNumberController.text}",
              verificationCompleted: (PhoneAuthCredential credential){ print("phone loged in"); Navigator.of(context).pop();        },
              verificationFailed: (FirebaseAuthException e){}, 
              codeSent: (String verificationId, int? resendToken)async{ 
                print("smsOTP.text: ${smsOTP.text}");
                Navigator.of(context).push(MaterialPageRoute(builder: (context){return  EnterOTPScreen(verificationId: verificationId); }));
                
              // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsOTP.text);
              // await auth.signInWithCredential(credential).then((value){  Navigator.of(context).pop(); Navigator.of(context).pop();  });
               }, 
              codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout){});  
        
        
        
                }, child: const Text("Send OTP")),
              // :FilledButton(onPressed: (){   
              // auth.verifyPhoneNumber( phoneNumber: "+91${phoneNumberController.text}",
              // verificationCompleted: (PhoneAuthCredential credential){ print("phone loged in"); Navigator.of(context).pop();        },
              // verificationFailed: (FirebaseAuthException e){}, 
              // codeSent: (String verificationId, int? resendToken)async{ 
              //   print("smsOTP.text: ${smsOTP.text}");
              //   showDialog(barrierDismissible:false, context: context, builder: (context){return sendOTPloadingAlert();});
                
              // PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsOTP.text);
              // await auth.signInWithCredential(credential).then((value){  Navigator.of(context).pop(); Navigator.of(context).pop();  });
        
        
              //  }, 
              // codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout){});              
              //     }, child: const Icon(Ionicons.arrow_forward)),
            ],),
          ),
        ),
      )
    );
  }

Dialog sendOTPloadingAlert() => const Dialog(surfaceTintColor: Colors.transparent, backgroundColor: Colors.transparent,
  child: AspectRatio(
    aspectRatio: 1,
    child: CircularProgressIndicator(color: Colors.black,),
  ),
);




}





            // auth.verifyPhoneNumber( phoneNumber: phoneNumberController.value.toString(),
            // verificationCompleted: (PhoneAuthCredential credential){},
            // verificationFailed: (FirebaseAuthException e){}, 
            // codeSent: (String verificationId, int? resendToken)async{ 
            //   String smsOTP = "";
            //   //await Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const OTPPage())).then((value){ smsOTP = OTPPage.smsOTP.value.toString(); print("smsOTP: $smsOTP"); } );


            //  }, 
            // codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout){});


class EnterOTPScreen extends StatelessWidget {final String verificationId;
  const EnterOTPScreen({super.key, required this.verificationId});
static final TextEditingController smsOTP = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async=> false,
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: AspectRatio(aspectRatio: 1,
            child: Column(children: [
              TextFormField(keyboardType: TextInputType.number, controller: smsOTP, inputFormatters: [FilteringTextInputFormatter.digitsOnly,], maxLength: 6, decoration: const InputDecoration(hintText: "Enter OTP"),),
              FilledButton(onPressed: (){
              
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsOTP.text);
                FirebaseAuth.instance.signInWithCredential(credential).then((value){  Navigator.of(context).pop(); Navigator.of(context).pop(); });
              
              }, child: const Icon(Ionicons.arrow_forward))
              
            ],),
          ),
        ),
      ),
    );
  }
}            