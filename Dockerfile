FROM amolthacker/quantlib-java

ENTRYPOINT ["/usr/bin/java", "-jar", "/tds-veritas/compute/compute-engine-akka-0.1.0-ve.jar"]

ADD target/compute-engine-akka-0.1.0-ve.jar /tds-veritas/compute/compute-engine-akka-0.1.0-ve.jar