byte num_processes = 5;
byte step[num_processes];
byte pos[num_processes];

/****************
LTL Properties
*****************/
ltl Safety_Property1 {[](mutex != 2)}
ltl Liveness_Property2 {[]<> (cs_user == 1)}


/*
Date: 12/10/2018
Author: Trenton Wishart

DESCRIPTION:
	for N (num_processes) processes, 
	individually add to the start of an array called pos in any order
	when new elements (process IDs) come in, shift the values 
	when an element reaches the Nth position, it is then elegible to use the critical section.

	To ensure correctness the time that the process has been waiting for the CS is reccorded in an array called step
	Step can be used as a weighting to ensure that the correct process gets to use the CS 
	Step corresponds to pos, therefore, whenever pos shifts, so does step.
	
	LTL properties are shown above

	The only thing you should need to edit is the value of num_processes at the top of this file

*/

byte j;
int proc_count;

byte cs_user; //Process inside CS
byte accessed[num_processes]; //This array reccords how many times each process has entered the critical section, it is not accessible from anywhere else
byte mutex = 0; //Counter to make sure that processes that are using the cs do not excede 1
bit ready1 = 0;	//checkpoints to make sure that processes are initialised properly
bit ready_array[num_processes];//checkpoints to make sure that processes are initialised properly
bit master_ready = 0;//checkpoints to make sure that processes are initialised properly

proctype P(byte id){
	byte it;
	byte k;
	byte my_score;
	ready1;
	run updatePos(id);
	run sync();
	master_ready;

	do
	:: skip ->	for (it : 0 .. num_processes-1){ //Find highest step index that contains an id
					if
					:: ((step[it] > 0) && (j < step[it])) -> j = it;
					:: else -> skip;
					fi 
				}
				for (it : 0 .. num_processes-1){//Find this ids position
					if
					:: (pos[it] == id ) -> my_score = it;
					:: else -> skip;
					fi 
				}
					if
					:: my_score == j -> break;
					:: else -> skip;	
					fi
	od

	//Start CS
	mutex++;
	cs_user = id;
	run cs(id);
	mutex--;
	//End CS

	//Update for next process
	run updatePos2(id);

	//Could use a goto here to co back to the top if needed for multiple cycles (breif doesnt say so?)
}

proctype cs(byte id){
	//this is the critical section, this is the only place that accesses the variable accessed[]
	accessed[id-1] = accessed[id-1] + 1;
	printf("\nprocess %d has reached %d\n\n", id, accessed[id-1]);
}

proctype updatePos(byte i){
	//this proctype is used when initialising
	d_step{
		byte it;
		byte new[num_processes];

		//Updates Pos
		for (it : 0 .. num_processes - 2){
			new[it+1] = pos[it];
		}
		for (it : 0 .. num_processes - 1){
			pos[it] = new[it];
		}		
		pos[0] = i;

		//Updates step
		for (it : 0 .. num_processes - 2){
			new[it+1] = step[it]+1;
		}
		for (it : 0 .. num_processes - 1){
			step[it] = new[it];
		}		
		step[0] = 1;

		ready_array[i-1] = 1;

	}	
}

proctype updatePos2(byte i){
	//this proctype is used when updating
	d_step{
		byte it;
		byte new[num_processes];

		//Updates Pos
		for (it : 0 .. num_processes - 2){
			new[it+1] = pos[it];
		}
		for (it : 0 .. num_processes - 1){
			pos[it] = new[it];
		}		
		pos[0] = i;

		//Updates step
		for (it : 0 .. num_processes - 2){
			new[it+1] = step[it];
		}
		for (it : 0 .. num_processes - 1){
			step[it] = new[it];
		}		

		ready_array[i-1] = 1;
	}	
}

proctype sync(){
	//Synchronises the processes when initialising pos and step
	d_step{
		byte it;
		master_ready = 1;

		for (it : 0 .. num_processes - 1){
			if
			:: ready_array[it] != 1 -> master_ready = 0; 
			:: else -> skip;
			fi
		}
	}
}

proctype initialise(){	
	//initalise num_processes of process P
	for (proc_count : 1 .. num_processes) {
		run P(proc_count); 
	}
	ready1 = 1;
}

init {
	d_step{run initialise();}
}