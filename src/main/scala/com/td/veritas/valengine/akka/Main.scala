package com.td.veritas.valengine.akka

/**
  * Created by thacka4 on 5/2/2017.
  */
import akka.actor.{ActorSystem, Props}
import scala.collection.JavaConversions._

object Main {

  def main(args: Array[String]): Unit =
  {
    val config = ClusterConfig.config
    val system = ActorSystem(config.getString(Properties.VALENGINE_CLUSTER_NAME), config)
    system.log.info("Configured seed nodes: " + config.getStringList(Properties.AKKA_CLUSTER_SEED_NODES).mkString(", "))
    system.actorOf(Props[ClusterMonitor], "cluster-monitor")
  }

}
