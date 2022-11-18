export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
java -Xmx1024m -jar /tmp/Generator-1.0-SNAPSHOT-jar-with-dependencies.jar "$1" "$2" "$3" "$4"
