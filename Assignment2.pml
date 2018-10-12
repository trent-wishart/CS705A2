/*
for all processes, 1 to Num_processes-1,	[this is -1 as one will be in the CS?]
assign process id (j) to pos[i],
assign





*/

bit ready1 = 0;
bit sat;

byte num_processes = 5;
byte num_processes_ex = num_processes+1;

byte cs_user; //Process inside CS
byte processes[num_processes];
byte accessed[num_processes]; 
byte mutex; 

byte step[num_processes];
byte pos[num_processes];

//LTL Properties

ltl Safety_Property1 {[](mutex != 2)}
//ltl Test {[] mutex >= 1}
//ltl Liveness_Property2 {[]<> (req[1] == 1 -> cs_user == 1)}


proctype P(int i){


	int j;
	int k;
	ready1;


	for (j : 1 .. num_processes) {
		//printf("here");
		pos[i-1] = j;
		step[j-1] = i;
		printf("\ni = %d, j = %d, pos[i] = %d, step[j] = %d\n", i, j, pos[i-1], step[j-1]);

		do
		:: skip ->	for (k : 1 .. num_processes){
				if
				:: (k == i) -> skip;
				:: else -> 	if
							:: ((pos[k-1] < j) && (step[j-1] != i)) -> sat = 1; break;
							fi
				fi
			}
		od
	}

	mutex++;
	run cs(i);
	mutex--;

	pos[i] = 0;



}



proctype cs(byte id){
	//this is the critical section, this is the only place that accesses the variable accessed[]
	accessed[id] = accessed[id] + 1;
	printf("\nprocess %d has reached %d\n\n", id, accessed[id]);

	mutex--;
}

proctype initialise(){
	 	
		int i;
		for (i : 1 .. num_processes) {
			run P(i); 
			printf("\nProcess %d created\n", i);

		}
		ready1 = 1;
}

init {
	d_step{run initialise();}
	}
}

