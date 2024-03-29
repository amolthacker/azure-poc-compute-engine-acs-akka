package com.td.veritas.valengine.akka

import akka.actor.{Actor, ActorLogging, ActorSystem, Props, RootActorPath}
import akka.cluster.{Cluster, Member, MemberStatus}
import akka.cluster.ClusterEvent.{CurrentClusterState, MemberUp}
import akka.pattern.pipe
import com.typesafe.config.ConfigFactory

import scala.concurrent.Future

/**
  * Created by Amol on 5/5/17.
  */
class Valengine extends Actor with ActorLogging {

  import context.dispatcher

  val cluster = Cluster(context.system)

  // subscribe to cluster changes
  override def preStart(): Unit = cluster.subscribe(self, classOf[MemberUp])
  override def postStop(): Unit = cluster.unsubscribe(self)

  def receive = {

    case ValuationRequest(tradeId, metric) =>
      log.info("Computing {} for {} ...", metric, tradeId)
      Future(computeMetric(metric)) map { result =>
          log.debug("{} [{}] = {}", metric, tradeId, result)
          ValuationResponse(tradeId, metric, result)
      } pipeTo sender()

    case ValuationJobRequest(jobId, metric, numTrades) =>
      log.info("Processing job {} [{}|{}] ...", jobId, metric, numTrades)
      val start = System.currentTimeMillis()
      Future(computeAggMetric(metric, numTrades)) map { result =>
        log.info(s"$jobId [$metric | $numTrades] = $result in ${System.currentTimeMillis() - start} ms")
        ValuationJobResponse(jobId, metric, numTrades, result, System.currentTimeMillis() - start)
      } pipeTo sender()

    case state: CurrentClusterState =>
      state.members.filter(_.status == MemberStatus.Up) foreach register

    case MemberUp(m) => register(m)
  }

  def computeMetric(metric: ValMetric): Double = {
    // TODO: QL call
    metric match {
      case ValMetric.FwdRate   => Pricer.computeFRASpot()
      //case ValMetric.ParRate   => 3.14d
      case ValMetric.NPV       => Pricer.computeSwapNPV()
      //case ValMetric.IRDelta   => 1000.0d
      case ValMetric.OptionPV  => Pricer.computeEquityOptionNPV()
      case _ => 0.0d
    }
  }

  def computeAggMetric(metric: ValMetric, numTrades: Int): Double = {
    var agg = 0.0d
    for (i <- 1 to numTrades){
      agg += computeMetric(metric)
    }
    if(numTrades == 0.0d) numTrades else agg / numTrades
  }

  def register(member: Member): Unit =
    if (member.hasRole("ctrl")) {
      context.actorSelection(RootActorPath(member.address) / "user" / "ctrl") ! EngineRegistration
    }

}

object Valengine {

  def main(args: Array[String]): Unit =
  {
    val port = if (args.isEmpty) "0" else args(0)

    val config = ConfigFactory.parseString(s"${Properties.AKKA_REMOTE_PORT}=$port")
                  //.withFallback(ConfigFactory.parseString(s"akka.remote.netty.tcp.bind-hostname=$internalIp"))
                  .withFallback(ConfigFactory.parseString(s"${Properties.AKKA_CLUSTER_ROLES} = [valeng]"))
                  .withFallback(ClusterConfig.config)

    val system = ActorSystem(config.getString(Properties.VALENGINE_CLUSTER_NAME), config)
    system.actorOf(Props[Valengine], name = "valeng")
  }

}
