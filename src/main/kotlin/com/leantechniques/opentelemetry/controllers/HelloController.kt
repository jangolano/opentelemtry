package com.leantechniques.opentelemetry.controllers

import io.micrometer.core.instrument.Counter
import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.Timer
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.util.function.Supplier
import kotlin.concurrent.thread

@RestController
class HelloController(
    meterRegistry: MeterRegistry,
) {
    private val log = LoggerFactory.getLogger(HelloController::class.java)
    private var helloCalled: Counter? = null
    private var helloDuration: Timer? = null

    init {
        helloCalled = Counter.builder("hello.counter").register(meterRegistry)
        helloDuration = Timer.builder("hello.timer").register(meterRegistry)
    }

    @GetMapping("/hello")
    fun hello(): String {
        log.info("Hello endpoint called")
        helloDuration?.record(
            Supplier {
                helloCalled?.increment()
                thread { Thread.sleep(1000) }
            },
        )
        return "Hello World"
    }
}
