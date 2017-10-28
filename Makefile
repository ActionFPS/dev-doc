.PHONY: \
	default \
	install \
	clean \

default: target/structure.svg

clean:
	rm -rf target

install: target/structure.svg
	cp target/structure.svg structure.svg

target/sbt-structure-extractor.jar:
	mkdir -p target
	wget --continue -O target/sbt-structure-extractor.jar http://dl.bintray.com/jetbrains/sbt-plugins/org.jetbrains/sbt-structure-extractor/scala_2.10/sbt_0.13/7.0.0+61-051fb9ba/jars/sbt-structure-extractor.jar


target/structure.xml: target/sbt-structure-extractor.jar
ifndef SBT_REPO
	$(error SBT_REPO is not set)
endif
	cd $(SBT_REPO) && \
	sbt 'set SettingKey[Option[File]]("sbtStructureOutputFile") in Global := Some(file("$(PWD)/target/structure.xml"))' \
		'set SettingKey[String]("sbtStructureOptions") in Global := "prettyPrint download"' \
		'apply -cp $(PWD)/target/sbt-structure-extractor.jar org.jetbrains.sbt.CreateTasks' \
		'*/*:dumpStructure'

target/structure.svg: target/structure.dot
	dot -Tsvg -o target/structure_1.svg target/structure.dot
	coursier launch net.sf.saxon:Saxon-HE:9.7.0-18 --main net.sf.saxon.Transform -- -s:target/structure_1.svg -xsl:add-underline.xsl -o:target/structure.svg 

target/structure.dot: target/structure.xml
	coursier launch net.sf.saxon:Saxon-HE:9.7.0-18 --main net.sf.saxon.Transform -- -s:target/structure.xml -xsl:struct.xsl -o:target/structure.dot
