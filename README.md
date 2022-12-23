# Number Manipulator: Strings and Macros

Prompts user to enter 10 signed decimal integers that are small enough to fit in a 32-bit register. Reads user input, performs a series of calculations (sum and truncated average), and then prints the calculated results to the user. 

This program was submitted as a course portfolio project and received a score of 47/50.

## Assignment Requirements

* Validate user input
  * Accept input as a string and convert it to numeric form
  * Display an error message if: non-numeric (excluding signs '+' and '-') characters are entered, if the input does not fit within 32-bit registers, or if the input is empty. The invalid input should not be saved and the user should be re-prompted.
* Cannot use `ReadInt` `ReadDec` `WriteInt` or `WriteDec`
* All procedure parameters must be passed on the runtime stack. Strings also must be passed by reference.
* Procedures other than `main` should not reference data segment variables by name.
