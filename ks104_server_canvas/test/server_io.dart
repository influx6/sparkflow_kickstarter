library server_io;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:sparkflow/sparkflow.dart';
import 'package:hub/hub.dart';

class Server{

  static RegExp socketMatcher = new RegExp(r'/ws$');

  static void register(){

     Sparkflow.createRegistry('http',(r){
  
        r.addMutation('io/server',(e){

           e.makeOutport('io:req');
           e.makeOutport('io:error');

           var server,port = 8080, address = '127.0.0.1';
           HttpServer.bind(address,port).then((s){
              server = s;
              s.listen((req){
                 e.send('io:req',req);
              });
           }).catchError((f){
              e.send('io:error',f);
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

        r.addMutation('io/socket_actor',(e){
            
            var sockets = [];

            Function fn;
            e.makeInport('io:req');
            e.makeInport('io:fn');

            e.port('io:req').pause();
            e.port('io:req').forceCondition((req){
              if(Server.socketMatcher.hasMatch(req.uri.path)) return true;
              return false;
            });

            e.tapData('io:fn',(n){
                fn = n.data;
                e.port('io:req').resume();
            });


            e.tapData('io:req',(n){
                WebSocketTransformer.upgrade(n.data).then((w){
                  sockets.add(w);
                  return fn(w);
                });
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
  io.use('http/io/socket_actor','socket');

  io.ensureBinding('servo','io:req','page','io:req');
  io.ensureBinding('servo','io:req','socket','io:req');

  io.schedulePacket('page','io:fn',(req){
     var path = req.uri.path;
     if(Server.socketMatcher.hasMatch(path)){
       print('Creating websocket connection for ${path}');
       return;
     }
     req.response.write('Welcome to ${path}');
     req.response.close();
  });

  io.schedulePacket('socket','io:fn',(socket){

    print('creating websocket for new connection');

    var rightbit = new math.Random();
    var leftbit = new math.Random();
    var colors = ['grey', 'black', 'yellow', 'red', 'green', 'blue', 'white', 'cyan', 'magenta','pink','peru','peachpuff','plum','orange'];

    var sendData = (socket){
        var coordinates = new List(5);
        coordinates[0] =  '${colors[leftbit.nextInt(colors.length)]}';
        coordinates[1] = rightbit.nextInt(10)  * leftbit.nextInt(8);
        coordinates[2] = rightbit.nextInt(5) * leftbit.nextInt(40);
        coordinates[3] = rightbit.nextInt(40) * leftbit.nextInt(100);
        coordinates[4] = rightbit.nextInt(140) * leftbit.nextInt(20);

        socket.add(JSON.encode({'message':'draw', 'data': coordinates}));
    };

    socket.listen((pack){

        Timer clock;

        var data = JSON.decode(pack);

        if(data['message'] == 'go'){
           
            new Timer.periodic(new Duration(milliseconds: 300),(t){
              clock = t;
              sendData(socket);
            });
        }

        if(data['message'] == 'stop'){
           return clock.cancel();
        }

        if(data['message'] == 'ping'){
          return socket.add(JSON.encode({'message':'pong'}));
        }

    });

      socket.add(JSON.encode({ 'message':100 }));

  });

  io.boot().then(Funcs.tag('booting io servo'));

}
