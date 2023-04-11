package com.example;

import io.micronaut.core.annotation.Introspected;
import io.micronaut.http.annotation.*;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;

@Controller
public class HomeController {

    @Get("/hello")
    public Map<String, Object> hello(@QueryValue Optional<String> name) {
        return Collections.singletonMap("message", "Hello " + name.orElse("?"));
    }

    @Post("/hello")
    public Map<String, Object> helloPost(@Body SampleInput input) {
        return Collections.singletonMap("message", "Hello " + input.name);
    }

    @Introspected
    static class SampleInput {
        String name;

        public void setName(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }
}
