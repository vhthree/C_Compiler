#include <stdio.h>
#include <iostream>
// Declaration of external variables and functions used in lex.yy.c
extern FILE *yyin;          // Input file pointer
extern int yyparse();       // Parser function declaration
extern void yyrestart(FILE *input_file); // Function to restart parser with a new input file

// Function declaration to print the assembly title
void printTitle();

// Main function
int main(int argc, char **argv)
{
    // Printing assembly title
    printTitle();

    // Checking if a file argument is provided
    if (argc <= 1)
        return 1;

    // Opening the input file
    FILE *f = fopen(argv[1], "r");
    if (!f) // Error handling if file couldn't be opened
    {
        perror(argv[1]); // Print error message
        return 1;
    }

    // Restarting parser with the opened file
    yyrestart(f);

    // Calling the parser
    yyparse();

    return 0;
}

// Function definition to print the assembly title
void printTitle()
{
    std::cout << ".intel_syntax noprefix" << std::endl  // Setting Intel assembly syntax
              << ".global main" << std::endl            // Declaring main function as global
              << ".extern printf" << std::endl         // Declaring printf function as external
              << ".data" << std::endl                  // Data section declaration
              << "format_str:" << std::endl           // Declaration of format string label
              << ".asciz \"%d\\n\"" << std::endl       // Definition of format string for integers
              << ".text" << std::endl;                 // Text section declaration
}
