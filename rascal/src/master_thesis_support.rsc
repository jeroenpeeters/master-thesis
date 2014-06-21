module master_thesis_support

import Prelude;
import util::Math;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Registry;
import util::FileSystem;

import metrics::CyclomaticComplexity;
import metrics::Volume;

data Unit = unit(loc src, num linesOfCode, num cyclomaticComplexity);

alias Units = set[Unit];

public void analyze(){
}


public void analyze(loc projectloc){
	model = createM3FromDirectory_(projectloc);
	docs = _docs(model);
	
	println("decl in model: <size(model@declarations)>");
	mthds = declaredMethods(model);
	units = filterEmpty( { unit(method, sloc(method, docs), cc(method)) | <loc class, loc method> <- mthds } );
	
	println("Total units: <size(units)>");
	
	ppCcUnits = ppCc(units);
	pCcUnits = pCc(units);
	nCcUnits = nCc(units);
	mCcUnits = mCc(units);
	
	ppSlocUnits = ppSloc(units);
	pSlocUnits = pSloc(units);
	nSlocUnits = nSloc(units);
	mSlocUnits = mSloc(units);
	
	println("ppCc: <size(ppCcUnits)> :: <prcnt(ppCcUnits, units)>");
	println("pCc: <size(pCcUnits)> :: <prcnt(pCcUnits, units)>");
	println("nCc: <size(nCcUnits)> :: <prcnt(nCcUnits, units)>");
	println("mCc: <size(mCcUnits)> :: <prcnt(mCcUnits, units)>");

	println("ppSloc: <size(ppSlocUnits)> :: <prcnt(ppSlocUnits, units)>");
	println("pSloc: <size(pSlocUnits)> :: <prcnt(pSlocUnits, units)>");
	println("nSloc: <size(nSlocUnits)> :: <prcnt(nSlocUnits, units)>");
	println("mSloc: <size(mSlocUnits)> :: <prcnt(mSlocUnits, units)>");
	
}

public real prcnt(set[&A] slice, set[&B] total) = prcnt(size(slice), size(total));
public real prcnt(int slice, int total) = (toReal(slice) / total);

public Units ppCc(Units units)  = { u | u <- units, u.cyclomaticComplexity <= 10 };
public Units pCc(Units units)   = { u | u <- units, u.cyclomaticComplexity > 10, u.cyclomaticComplexity <= 20 };
public Units nCc(Units units)   = { u | u <- units, u.cyclomaticComplexity > 20, u.cyclomaticComplexity <= 50 };
public Units mCc(Units units)   = { u | u <- units, u.cyclomaticComplexity > 50 };

public Units ppSloc(Units units) = { u | u <- units, u.linesOfCode <= 10 };
public Units pSloc(Units units)  = { u | u <- units, u.linesOfCode > 10, u.linesOfCode <= 50 };
public Units nSloc(Units units)  = { u | u <- units, u.linesOfCode > 50, u.linesOfCode <= 100 };
public Units mSloc(Units units)  = { u | u <- units, u.linesOfCode > 100 };

public Units badUnits(Units units) = { u | u : unit(_, linesOfCode, cyclomaticComplexity) <- units, linesOfCode > 20 || cyclomaticComplexity > 10 };
private Units filterEmpty(Units units) = { u | u <- units, u.linesOfCode > 0 };

private set[str] _docs(M3 m3) = ({} | it + toSet(readFileLines(l)) | <_,l> <- m3@documentation );

private M3 createM3FromDirectory_(loc project, str javaVersion = "1.7") {
    if (!(isDirectory(project)))
      throw "<project> is not a valid directory";
    classPaths = getPaths(project, "class") + find(project, "jar");
    sourcePaths = getPaths(project, "java");
    setEnvironmentOptions(classPaths, sourcePaths);
    m3s = { *createM3FromFile(f, javaVersion = javaVersion) | sp <- sourcePaths, loc f <- find(sp, "java") };
    M3 result = composeJavaM3(project, m3s);
    registerProject(project, result);
    return result;
}