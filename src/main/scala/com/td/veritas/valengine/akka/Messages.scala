package com.td.veritas.valengine.akka

/**
  * Created by thacka4 on 5/2/2017.
  */

final case class ValuationRequest(tradeId: String, metric: ValMetric)
final case class ValuationResponse(tradeId: String, metric: ValMetric, result: Double)
final case class ValuationFailed(reason: String, job: ValuationRequest)

final case class ValuationJobRequest(jobId: String, metric: ValMetric, numTrades: Int)
final case class ValuationJobResponse(jobId: String, metric: ValMetric, numTrades: Int, aggResult: Double, duration: Long)
final case class ValuationJobFailed(reason: String, job: ValuationJobRequest)

case object EngineRegistration

