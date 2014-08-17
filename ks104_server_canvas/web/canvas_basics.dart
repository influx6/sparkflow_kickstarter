library canvas_basics;

import 'dart:convert';
import 'dart:html';
import 'package:sparkflow/sparkflow.dart';
import 'package:hub/hub.dart';

//Welcome to Lesson 2: Canvas Basics (Building Components the EasyWay) -> My Way

//In these lessson we are going to create generally 4 components
// Canvas Component
// Rectangel Drawing Component
// We are going to learn how components can interact within a network
// these is some what of weak method for doing canvas,i saw a better approach in node-canvas
// library released by the noflo-guys,check it out

class CanvasBasics{

  static void register(){

    Sparkflow.createRegistry('canvas',(r){
        
        r.addMutation('draw/canvas',(shell){
           
            var canvas;

            shell.makeInport('io:in'); // the io space will be created automatically
            shell.makeOutport('io:out');

            shell.port('io:in').forceCondition((n) => n is CanvasElement);

            shell.tapData('io:in',(n){
               canvas = n.data;
               shell.send('io:out',canvas);
               shell.endStream('io:out'); //always wise to endstream after data is sent
            });

        });

        r.addMutation('draw/rectangle',(shell){

            var canvas,context;
            shell.makeInport('io:canvas');
            shell.makeInport('io:coords');

            shell.port('io:canvas').forceCondition((n) => n is CanvasElement);
            shell.port('io:coords').forceCondition((n) => n is List); 
            shell.port('io:coords').forceCondition((n){
              if(n.length < 5) return false;
              return true;
            });

            shell.port('io:coords').pause();

            shell.tapData('io:canvas',(n){
               canvas = n.data;
               context = canvas.context2D;
               shell.port('io:coords').resume();
            });


            shell.tapData('io:coords',(n){
               print('got coord $n');
                var cd = n.data;
                /*context.save();*/
                context.fillStyle = cd[0];
                context.fillRect(cd[1],cd[2],cd[3],cd[4]);
                /*context.restore();*/
            });

        });

    });
  }
 }


 void main(){
    
    var board = window.document.querySelector('#stage');
    var socket = new WebSocket('ws://127.0.0.1:3001/ws');

    var sendMessage = (String tag,[dynamic m]){
      if(socket != null && socket.readyState == WebSocket.OPEN){
        return socket.send(JSON.encode({'message': tag, 'data': m}));
      }
      print('WebSocket not ready or error in connection');
    };

    
     CanvasBasics.register();
     var canvas = Network.create('basic test');
     canvas.use('canvas/draw/canvas','stage');
     canvas.use('canvas/draw/rectangle','rect');

     canvas.ensureBinding('stage','io:out','rect','io:canvas');

     canvas.schedulePacket('stage','io:in',board);
     canvas.schedulePacket('rect','io:coords',['#C02929',20,20,200,300]);

     canvas.boot().then(Funcs.tag('booting canvas test'));

     socket.onMessage.listen((e){
        var pack = JSON.decode(e.data);
        var message = pack['message'];

        if(message == 100) sendMessage('ping');

        if(message == 'pong') sendMessage('go');

        if(message == 'draw'){
           canvas.schedulePacket('rect','io:coords',pack['data']);
        }

        print('got new message from server $pack');
     });
 }

