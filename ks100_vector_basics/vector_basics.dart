library vector_basics;

import 'package:sparkflow/sparkflow.dart';
import 'package:hub/hub.dart';

//Welcome to Lesson 1: Vectors Basics (Generally Component Building 101)

//Components can be create into two ways in sparkflow 
// generally using inheritances as within these examples 
// or using a registery where we simple bind operations into empty shells as 
//will be seen in 101_canvas_basic tutorial

//Here I wish for you to gain insight into the generally way a component is created and 
//can be interacted with,without having a network or register,as these is the basics
//for anyone to grasp,even without networks,components still behave

class Vector2Add extends Component{
  List v1,v2;

  Vector2Add(): super('VectorAdd'){
    this.meta('id','VectorAdd');
    this.meta('description','adds two vector list together');

    //vector add takes two vector arrays separately from two ports
    // that is the first comes in port 1 and the second array comes in
    //port 2 and then its sends out the result using a output port

    //make a group for the ports
    this.createSpace('in');
    this.makeInport('in:v1'); //port for the first vector
    this.makeInport('in:v2'); //port for the second vector

    this.createSpace('out'); // group for output ports
    this.makeOutport('out:result');

    //runs this functions if any returns false,it drops the packet
    this.port('in:v1').forceCondition((n) => n is List); 
    this.port('in:v2').forceCondition((n) => n is List); 

    this.port('in:v1').forceCondition((n){
      if(n.length > 2) return false;
      return true;
    }); // runs the function to ensure the list is of Length2

    this.port('in:v2').forceCondition((n){
      if(n.length > 2) return false;
      return true;
    }); // runs the function to ensure the list is of Length2

    this.port('in:v1').tapData((n){ //lets only listen for data events
      this.v1 = n.data;
      this.add(); // calls the add function which will check if both vectors are available then add
    });

    this.port('in:v2').tapData((n){
      this.v2 = n.data;
      this.add(); // calls to execute the add operation
    });

  }

  void add(){
    if(Valids.notExist(v1) || Valids.notExist(v2)) return null;
    var add = new List(2);
    add[0] = this.v1[0] + this.v2[0];
    add[1] = this.v1[1] + this.v2[1];

    this.port('out:result').send(add); // send out the result to the outport
    this.port('out:result').endStream(); //always endstream after you sent all data;
  }

}

class Vector2Subtract extends Component{
  List v1,v2;

  Vector2Subtract(): super('VectorSubtract'){

    this.createSpace('in');
    this.createSpace('out');

    this.makeInport('in:v1'); 
    this.makeInport('in:v2'); 
    this.makeOutport('out:result');

    this.port('in:v1').forceCondition((n) => n is List); 
    this.port('in:v2').forceCondition((n) => n is List); 

    this.port('in:v1').forceCondition((n){
      if(n.length > 2) return false;
      return true;
    }); 

    this.port('in:v2').forceCondition((n){
      if(n.length > 2) return false;
      return true;
    }); 

    this.port('in:v1').tapData((n){
      this.v1 = n.data;
      this.subtract(); 
    });

    this.port('in:v2').tapData((n){
      this.v2 = n.data;
      this.subtract(); 
    });

  }

  void subtract(){
    if(Valids.notExist(v1) || Valids.notExist(v2)) return null;
    var sub = new List(2);
    sub[0] = this.v1[0] - this.v2[0];
    sub[1] = this.v1[1] - this.v2[1];

    this.port('out:result').send(sub); // send out the result to the outport
    this.port('out:result').endStream(); //always endstream after you sent all data;
  }

}


void main(){
  
    var add = new Vector2Add();
    var sub = new Vector2Subtract();
    var sub2 = new Vector2Subtract(); // lets have abit of fun with this

    // these are functions that take a value and prints them out with the title
    // the definition is located within the Hub library,
    // its not different from running print('Vector Addtion $res')
    var addPrinter = Funcs.tag('Vector Addition');
    var subtractPrinter = Funcs.tag('Vector Subtraction');
    var boundPrinter = Funcs.tag('Bound Vector Subtraction');
    
    // lets bind into the output port for the result to be printer out
    add.port('out:result').tapData(addPrinter);
    sub.port('out:result').tapData(subtractPrinter);
    sub2.port('out:result').tapData(boundPrinter);

    add.port('out:result').bindPort(sub2.port('in:v1')); // we can bindports together

    var v1 = [20,10], v2 = [30,40]; // out vectors

    add.port('in:v1').send(v1);
    add.port('in:v2').send(v2);

    sub.port('in:v1').send(v1);
    sub.port('in:v2').send(v2);

    sub2.port('in:v2').send(v2);
}
