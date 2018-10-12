int key;
byte it;
byte itp = 0;
byte num_processes = 5;
byte processes[num_processes]; 
byte weights[num_processes]; 
byte mutex; 
bit flag[num_processes];
byte leader;
bit done = 0;
bit doneA= 0;
bit doneB= 0;
bit doneC= 0;

byte accessed[num_processes];

//LTL Properties

ltl Safety_Property1 {[](mutex != 2)}
//ltl Test {[] mutex >= 1}
//ltl Liveness_Property2 {[]<> accessed[1] >= 1}


proctype P(byte myID){
	doneB;
	weights[myID] = 1;

	//printf("\nHi I am process %d, my weight is %d\n", myID, weights[myID]);

	start:
	do
	:: (key == myID && mutex == 0) -> printf("\nI am %d and its my turn\n\n", myID); break;
	//:: ((key != myID) && (first != 0)) -> weights[myID] = weights[myID] + 1; 
	:: (done == 1) -> goto end;
	:: else -> goto start;
	od

	doneC = 0;
	mutex++;
	printf("\nmutex in = %d\n\n", mutex);
	atomic{run cs(myID);}
	doneC;
	printf("\nmutex out = %d\n\n", mutex);

	//printf("done = %d\n", done);
	if
	:: (done != 1) -> atomic{run findLeader();} goto start
	:: (done == 1) -> printf("DONE\n"); goto end
	fi
	end:
}


proctype findLeader(){
	byte lead = weights[0];
	bit change = 0;
	int j;

	for (j : 0 .. num_processes-1) {
		if
		:: (weights[j] > lead) -> lead = weights[j]; leader = j; change = 1;
		:: (weights[j] < lead) -> change = 1;
		:: (weights[j] == lead);
		fi
		//printf("\nw %d\n", weights[j]);

	}
	//printf("change = %d\n", change);

	if 
	:: (change == 0) -> key = 0; 
	:: (change == 1) -> key = leader;
	fi
	printf("\nIt is process %d's turn\n\n", key);
	doneA = 1;
}


proctype cs(byte id){
	//this is the critical section, this is the only place that accesses the variable accessed[]
	accessed[id] = accessed[id] + 1;
	printf("\nprocess %d has reached %d\n\n", id, accessed[id]);
	int i;
	for (i : 0 .. num_processes-1) {
		weights[i] = weights[i] + 1;
		//printf("\nwnew %d\n",weights[i]);
	}
	weights[id] = weights[id] - 1;

	if
	:: (accessed[id] >= 5) -> done = 1; printf("STOP PLEASSE\n");
	:: (accessed[id] < 5) -> done = 0; //printf("next\n");
	fi

	mutex--;
	doneC = 1;
}

proctype initialise(){
	 	
		int i;
		for (i : 0 .. num_processes-1) {
			run P(i); printf("\nProcess %d created\n", i);
		}
		doneB = 1;
}

init {
	doneA = 0;
	run findLeader();
	doneA;
	doneB = 0;
	run initialise();
	}
	
}




/* Perfect hang

	if
	:: (accessed[id] >= 5) -> done = 1; printf("STOP PLEASSE");
	fi

	*/