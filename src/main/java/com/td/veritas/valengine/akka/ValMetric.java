package com.td.veritas.valengine.akka;

/**
 * Created by Amol on 5/7/17.
 */
public enum ValMetric {

    FwdRate,
    OptionPV,
    NPV;

    public static ValMetric getRandom() {
        return values()[(int) (Math.random() * values().length)];
    }

}
