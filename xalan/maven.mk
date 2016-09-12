this.makefile=$(lastword $(MAKEFILE_LIST))
this.dir=$(dir $(realpath ${this.makefile}))
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
lib.dir?=${this.dir}maven

jtidy.libs  =  \
	$(lib.dir)/net/sf/jtidy/jtidy/r938/jtidy-r938.jar


xalan.libs  = \
	$(lib.dir)/xalan/serializer/2.7.2/serializer-2.7.2.jar \
	$(lib.dir)/xalan/xalan/2.7.2/xalan-2.7.2.jar \
	$(lib.dir)/xml-apis/xml-apis/1.3.04/xml-apis-1.3.04.jar

.PHONY:all clean


all: ${this.dir}dist/xalan
	
${this.dir}dist/xalan : ${this.dir}dist/xalan.jar ${xalan.libs} 
	echo '#!/bin/bash' > $@
	echo 'java -Dfile.encoding=UTF8 -cp "$(subst $(SPACE),:,$(filter %.jar,$^))" org.apache.xalan.xslt.Process $$*' >>  $@
	chmod +x  $@

${this.dir}dist/xalan.jar : ./src/main/java/com/github/lindenb/xslt/img/Image.java \
				 ./src/main/java/com/github/lindenb/xslt/strings/Strings.java \
				 ${xalan.libs} 
	rm -rf tmp
	mkdir -p  dist tmp/WEB-INF
	javac  -classpath "$(subst $(SPACE),:,$(filter %.jar,$^))" -d tmp -sourcepath ./src/main/java $(filter %.java,$^)
	echo "Manifest-Version: 1.0" > tmp/mf
	echo "Main-Class: org.apache.xalan.xslt.Process" >>  tmp/mf
	echo "Class-Path: $(realpath $(filter %.jar,$^))" | fold -w 71 | awk '{printf("%s%s\n",(NR==1?"": " "),$$0);}' >>  tmp/mf
	jar cfvm $@ tmp/mf -C tmp .
	rm -rf tmp


clean:
	rm -rf tmp dist maven
	
	
all_maven_jars = $(sort  ${xalan.libs})
${xalan.libs}  : 
	mkdir -p $(dir $@) && wget -O "$@" "http://central.maven.org/maven2/$(patsubst ${lib.dir}/%,%,$@)"

