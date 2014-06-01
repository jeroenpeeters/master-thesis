module master_thesis_support

import Prelude;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Registry;
import util::FileSystem;

import metrics::CyclomaticComplexity;
import metrics::Volume;

data Unit = unit(loc src, num linesOfCode, num cyclomaticComplexity);

public void analyze(){
}


public void analyze(loc projectloc){
	model = createM3FromDirectory_(projectloc);
	
	println("decl in model: <size(model@declarations)>");
	mthds = declaredMethods(model);
	println("num of methods: <size(mthds)>");
	
	docs = _docs(model);
	rel[loc, loc] methods = declaredMethods(model);
	
	units = { unit(method, sloc(method, docs), cc(method)) | <loc class, loc method> <- mthds };
	
	for(u <- toList(units)[..10]){
		println(u);
	}
}

private set[str] _docs(M3 m3) = ({} | it + toSet(readFileLines(l)) | <_,l> <- m3@documentation );

public M3 createM3FromDirectory_(loc project, str javaVersion = "1.7") {
    if (!(isDirectory(project)))
      throw "<project> is not a valid directory";
    classPaths = getPaths(project, "class") + find(project, "jar");
    sourcePaths = getPaths(project, "java");
    setEnvironmentOptions(classPaths, sourcePaths);
    m3s = {};
    for (sp <- sourcePaths) {
      m3s += { createM3FromFile(f, javaVersion = javaVersion) | loc f <- find(sp, "java") };
    }
    M3 result = composeJavaM3(project, m3s);
    registerProject(project, result);
    return result;
}