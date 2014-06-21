module metrics::Volume

import Prelude;
import lang::java::m3::Core;
import lang::java::m3::AST;

/*
 * These functions calculate the source lines of code for the given declaration.
 */
public num sloc(loc code, set[str] comments) = sloc(getMethodAST(code), comments);
public num sloc([Declaration] /method(_,_,_,_, Statement impl), set[str] comments) = sloc(impl, comments);
public num sloc([Declaration] /constructor(_,_,_,Statement impl), set[str] comments) = sloc(impl, comments); 
public num sloc(Statement impl, set[str] comments) = sum([ 1 | line <- readFileLines(impl@src), size(trim(line))>0, line notin comments ] - 2);
public num sloc(_, _) = 0;	
