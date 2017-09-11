package com.td.veritas.valengine.akka

/**
  * Created by Amol on 5/6/17.
  */
object MainLocal extends App {

  Controller.main(Array.empty)
  Valengine.main(Seq("8000").toArray)

}
