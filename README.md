1. +0.5 ec
	error message, give feedback
	pause, press enter to continue

2. max string length
	128 bytes

3. capitalize THE

MASM4
For this assignment, you will be creating a Menu driver program that allows the user to test all of your string macros that you created for MASM3 plus some additional functionality.
1. Create an array of 10 empty strings.
2. Allow the user to enter a string and store it in the array.
3. If the array is full, do not allow the user to store any more strings until there is room.
4. Allow the user to delete a string.
5. Allow the user to see the entire array of strings.
6. Allow the user to search for a substring within the entire array.
More details to follow ......

MASM4                                STRING MANAGER
<1> View all strings
<2> Add string
<3> Delete string
<4> Edit string
<5> String search
<6> String Array Memory Consumption
<7> Quit

EXAMPLE RUNS:
<1> View all Strings
[0] 
 .
 .
[9] 


clear the screen and reprint menu

<2> Add String
Enter new string (Max 127 characters): The cat in the hat.
SUCCESSFULLY ADDED STRING 0: "The cat in the hat"


clear the screen and reprint menu

<1> View all strings
[0] The cat in the hat
 .
 .
[9] 


clear the screen and reprint menu

<2> Add ..... 

<1> View all Strings
[0] The cat in the hat.
 .
 .
[4] Green eggs and ham.
 .
 .
[9] The mouse in their house.


clear the screen and reprint menu

<2> Add String
**ERROR String Manager is FULL, please delete a string before adding.


clear the screen and reprint menu

<3> Delete String
Please enter string index to delete: 4
Deleting: [4] Green eggs and ham. CONFIRM DELETION Y/N: Y
SUCCESSFULLY DELETED STRING [4] 


clear the screen and reprint menu

<4> Edit String
Please enter string index to edit: 0
[0] The cat in the hat. CONFIRM EDIT Y/N: Y
[0] The cat ate my hat.
SUCCESSFULLY EDITED STRING[0]


clear the screen and reprint menu

<5> String search
Please enter the target string: The
"The" successfully found 4 times:
[0] The cat ate my hat.
[9] The mouse in their house.
[EXTRA CREDIT +0.5]
[0] THE cat ate my hat.
[9] THE mouse in THEir house. 

<6> String Array Memory Consumption
The String Array size: 300 bytes (dependent upon the actual length of all 10 strings.)

EXTRA CREDIT : +2.5 Use dynamic memory allocation/deallocation when adding/deleting your strings.
