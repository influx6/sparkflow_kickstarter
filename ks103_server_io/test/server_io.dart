library server_io;

import 'dart:async';
import 'dart:io';
import 'package:sparkflow/sparkflow.dart';
import 'package:hub/hub.dart';

class Server{

  static void register(){

     Sparkflow.createRegistry('http',(r){
  
        r.addMutation('io/server',(e){

           e.makeOutport('io:req');
           e.makeOutport('io:error');

           var server,port = 3001, address = '127.0.0.1';
           HttpServer.bind(address,port).then((s){
              server = s;
              s.listen((req){
                 e.send('io:req',req);
              });
           }).catchError((e){
              e.send('io:error',e);
           });
        });

        r.addMutation('io/route_actor',(e){
  
            Function fn;
            e.makeInport('io:req');
            e.makeInport('io:fn');

            e.port('io:req').pause();

            e.tapData('io:fn',(n){
                fn = n.data;
                e.port('io:req').resume();
            });


            e.tapData('io:req',(n){
                return fn(n.data);
            });

        });

     });
  }
}

void main(){
  
  Server.register();
  var io = Network.create('basic_server');
  io.use('http/io/server','servo');
  io.use('http/io/route_actor','page');

  io.ensureBinding('servo','io:req','page','io:req');

  io.schedulePacket('page','io:fn',(req){
     req.response.write('Welcome to ${req.uri.path}');
     req.response.close();
  });


  io.boot().then(Funcs.tag('booting io servo'));

}
