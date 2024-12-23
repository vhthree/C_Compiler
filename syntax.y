%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.cpp"
#include <map>
#include <string>
#include <stack>
void yyerror(const char*);
#define YYSTYPE char *
int ii = 0, itop = -1, istack[100];
int ww = 0, wtop = -1, wstack[100];

int aand = 0, aatop = -1, aastack[100];
int oor = 0, ootop = -1, oostack[100];

#define _BEG_IF     {istack[++itop] = ++ii;}
#define _END_IF     {itop--;}
#define _i          (istack[itop])

#define _BEG_WHILE  {wstack[++wtop] = ++ww;}
#define _END_WHILE  {wtop--;}
#define _w          (wstack[wtop])

#define _BEG_AND  {wstack[++aatop] = ++aand;}
#define _END_AND  {aatop--;}
#define _aa          (wstack[aatop])

#define _BEG_OR  {wstack[++ootop] = ++oor;}
#define _END_OR  {ootop--;}
#define _oo          (wstack[ootop])

void printOperatorX86(std::string msg);//执行操作符
void printNumberX86(std::string msg);//把数字弹入栈
void printIdentifierX86(std::string msg);//把标识符对应的值弹入栈
void printAssignmentX86(std::string msg);//赋值操作
void printDefinitionX86(std::string msg);//给变量分配空间
void printPrintX86();//自定义的print函数
void printFunNameX86(std::string msg);//函数名
void printFunArgX86();//函数参数
void saveFunNameNum(std::string msg);//保存函数名和参数个数
int findFunNameNum(std::string msg);//找到函数名对应的参数个数
std::string tempFunName;//当前函数名
int tempInt=0;//函数参数的个数
std::stack<std::string> tempStack;//把函数参数入栈
std::map<std::string, int> identifierIndexMap;//变量与对应的空间
std::map<std::string, int> funNameIndexMap;//函数名称对应的变量个数
int identifierIndexValue = 1;//所有变量的个数
%}
%token T_Int T_Void T_Return T_Print T_ReadInt T_While
%token T_If T_Else T_Break T_Continue T_Le T_Ge T_Eq T_Ne
%token T_And T_Or T_IntConstant T_StringConstant T_Identifier

%left '='
%left T_Or
%left T_And
%left '|'
%left '^'
%left '&'
%left T_Eq T_Ne
%left '<' '>' T_Le T_Ge

%left '+' '-'
%left '*' '/' '%'
%right '!' '~'


%%

Program:
    /* empty */             { /* empty */ }
|   Program FuncDecl        { /* empty */ }
;

FuncDecl:
    RetType FuncName '(' Args ')' '{' Stmts '}'
                            { printf("\tleave\n\tret\n"); }
;

RetType:
    T_Int                   { /* empty */ }
|   T_Void                  { /* empty */ }
;

FuncName:
    T_Identifier            { printFunNameX86($1);tempFunName=$1; }
;

Args:
    /* empty */             { /* empty */ }
|   Argss                   {saveFunNameNum(tempFunName);printFunArgX86();}
;

Argss:
    T_Int T_Identifier      { tempInt++;tempStack.push($2);}
|   Argss ',' T_Int T_Identifier
                            { tempInt++;tempStack.push($4);}
;



Stmts:
    /* empty */             { /* empty */ }
|   Stmts Stmt              { /* empty */ }
;

Stmt:
    AssignStmt              { /* empty */ }
|   PrintStmt               { /* empty */ }
|   CallStmt                { /* empty */ }
|   ReturnStmt              { /* empty */ }
|   IfStmt                  { /* empty */ }
|   WhileStmt               { /* empty */ }
|   BreakStmt               { /* empty */ }
|   ContinueStmt            { /* empty */ }
|   VarDecls                { /* empty */ }
;
VarDecls:
    /* empty */             { /* empty */ }
|   VarDecls VarDecl ';'    { /* printf("\n\n"); */ }
;

VarDecl:
    T_Int T_Identifier      { printDefinitionX86($2); }
|   T_Int T_Identifier '=' Expr
                            { printDefinitionX86($2);printAssignmentX86($2); }
|   VarDecl ',' T_Identifier
                            { printDefinitionX86($3); }
|   VarDecl ',' T_Identifier '=' Expr
                            { printDefinitionX86($3);printAssignmentX86($3); }
;
AssignStmt:
    T_Identifier '=' Expr ';'
                            { printAssignmentX86($1); }
;

PrintStmt:
    T_Print '('Expr')' ';'  { printPrintX86(); }
;



CallStmt:
    CallExpr ';'            { /*printf("pop\n\n");*/ }
;

CallExpr:
    T_Identifier '(' Actuals ')'
                            { printf("\t/*调用完函数回退栈*/\n\tcall %s\n\tadd esp, %d\npush eax\n", $1, findFunNameNum($1)*4); }
;

Actuals:
    /* empty */             { /* empty */ }
|   Expr PActuals           { /* empty */ }
;

PActuals:
    /* empty */             { /* empty */ }
|   PActuals ',' Expr       { /* empty */ }
;

ReturnStmt:
    T_Return Expr ';'       { printf("\tleave\n\tret\n"); }
|   T_Return ';'            { printf("\tret\n\n"); }
;
IfStmt:
    If TestExpr Then StmtsBlock EndThen EndIf
                            { /* empty */ }
|   If TestExpr Then StmtsBlock EndThen Else StmtsBlock EndIf
                            { /* empty */ }
;

TestExpr:
    '(' Expr ')'            { /* empty */ }
;

StmtsBlock:
    '{' Stmts '}'           { /* empty */ }
;

If:
    T_If            { _BEG_IF; printf("_begIf_%d:\n", _i); }
;

Then:
    /* empty */     { printf("\tcmp eax, 0\n\tje _elIf_%d\n", _i); }
;

EndThen:
    /* empty */     { printf("\tjmp _endIf_%d\n_elIf_%d:\n", _i, _i); }
;

Else:
    T_Else          { /* empty */ }
;

EndIf:
    /* empty */     { printf("_endIf_%d:\n\n", _i); _END_IF; }
;

WhileStmt:
    While TestExpr Do StmtsBlock EndWhile
                    { /* empty */ }
;

While:
    T_While         { _BEG_WHILE; printf("_begWhile_%d:\n", _w); }
;

Do:
    /* empty */     { printf("\tcmp eax, 0\n\tje _endWhile_%d\n", _w); }
;

EndWhile:
    /* empty */     { printf("\tjmp _begWhile_%d\n_endWhile_%d:\n\n", 
                                _w, _w); _END_WHILE; }
;

BreakStmt:
    T_Break ';'     { printf("\tjmp _endWhile_%d\n", _w); }
;

ContinueStmt:
    T_Continue ';'  { printf("\tjmp _begWhile_%d\n", _w); }
;
Expr:
    Expr '+' Expr           { printOperatorX86("add"); }
|   Expr '-' Expr           { printOperatorX86("sub"); }
|   Expr '*' Expr           { printOperatorX86("mul"); }
|   Expr '/' Expr           { printOperatorX86("div"); }
|   Expr '%' Expr           { printOperatorX86("mod"); }
|   Expr '>' Expr           { printOperatorX86("cmpgt"); }
|   Expr '<' Expr           { printOperatorX86("cmplt"); }
|   Expr '|' Expr           { printOperatorX86("bitor"); }
|   Expr '^' Expr           { printOperatorX86("xor"); }
|   Expr '&' Expr           { printOperatorX86("bitand"); }
|   Expr T_Ge Expr          { printOperatorX86("cmpge"); }
|   Expr T_Le Expr          { printOperatorX86("cmple"); }
|   Expr T_Eq Expr          { printOperatorX86("cmpeq"); }
|   Expr T_Ne Expr          { printOperatorX86("cmpne"); }
|   Expr T_Or Expr          { printOperatorX86("or"); }
|   Expr T_And Expr         { printOperatorX86("and"); }
|   '-' Expr %prec '!'      { printOperatorX86("neg"); }
|   '!' Expr                { printOperatorX86("not"); }
|   '~' Expr                { printOperatorX86("tilde");}
|   T_IntConstant           { printNumberX86($1); }
|   T_Identifier            { printIdentifierX86($1); }
|   ReadInt                 { /* empty */ }
|   CallExpr                { /* empty */ }
|   '(' Expr ')'            { /* empty */ }
;
ReadInt:
    T_ReadInt '(' T_StringConstant ')'
                            { printf("\treadint %s\n", $3); }
;

%%
void printOperatorX86(std::string msg)
{   
    printf("\t/* 使用操作符%s: ↓*/\n", msg.c_str());
    if (msg == "add")
    {
        printf("\tpop ebx\n\tpop eax\n\tadd eax, ebx\n\tpush eax\n");
    }
    else if (msg == "sub")
    {
        printf("\tpop ebx\n\tpop eax\n\tsub eax, ebx\n\tpush eax\n");
    }
    else if (msg == "mul")
    {
        printf("\tpop ebx\n\tpop eax\n\timul eax, ebx\n\tpush eax\n");
    }
    else if (msg == "div")
    {
        printf("\tpop ebx\n\tpop eax\n\tcdq\n\tidiv ebx\n\tpush eax\n");
    }
    else if (msg == "neg")
    {
        printf("\tpop eax\n\tneg eax\n\tpush eax\n");
    }
    else if (msg == "mod")
    {
        printf("\tpop ebx\n\tpop eax\n\tcdq\n\tidiv ebx\n\tpush edx\n\tmov eax, edx\n");
    }
    else if (msg == "cmplt")
    {
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, ebx\n\tsetl al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "cmple")
    {
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, ebx\n\tsetle al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "cmpgt")
    {
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, ebx\n\tsetg al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "cmpge")
    {
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, ebx\n\tsetge al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "cmpeq")
    {
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, ebx\n\tsete al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "cmpne")
    {
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, ebx\n\tsetne al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "bitand")
    {
        printf("\tpop ebx\n\tpop eax\n\tand eax, ebx\n\tpush eax\n");
    }
    else if (msg == "bitor")
    {
        printf("\tpop ebx\n\tpop eax\n\tor eax, ebx\n\tpush eax\n");
    }
    else if (msg == "xor")
    {
        printf("\tpop ebx\n\tpop eax\n\txor eax, ebx\n\tpush eax\n");
    }
    else if (msg == "and")
    {
        _BEG_AND;
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, 0\n\tje short _AND_FALSE_%d\n\tcmp ebx, 0\n\tje short _AND_FALSE_%d\n\tpush 1\n\tjmp short _AND_END_%d\n\t_AND_FALSE_%d:\n\tpush 0\n\t_AND_END_%d:\n", _aa, _aa, _aa, _aa, _aa);
        _END_AND;
    }
    else if (msg == "or")
    {
        _BEG_OR;
        printf("\tpop ebx\n\tpop eax\n\tcmp eax, 0\n\tjne short _OR_TRUE_%d\n\tcmp ebx, 0\n\tjne short _OR_TRUE_%d\n\tpush 0\n\tjmp short _OR_END_%d\n\t_OR_TRUE_%d:\n\tpush 1\n\t_OR_END_%d:\n", _oo, _oo, _oo, _oo, _oo);
        _END_OR;
    }
    else if (msg == "not")
    {
        printf("\tpop eax\n\tcmp eax, 0\n\tsete al\n\tmovzx eax, al\n\tpush eax\n");
    }
    else if (msg == "tilde")
    {
        printf("\tpop eax\n\tnot eax\n\tpush eax\n");
    }
    else
    {
        fprintf(stderr, "未找到printOperatorX86 %s 对应的值\n", msg.c_str());
    }
}

void printNumberX86(std::string msg)
{
    printf("\t/* 入栈数字%s: ↓*/\n", msg.c_str());
    printf("\tmov eax, %s\n\tpush eax\n", msg.c_str());
}

void printAssignmentX86(std::string msg)
{
    printf("\t/* 将栈内数字赋值给%s->%s: ↓*/\n", tempFunName.c_str(), msg.c_str());
    msg.append(tempFunName);
    auto it = identifierIndexMap.find(msg);
    if (it != identifierIndexMap.end())
    {
        printf("\tpop eax\n\tmov DWORD PTR [ebp-%d], eax\n", it->second * 4);
    }
    else
    {
        identifierIndexMap[msg] = identifierIndexValue++;
        printf("\tpop eax\n\tmov DWORD PTR [ebp-%d], eax\n", identifierIndexMap[msg] * 4);
    }
}

void printDefinitionX86(std::string msg)
{
    printf("\t/* 定义变量%s->%s: ↓*/\n", tempFunName.c_str(), msg.c_str());
    msg.append(tempFunName);
    auto it = identifierIndexMap.find(msg);
    if (it == identifierIndexMap.end())
    {
        identifierIndexMap[msg] = identifierIndexValue++;
        printf("\tmov DWORD PTR [ebp-%d], 0\n", identifierIndexMap[msg] * 4);
    }
}

void saveFunNameNum(std::string msg)
{
    auto it = funNameIndexMap.find(msg);
    if (it == funNameIndexMap.end())
    {
        funNameIndexMap[msg] = tempInt;
    }
    else
    {
        fprintf(stderr, "函数%s已存在，对应参数为: %d\n", msg.c_str(), it->second);
    }
    tempInt = 0;
}

void printIdentifierX86(std::string msg)
{
    printf("\t/* 找到变量%s->%s对应的值然后入栈: ↓*/\n", tempFunName.c_str(), msg.c_str());
    msg.append(tempFunName);
    auto it = identifierIndexMap.find(msg);
    if (it != identifierIndexMap.end())
    {
        printf("\tmov eax, DWORD PTR [ebp-%d]\n\tpush eax\n", it->second * 4);
    }
    else
    {
        fprintf(stderr, "\t未找到printIdentifierX86 %s 对应的值\n", msg.c_str());
    }
}

int findFunNameNum(std::string msg)
{
    auto it = funNameIndexMap.find(msg);
    if (it != funNameIndexMap.end())
    {
        return it->second;
    }
    else
    {
        fprintf(stderr, "未找到函数%s 对应的参数个数\n", msg.c_str());
    }
    return 0; // 默认返回0，如果未找到函数名
}

void printPrintX86()
{
    printf("\t/*打印变量:↓*/\n");
    printf("\tpush offset format_str\n\tcall printf\n\tadd esp, 8\n");
}

void printFunNameX86(std::string msg)
{
    printf("\t/* 定义函数%s: ↓*/\n", msg.c_str());
    printf("%s:\n\tpush ebp\n\tmov ebp, esp\n\tsub esp, 0x200\n", msg.c_str());
}

void printFunArgX86()
{
    printf("\t/* 处理函数的参数: ↓*/\n");
    int theArgsNum = 0;

    while (!tempStack.empty())
    {
        printDefinitionX86(tempStack.top());
        printf("\t/* 给参数赋初值 ↓*/\n");
        printf("\tmov eax, DWORD PTR[ebp+%d]\n", 8 + theArgsNum++ * 4);
        printf("\tpush eax\n");
        printAssignmentX86(tempStack.top());
        tempStack.pop();
    }
}
