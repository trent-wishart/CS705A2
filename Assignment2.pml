/*
for all processes, 1 to Num_processes-1,	[this is -1 as one will be in the CS?]
assign process id (j) to pos[i],
assign





*/

bit sat;

byte num_processes = 5;
int proc_count;

byte cs_user; //Process inside CS
//byte processes[num_processes];
byte accessed[num_processes]; 
byte mutex = 0; 

bit ready1 = 0;
bit ready2 = 0;
bit ready_array[num_processes];
bit master_ready = 0;

byte step[num_processes];
byte pos[num_processes];

//LTL Properties

//ltl Safety_Property1 {[](mutex != 2)}
//ltl Test {[] mutex >= 1}
//ltl Liveness_Property2 {[]<> (req[1] == 1 -> cs_user == 1)}


proctype P(byte id){

	//ready_array[i-1] = 0;
	byte j;
	byte k;
	ready1;
	run updatePos(id);
	run sync();
	master_ready;

	do
	:: skip ->	for (k : 1 .. num_processes){
					if
					:: (k == id) -> skip;
					:: else -> 	if
								:: ((pos[k-1] < j) && (step[j-1] != id)) -> sat = 1; break;
								fi
					fi
				}
	od

	mutex++;
	cs_user = id;
	run cs(id);
	mutex--;

	pos[id] = 0;
}

proctype cs(byte id){
	//this is the critical section, this is the only place that accesses the variable accessed[]
	accessed[id] = accessed[id] + 1;
	printf("\nprocess %d has reached %d\n\n", id, accessed[id]);
}

proctype updatePos(byte i){
	d_step{
		byte it;
		byte new[num_processes];

		for (it : 0 .. num_processes - 2){
			new[it+1] = pos[it];
		}
		for (it : 0 .. num_processes - 1){
			pos[it] = new[it];
		}		
		pos[0] = i;
		ready_array[i-1] = 1;
	}	
}

proctype sync(){
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
	 	
		for (proc_count : 1 .. num_processes) {
			run P(proc_count); 
		}
		ready1 = 1;
}

init {
	d_step{run initialise();}
	
}

/*

	d_step{
		int it
		for (it : 0 .. num_processes-1) {
			printf("\nfrom process %d, pos[%d] = %d\n", i, pos[it], pos[it]);
		}
	}












	int j;
	for (j : 1 .. num_processes) {
		//printf("here");
		pos[i-1] = j;
		step[j-1] = i;
		printf("\ni = %d, j = %d, pos[i] = %d, step[j] = %d\n", i, j, pos[i-1], step[j-1]);

	}*/










	/*
proctype shifter(bit op){
	//MUST BE USED WHEN END ELEMENT IS EMPTY as you will lose the last element
	//op 0 = pos
	//op 1 = step
		byte it;
		byte new[num_processes];
		printf("\nproc is shifting\n\n");
	
		if
		:: op == 0 -> 	for (it : 0 .. num_processes - 2){
							new[it+1] = pos[it];
							printf("\na\n");
						}
						for (it : 0 .. num_processes - 1){
							pos[it] = new[it];
							printf("\nb\n");
						}
							
		:: op == 1 ->	for (it : 0 .. num_processes - 2){
						new[it+1] = step[it];
						}
						for (it : 0 .. num_processes - 1){
							step[it] = new[it];
							printf("\nb\n");
						}	
		:: else -> skip;
		fi
}
*/