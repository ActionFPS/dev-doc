.PHONY: \
	default \
	install \
	clean \

default: target/structure.svg

clean:
	rm -rf target

install: target/structure.svg
	cp target/structure.svg structure.svg

target/structure.xml:
	mkdir -p target
	$(error do it yourself from IntelliJ's sbt: "*/*:dumpStructureTo $(PWD)/target/structure.xml prettyPrint download")

target/structure.svg: target/structure.dot
	dot -Tsvg -o target/structure.svg target/structure.dot

target/structure.dot: target/structure.xml
	coursier launch net.sf.saxon:Saxon-HE:9.7.0-18 --main net.sf.saxon.Transform -- -s:target/structure.xml -xsl:struct.xsl -o:target/structure.dot
