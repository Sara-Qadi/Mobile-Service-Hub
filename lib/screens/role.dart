import 'package:flutter/material.dart';
import 'package:mobile_service_hub/screens/create_account.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 250),

            Text(
              "Please select your role",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAccountScreen(role: "Service Provider"),
                  ),
                );
              },
              child: Text("Customer" ,   style: TextStyle(fontSize: 20),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70),

                primary: Colors.blue,
              ),
              
            ),
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAccountScreen(role: "Admin"),
                  ),
                );
              },
              child: Text("Service Provider",   style: TextStyle(fontSize: 20),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70),
                primary: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAccountScreen(role: "Customer"),
                  ),
                );
              },
              child: Text("Admin",   style: TextStyle(fontSize: 20),),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70),
                primary: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
