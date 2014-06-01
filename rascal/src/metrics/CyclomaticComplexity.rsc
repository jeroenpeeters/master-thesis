module metrics::CyclomaticComplexity

import lang::java::m3::AST;
import lang::java::m3::Core;

public num cc(loc code) = cc(getMethodAST(code), true);

@doc {
Computes the complexity of the given sub-AST.
Complexity increases for the following: break, case, catch, continue, do-while, foreach, for, if, if-else, throw, while, 
return that is not the last statement and for boolean expressions (&&, ||).
}
public int cc(Statement stmnt, bool strict){
    int i = 1;
    int retCount = -1;
    visit(stmnt){
    	case \case(_): i += 1;
    	case \catch(_,_): i += 1;
    	case \conditional(_,_,_): i += 1;
    	case \foreach(_,_,_): i += 1;
    	case \for(_,_,_,_): i += 1;
    	case \for(_,_,_): i += 1;
    	case \if(_,_,_): i += 1;
    	case \if(_,_): i += 1;
    	case \infix(_,"||",_,_): i += 1;
    	case \infix(_,"&&",_,_): i += 1;
    	case \while(_,_): i += 1;
    	
    	case \default(_): i+= s(strict);
    	case \return(): retCount += s(strict);
    	case \return(_): retCount += s(strict);
    	case \break(): i += s(strict);
    	case \break(_): i+= s(strict);
    	case \continue(): i += s(strict);
    	case \continue(_): i+= s(strict);
    	case \do(_,_): i += s(strict);
    	case \throw(_): i += s(strict);
    }
    retCount = retCount == -1 ? 0 : retCount;
    return i + retCount;
}

private int s(bool b) = b ? 0 : 1;
